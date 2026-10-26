import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/models/travel_models.dart';
import 'core/l10n/app_localizations.dart';
import 'core/api/travel_api_client.dart';
import 'features/home/home_screen.dart';
import 'features/map/global_map_screen.dart';
import 'features/transit/transit_planner_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/trips/my_trip_screen.dart';
import 'features/admin/admin_coverage_screen.dart';

void main() {
  runApp(const GlobalTravelApp());
}

class GlobalTravelApp extends StatelessWidget {
  const GlobalTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocale.currentLanguage,
      builder: (context, lang, _) {
        return MaterialApp(
          title: 'GLOBAL TRAVEL ESSENTIAL',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  List<City> _cities = [];
  City? _currentCity;
  WeatherReport? _currentWeather;
  bool _loading = true;

  Place? _prefilledTransitPlace;

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  Future<void> _initializeAppData() async {
    final list = await TravelApiClient.fetchCities();
    if (mounted) {
      setState(() {
        _cities = list;
        if (list.isNotEmpty) {
          _currentCity = list.first; // Default Seoul
        }
        _loading = false;
      });
      if (_currentCity != null) {
        _loadCityWeather(_currentCity!.id);
      }
    }
  }

  Future<void> _loadCityWeather(String cityId) async {
    final w = await TravelApiClient.fetchWeather(cityId);
    if (mounted) {
      setState(() {
        _currentWeather = w;
      });
    }
  }

  void _onCityChanged(City newCity) {
    setState(() {
      _currentCity = newCity;
      _currentWeather = null;
    });
    _loadCityWeather(newCity.id);
  }

  void _handlePlanRoute(Place place) {
    setState(() {
      _prefilledTransitPlace = place;
      _currentIndex = 2; // Switch to Transit Tab
    });
  }

  void _handleAddToTrip(Place place) async {
    final trips = await TravelApiClient.fetchTrips();
    if (!mounted) return;

    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a trip first in "My Trip" tab.')),
      );
      return;
    }

    final targetTrip = trips.first;
    final item = ItineraryItem(
      id: '',
      placeId: place.id,
      title: place.name,
      subtitle: place.category,
      category: place.category,
      order: 1,
      timeScheduled: '11:00',
      latitude: place.latitude,
      longitude: place.longitude,
      durationMin: place.estimatedDurationMin,
      notes: 'Nearest metro: ${place.nearestMetroStationName}',
      isCompleted: false,
    );

    final updated = await TravelApiClient.addItineraryItem(targetTrip.id, 1, item);
    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${place.name}" to Day 1 of "${targetTrip.title}"!'),
          action: SnackBarAction(
            label: 'View Trip',
            onPressed: () {
              setState(() => _currentIndex = 4); // Switch to My Trip
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _currentCity == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to Global Travel Platform...', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        cities: _cities,
        currentCity: _currentCity!,
        weather: _currentWeather,
        onCityChanged: _onCityChanged,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
        onPlanRoute: _handlePlanRoute,
        onAddToTrip: _handleAddToTrip,
      ),
      GlobalMapScreen(
        currentCity: _currentCity!,
        weather: _currentWeather,
        onPlanRoute: _handlePlanRoute,
        onAddToTrip: _handleAddToTrip,
      ),
      TransitPlannerScreen(
        currentCity: _currentCity!,
        targetPlace: _prefilledTransitPlace,
      ),
      ExploreScreen(
        currentCity: _currentCity!,
        weather: _currentWeather,
        onPlanRoute: _handlePlanRoute,
        onAddToTrip: _handleAddToTrip,
      ),
      MyTripScreen(
        currentCity: _currentCity!,
        weather: _currentWeather,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

        if (isDesktop || isTablet) {
          // PC & Tablet Dedicated Desktop UX/UI (Article 3 & 5)
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Brand Logo
                    Row(
                      children: [
                        const Icon(Icons.travel_explore, color: AppTheme.accentLight, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GLOBAL TRAVEL ESSENTIAL',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.5),
                            ),
                            Text(
                              'Booking Network Co., Ltd. • Production Edition',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // City Selector Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<City>(
                          dropdownColor: AppTheme.primaryDark,
                          value: _cities.firstWhere((x) => x.id == _currentCity!.id, orElse: () => _currentCity!),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                '${city.name} (${city.countryCode})',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newCity) {
                            if (newCity != null) _onCityChanged(newCity);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Weather Indicator
                    if (_currentWeather != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_currentWeather!.currentTempC.toStringAsFixed(1)}°C • ${_currentWeather!.condition}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Language Selector
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: AppTheme.primaryDark,
                        value: AppLocale.currentLanguage.value,
                        icon: const Icon(Icons.language, color: Colors.white70, size: 18),
                        items: const [
                          DropdownMenuItem(value: 'ko', child: Text('한국어 (KO)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(value: 'en', child: Text('English (EN)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(value: 'ja', child: Text('日本語 (JA)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(value: 'zh', child: Text('中文 (ZH)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(value: 'fr', child: Text('Français (FR)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(value: 'es', child: Text('Español (ES)', style: TextStyle(color: Colors.white, fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) AppLocale.setLanguage(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Admin Console Button
                    IconButton(
                      tooltip: 'Coverage & Governance Console',
                      icon: const Icon(Icons.shield_outlined, color: Colors.white70),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => AdminCoverageScreen(cities: _cities)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Row(
              children: [
                // Left Navigation Sidebar
                if (isDesktop)
                  _buildDesktopSidebar()
                else
                  _buildTabletNavRail(),
                VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout (< 600px, Article 4)
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  if (index != 2) _prefilledTransitPlace = null;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: AppLocale.tr('tab_home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.map_outlined),
                  activeIcon: const Icon(Icons.map),
                  label: AppLocale.tr('tab_map'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.directions_transit_outlined),
                  activeIcon: const Icon(Icons.directions_transit),
                  label: AppLocale.tr('tab_transit'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  activeIcon: const Icon(Icons.explore),
                  label: AppLocale.tr('tab_explore'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.luggage_outlined),
                  activeIcon: const Icon(Icons.luggage),
                  label: AppLocale.tr('tab_my_trip'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopSidebar() {
    final navItems = [
      (Icons.home_outlined, Icons.home, AppLocale.tr('tab_home')),
      (Icons.map_outlined, Icons.map, AppLocale.tr('tab_map')),
      (Icons.directions_transit_outlined, Icons.directions_transit, AppLocale.tr('tab_transit')),
      (Icons.explore_outlined, Icons.explore, AppLocale.tr('tab_explore')),
      (Icons.luggage_outlined, Icons.luggage, AppLocale.tr('tab_my_trip')),
    ];

    return Container(
      width: 220,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'NAVIGATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1),
            ),
          ),
          ...List.generate(navItems.length, (idx) {
            final isSel = _currentIndex == idx;
            final item = navItems[idx];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: isSel ? AppTheme.accent.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSel ? Border.all(color: AppTheme.accent.withValues(alpha: 0.2)) : null,
              ),
              child: ListTile(
                dense: true,
                leading: Icon(isSel ? item.$2 : item.$1, color: isSel ? AppTheme.accent : AppTheme.textMuted),
                title: Text(
                  item.$3,
                  style: TextStyle(
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? AppTheme.accent : AppTheme.textMain,
                    fontSize: 14,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () {
                  setState(() {
                    _currentIndex = idx;
                    if (idx != 2) _prefilledTransitPlace = null;
                  });
                },
              ),
            );
          }),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_done, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentCity?.name} Active',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentCity?.coverageLevel ?? "LEVEL_A"} Certified',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'v1.0.0 • Booking Network',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletNavRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (idx) {
        setState(() {
          _currentIndex = idx;
          if (idx != 2) _prefilledTransitPlace = null;
        });
      },
      labelType: NavigationRailLabelType.selected,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(AppLocale.tr('tab_home')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.map),
          label: Text(AppLocale.tr('tab_map')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.directions_transit_outlined),
          selectedIcon: const Icon(Icons.directions_transit),
          label: Text(AppLocale.tr('tab_transit')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: Text(AppLocale.tr('tab_explore')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.luggage_outlined),
          selectedIcon: const Icon(Icons.luggage),
          label: Text(AppLocale.tr('tab_my_trip')),
        ),
      ],
    );
  }
}
