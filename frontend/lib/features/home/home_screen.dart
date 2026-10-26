import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import '../metro/metro_map_screen.dart';
import '../explore/place_detail_screen.dart';
import '../admin/admin_coverage_screen.dart';

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
      appBar: AppBar(
        titleSpacing: 16,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<City>(
            value: widget.cities.firstWhere((x) => x.id == c.id, orElse: () => c),
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textMain),
            items: widget.cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city, size: 18, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Text('${city.name} (${city.countryCode})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newCity) {
              if (newCity != null) {
                widget.onCityChanged(newCity);
              }
            },
          ),
        ),
        actions: [
          // Language Switcher
          ValueListenableBuilder<String>(
            valueListenable: AppLocale.currentLanguage,
            builder: (ctx, lang, _) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: lang,
                  icon: const Icon(Icons.language, size: 20, color: AppTheme.primary),
                  items: const [
                    DropdownMenuItem(value: 'ko', child: Text('한국어')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    DropdownMenuItem(value: 'zh', child: Text('中文')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                  ],
                  onChanged: (newLang) {
                    if (newLang != null) {
                      AppLocale.currentLanguage.value = newLang;
                      setState(() {});
                    }
                  },
                ),
              );
            },
          ),
          // Admin Console
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.primary),
            tooltip: AppLocale.tr('admin_console'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AdminCoverageScreen(cities: widget.cities)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
                onTap: () => widget.onNavigateTab(3), // Navigate to Explore
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

            // City Hero Card with Live Weather
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.network(
                      c.heroImageUrl.isNotEmpty ? c.heroImageUrl : 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 180,
                        color: AppTheme.primary,
                        alignment: Alignment.center,
                        child: const Icon(Icons.location_city, size: 48, color: Colors.white24),
                      ),
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(6)),
                        child: Text(c.coverageLevel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${c.name} • ${c.localName}',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  c.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (w != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${w.currentTempC.toStringAsFixed(1)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('${AppLocale.tr('weather_feels_like')} ${w.feelsLikeC.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                    ],
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
            ),
            const SizedBox(height: 16),

            // Quick Access Actions (Metro, Bus, Transit, Offline)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildQuickAction(
                    icon: Icons.subway,
                    label: AppLocale.tr('metro_network'),
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => MetroMapScreen(
                            city: c,
                            lines: _metroLines,
                            stations: _metroStations,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildQuickAction(
                    icon: Icons.directions_bus,
                    label: AppLocale.tr('bus_arrivals'),
                    color: const Color(0xFF10B981),
                    onTap: () => widget.onNavigateTab(2), // Transit Tab
                  ),
                  const SizedBox(width: 10),
                  _buildQuickAction(
                    icon: Icons.alt_route,
                    label: AppLocale.tr('tab_transit'),
                    color: const Color(0xFF6366F1),
                    onTap: () => widget.onNavigateTab(2), // Transit Tab
                  ),
                  const SizedBox(width: 10),
                  _buildQuickAction(
                    icon: Icons.download_for_offline,
                    label: 'Offline',
                    color: const Color(0xFFF59E0B),
                    onTap: () => widget.onNavigateTab(4), // My Trip Tab
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Popular Attractions in this City
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${c.name} ${AppLocale.tr('popular_places')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(3), // Explore Tab
                    child: Text(AppLocale.tr('view_all'), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

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
                  itemBuilder: (ctx, i) {
                    final place = _topPlaces[i];
                    return _buildPlaceMiniCard(place);
                  },
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceMiniCard(Place place) {
    return InkWell(
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
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              place.photoUrls.isNotEmpty ? place.photoUrls.first : 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=400&q=80',
              height: 110,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 110,
                width: 200,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.place, size: 28, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(' (${place.reviewCount})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.nearestMetroStationName,
                    style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
