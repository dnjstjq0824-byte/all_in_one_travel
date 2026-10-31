import 'package:flutter/material.dart';
import '../../core/api/travel_api_client.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_place_mini_card.dart';
import 'widgets/home_quick_actions.dart';

class HomeScreen extends StatefulWidget {
  final List<City> cities;
  final City currentCity;
  final WeatherReport? weather;
  final Function(City newCity) onCityChanged;
  final Function(int tabIndex) onNavigateTab;
  final Function(Place place)? onPlanRoute;
  final Function(Place place)? onAddToTrip;

  const HomeScreen({
    super.key,
    required this.cities,
    required this.currentCity,
    this.weather,
    required this.onCityChanged,
    required this.onNavigateTab,
    this.onPlanRoute,
    this.onAddToTrip,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MetroLine> _metroLines = [];
  List<MetroStation> _metroStations = [];
  List<Place> _topPlaces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCityData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity.id != widget.currentCity.id) {
      _loadCityData();
    }
  }

  Future<void> _loadCityData() async {
    setState(() => _loading = true);
    final lines = await TravelApiClient.fetchMetroLines(widget.currentCity.id);
    final stations = await TravelApiClient.fetchMetroStations(widget.currentCity.id);
    final places = await TravelApiClient.fetchPlaces(widget.currentCity.id);

    if (mounted) {
      setState(() {
        _metroLines = lines;
        _metroStations = stations;
        _topPlaces = places;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.currentCity;
    final w = widget.weather;

    return Scaffold(
      appBar: HomeAppBar(
        cities: widget.cities,
        currentCity: c,
        onCityChanged: widget.onCityChanged,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: InkWell(
                    onTap: () => widget.onNavigateTab(3),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.accent),
                          const SizedBox(width: 10),
                          Text(AppLocale.tr('search_placeholder'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),

                // City Hero Card
                HomeHeroCard(city: c, weather: w),
                const SizedBox(height: 16),

                // Quick Access Actions
                HomeQuickActions(
                  city: c,
                  metroLines: _metroLines,
                  metroStations: _metroStations,
                  onNavigateTab: widget.onNavigateTab,
                ),
                const SizedBox(height: 20),

                // Popular Attractions Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${c.name} ${AppLocale.tr('popular_places')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      TextButton(
                        onPressed: () => widget.onNavigateTab(3),
                        child: Text(AppLocale.tr('view_all'), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Attractions List
                if (_loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (_topPlaces.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No places loaded yet.', style: TextStyle(color: AppTheme.textMuted)),
                  )
                else
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _topPlaces.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (ctx, i) => HomePlaceMiniCard(
                        place: _topPlaces[i],
                        weather: widget.weather,
                        onPlanRoute: widget.onPlanRoute,
                        onAddToTrip: widget.onAddToTrip,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Verified Transit Status Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.blue.shade50.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.accent,
                            child: Icon(Icons.verified, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c.name} Metro & Bus Verified', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                                Text(
                                  '${_metroLines.length} subway lines and ${_metroStations.length} stations directly connected to tour destinations.',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
