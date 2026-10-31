import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import 'widgets/explore_place_card.dart';

class ExploreScreen extends StatefulWidget {
  final City currentCity;
  final WeatherReport? weather;
  final Function(Place place)? onPlanRoute;
  final Function(Place place)? onAddToTrip;

  const ExploreScreen({
    super.key,
    required this.currentCity,
    this.weather,
    this.onPlanRoute,
    this.onAddToTrip,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Place> _places = [];
  bool _loading = true;
  String _selectedCategory = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'All',
    'Historic & Culture',
    'Landmark',
    'Museum & Art',
    'Nature & Park',
    'Food & Market',
    'Night View',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity.id != widget.currentCity.id) {
      _loadPlaces();
    }
  }

  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    final cat = _selectedCategory == 'All' ? null : _selectedCategory;
    final q = _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim();
    final list = await TravelApiClient.fetchPlaces(widget.currentCity.id, query: q, category: cat);
    if (mounted) {
      setState(() {
        _places = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentCity.name} ${AppLocale.tr('tab_explore')}'),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppLocale.tr('search_placeholder'),
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadPlaces();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (_) => _loadPlaces(),
            ),
          ),

          // Category Pills
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSel = (_selectedCategory.isEmpty && cat == 'All') || _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  selected: isSel,
                  selectedColor: AppTheme.accent,
                  labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? cat : 'All';
                    });
                    _loadPlaces();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Place Cards List (Responsive Grid for Tablet/Desktop, List for Mobile)
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _places.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.travel_explore, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text('No attractions found in ${widget.currentCity.name}', style: const TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 800) {
                            final crossAxisCount = constraints.maxWidth >= 1200 ? 3 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.95,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _places.length,
                              itemBuilder: (ctx, index) => ExplorePlaceCard(
                                place: _places[index],
                                weather: widget.weather,
                                onPlanRoute: widget.onPlanRoute,
                                onAddToTrip: widget.onAddToTrip,
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _places.length,
                            itemBuilder: (ctx, index) => ExplorePlaceCard(
                              place: _places[index],
                              weather: widget.weather,
                              onPlanRoute: widget.onPlanRoute,
                              onAddToTrip: widget.onAddToTrip,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
