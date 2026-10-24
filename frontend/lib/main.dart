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

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 2) {
              _prefilledTransitPlace = null;
            }
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
    );
  }
}
