import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import 'place_detail_screen.dart';

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
                              itemBuilder: (ctx, index) => _buildPlaceCard(_places[index]),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _places.length,
                            itemBuilder: (ctx, index) => _buildPlaceCard(_places[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => PlaceDetailScreen(
                place: place,
                weather: widget.weather,
                onPlanRoute: widget.onPlanRoute,
                onAddToTrip: widget.onAddToTrip,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Overlay
            Stack(
              children: [
                Image.network(
                  place.photoUrls.isNotEmpty ? place.photoUrls.first : 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=800&q=80',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.travel_explore, size: 36, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(8)),
                    child: Text(place.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  Text(place.englishName, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 10),

                  // ARTICLE 12: Nearest Metro Connection Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.subway, size: 14, color: AppTheme.accent),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            place.nearestMetroStationName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
