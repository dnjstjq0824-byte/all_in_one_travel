import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_travel_app/core/models/travel_models.dart';
import 'package:global_travel_app/features/metro/metro_map_screen.dart';
import 'package:global_travel_app/features/transit/transit_planner_screen.dart';
import 'package:global_travel_app/features/explore/explore_screen.dart';
import 'package:global_travel_app/features/trips/my_trip_screen.dart';

class _FakeHttpOverrides extends HttpOverrides {
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) => '';
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  final testCity = City(
    id: 'seoul', countryCode: 'KR', name: 'Seoul', englishName: 'Seoul', localName: '서울',
    latitude: 37.5665, longitude: 126.9780, timezone: 'Asia/Seoul',
    coverageLevel: 'LEVEL_A', transportModes: ['METRO', 'BUS', 'WALK'],
    description: 'Capital of South Korea', heroImageUrl: '',
  );

  testWidgets('Metro Map Screen rendering and schematic/geo toggle test', (WidgetTester tester) async {
    final lines = [
      MetroLine(
        id: 'kr_seoul_l1', cityId: 'seoul', lineNumber: '1', name: '1호선',
        englishName: 'Line 1', colorHex: '#0052A4', textColorHex: '#FFFFFF',
        stationIds: ['kr_sel_seoul_stn'], isCircular: false, operatingHours: '05:30 - 24:00',
      ),
    ];
    final stations = [
      MetroStation(
        id: 'kr_sel_seoul_stn', cityId: 'seoul', code: '133', name: '서울역',
        englishName: 'Seoul Station', localName: '서울역', latitude: 37.5559, longitude: 126.9723,
        schematicX: 200, schematicY: 300, lines: ['kr_seoul_l1'], exits: [],
        elevatorAccessible: true, wheelchairBoarding: true, firstTrain: '05:12', lastTrain: '23:58',
        nearbyBusStopIds: [], nearbyPlaceIds: [],
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: MetroMapScreen(city: testCity, lines: lines, stations: stations),
    ));
    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(SegmentedButton<MetroViewMode>), findsOneWidget);
  });

  testWidgets('Transit Planner screen rendering test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TransitPlannerScreen(currentCity: testCity),
    ));
    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('Explore screen rendering test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ExploreScreen(currentCity: testCity),
    ));
    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(ChoiceChip), findsWidgets);
  });

  testWidgets('My Trip screen rendering test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyTripScreen(currentCity: testCity),
    ));
    await tester.pump(const Duration(seconds: 5));

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
