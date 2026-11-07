import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_travel_app/core/models/travel_models.dart';
import 'package:global_travel_app/core/state/city_scope.dart';
import 'package:global_travel_app/core/theme/app_theme.dart';
import 'package:global_travel_app/pages/arrivals_page.dart';
import 'package:global_travel_app/pages/cities_page.dart';
import 'package:global_travel_app/pages/coverage_page.dart';
import 'package:global_travel_app/pages/explore_page.dart';
import 'package:global_travel_app/pages/home_page.dart';
import 'package:global_travel_app/pages/map_page.dart';
import 'package:global_travel_app/pages/metro_page.dart';
import 'package:global_travel_app/pages/offline_page.dart';
import 'package:global_travel_app/pages/transit_page.dart';
import 'package:global_travel_app/pages/trips_page.dart';

class _FakeHttpOverrides extends HttpOverrides {
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) =>
      '';
}

final _city = City(
  id: 'seoul',
  countryCode: 'KR',
  name: 'Seoul',
  englishName: 'Seoul',
  localName: '서울',
  latitude: 37.5665,
  longitude: 126.9780,
  timezone: 'Asia/Seoul',
  coverageLevel: 'LEVEL_A',
  transportModes: ['METRO', 'BUS', 'WALK'],
  description: 'Capital of South Korea',
  heroImageUrl: '',
);

Widget _wrap(Widget page) {
  final session = CitySession()
    ..cities = [_city]
    ..current = _city
    ..loading = false;
  return CityScope(
    notifier: session,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: page),
    ),
  );
}

/// Every page must build cleanly at compact, tablet and PC windows.
/// LayoutBuilder + MediaQuery branches that overflow or throw fail here.
void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  final pages = <String, Widget>{
    'home': const HomePage(),
    'cities': const CitiesPage(),
    'map': const MapPage(),
    'transit': const TransitPage(),
    'arrivals': const ArrivalsPage(),
    'metro': const MetroPage(),
    'explore': const ExplorePage(),
    'trips': const TripsPage(),
    'offline': const OfflinePage(),
    'coverage': const CoveragePage(),
  };

  final windows = <String, Size>{
    'compact-390': const Size(390, 844),
    'tablet-800': const Size(800, 1200),
    'pc-1400': const Size(1400, 900),
  };

  for (final win in windows.entries) {
    for (final page in pages.entries) {
      testWidgets('${page.key} renders at ${win.key}', (tester) async {
        tester.view.physicalSize = win.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        await tester.pumpWidget(_wrap(page.value));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
