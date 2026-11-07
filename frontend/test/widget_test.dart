import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_travel_app/app/router.dart';
import 'package:global_travel_app/app/routes.dart';
import 'package:global_travel_app/core/models/travel_models.dart';
import 'package:global_travel_app/core/responsive/devices.dart';
import 'package:global_travel_app/core/state/city_scope.dart';
import 'package:global_travel_app/core/theme/app_theme.dart';
import 'package:global_travel_app/pages/explore_page.dart';
import 'package:global_travel_app/pages/home_page.dart';
import 'package:global_travel_app/pages/metro_page.dart';
import 'package:global_travel_app/pages/transit_page.dart';
import 'package:global_travel_app/pages/trips_page.dart';
import 'package:go_router/go_router.dart';

class _FakeHttpOverrides extends HttpOverrides {
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) =>
      '';
}

final _testCity = City(
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

CitySession _readySession() {
  final session = CitySession()
    ..cities = [_testCity]
    ..current = _testCity
    ..loading = false;
  return session;
}

Widget _wrap(Widget page) {
  return CityScope(
    notifier: _readySession(),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: page),
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  test('route table holds one route per page', () {
    final shell = buildRouteTable().single as ShellRoute;
    expect(shell.routes.length, 11);
    expect(
      Routes.placeDetail('p1', 'seoul'),
      '/place/p1?cityId=seoul',
    );
  });

  test('device breakpoints classify four classes', () {
    expect(deviceOfWidth(1400, isWeb: true), DeviceKind.pc);
    expect(deviceOfWidth(800, isWeb: true), DeviceKind.tablet);
    expect(deviceOfWidth(390, isWeb: true), DeviceKind.mobile);
    expect(deviceOfWidth(390, isWeb: false), DeviceKind.app);
  });

  testWidgets('Metro page renders canvas and mode toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const MetroPage()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(SegmentedButton<MetroViewMode>), findsOneWidget);
  });

  testWidgets('Transit page renders search form',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const TransitPage()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Explore page renders category filters',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const ExplorePage()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(ChoiceChip), findsWidgets);
  });

  testWidgets('Trips page renders ledger shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const TripsPage()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('Home page renders board and index',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const HomePage()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Seoul'), findsWidgets);
    expect(find.text('LEDGER INDEX'), findsOneWidget);
  });
}
