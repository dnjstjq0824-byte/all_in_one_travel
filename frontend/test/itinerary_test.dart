import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:global_travel_app/core/api/travel_api_client.dart';
import 'package:global_travel_app/core/models/travel_models.dart';
import 'package:global_travel_app/features/trips/my_trip_screen.dart';

void main() {
  tearDown(() {
    TravelApiClient.clientOverride?.close();
    TravelApiClient.clientOverride = null;
    TravelApiClient.customBaseUrl = null;
  });

  testWidgets(
    'Activity reorder, edit, delete and trip delete update the timeline',
    (tester) async {
      var items = <Map<String, dynamic>>[
        {'id': 'a', 'title': 'First stop'},
        {'id': 'b', 'title': 'Second stop'},
      ];
      var deletedTrip = false;
      Map<String, dynamic> trip() => {
        'id': 'trip',
        'title': 'Editable trip',
        'start_date': '2026-11-01',
        'end_date': '2026-11-01',
        'days': [
          {'day_number': 1, 'date_str': '2026-11-01', 'items': items},
        ],
      };
      TravelApiClient.customBaseUrl = 'https://test.example/api/v1';
      TravelApiClient.clientOverride = MockClient((request) async {
        if (request.method == 'PUT') {
          final ids = (jsonDecode(request.body)['item_ids'] as List)
              .cast<String>();
          expect(ids, ['b', 'a']);
          items = ids
              .map((id) => items.firstWhere((item) => item['id'] == id))
              .toList();
          return http.Response(jsonEncode(trip()), 200);
        }
        if (request.method == 'PATCH') {
          final fields = jsonDecode(request.body) as Map<String, dynamic>;
          items[0] = {...items[0], ...fields};
          return http.Response(jsonEncode(trip()), 200);
        }
        if (request.method == 'DELETE' &&
            request.url.path.endsWith('/items/b')) {
          items.removeWhere((item) => item['id'] == 'b');
          return http.Response(jsonEncode(trip()), 200);
        }
        if (request.method == 'DELETE') {
          deletedTrip = true;
          return http.Response('', 204);
        }
        if (request.url.path.endsWith('/trips')) {
          return http.Response(jsonEncode([trip()]), 200);
        }
        return http.Response('[]', 200);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: MyTripScreen(currentCity: City.fromJson({'id': 'seoul'})),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Activity actions').first);
      await tester.tap(find.byTooltip('Activity actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move later'));
      await tester.pumpAndSettle();
      expect(items.first['id'], 'b');
      await tester.ensureVisible(find.byTooltip('Activity actions').first);
      await tester.tap(find.byTooltip('Activity actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit activity'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Updated stop');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Updated stop'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Activity actions').first);
      await tester.tap(find.byTooltip('Activity actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Updated stop'), findsNothing);
      expect(find.text('First stop'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Trip actions'));
      await tester.tap(find.byTooltip('Trip actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete trip'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(deletedTrip, isTrue);
      expect(find.text('No travel itineraries yet.'), findsOneWidget);
    },
  );

  testWidgets('Day rain warning and completion persist through the API', (
    tester,
  ) async {
    var completed = false;
    Map<String, dynamic> trip() => {
      'id': 'trip',
      'title': 'Weekend',
      'city_id': 'seoul',
      'city_name': 'Seoul',
      'start_date': '2026-11-01',
      'end_date': '2026-11-01',
      'days': [
        {
          'day_number': 1,
          'date_str': '2026-11-01',
          'city_id': 'seoul',
          'day_weather': {
            'condition': 'Rain',
            'temp_max_c': 15,
            'temp_min_c': 10,
            'precip_prob': 80,
            'rain_alert': true,
            'indoor_tip': 'Consider a museum.',
          },
          'items': [
            {
              'id': 'item',
              'title': 'Museum stop',
              'subtitle': 'Gallery',
              'is_completed': completed,
              'route_from_previous': {
                'id': 'walk',
                'summary': 'Walk 5 min',
                'total_minutes': 5,
                'walk_minutes': 5,
                'transfers': 0,
                'legs': [],
              },
            },
          ],
        },
      ],
    };
    TravelApiClient.customBaseUrl = 'https://test.example/api/v1';
    TravelApiClient.clientOverride = MockClient((request) async {
      if (request.method == 'PATCH') {
        expect(request.url.path, '/api/v1/trips/trip/items/item');
        completed = jsonDecode(request.body)['is_completed'] as bool;
        return http.Response(jsonEncode(trip()), 200);
      }
      if (request.url.path.endsWith('/trips')) {
        return http.Response(jsonEncode([trip()]), 200);
      }
      return http.Response('[]', 200);
    });
    final city = City.fromJson({'id': 'seoul', 'name': 'Seoul'});
    await tester.pumpWidget(MaterialApp(home: MyTripScreen(currentCity: city)));
    await tester.pumpAndSettle();
    expect(find.text('Consider a museum.'), findsOneWidget);
    expect(find.textContaining('Rain 80%'), findsOneWidget);
    expect(find.text('From previous stop: Walk 5 min'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('Failed completion keeps the old state and shows an error', (
    tester,
  ) async {
    TravelApiClient.customBaseUrl = 'https://test.example/api/v1';
    TravelApiClient.clientOverride = MockClient((request) async {
      if (request.method == 'PATCH') return http.Response('{}', 500);
      if (request.url.path.endsWith('/trips')) {
        return http.Response(
          jsonEncode([
            {
              'id': 'trip',
              'title': 'Trip',
              'days': [
                {
                  'day_number': 1,
                  'date_str': '2026-11-01',
                  'items': [
                    {'id': 'item', 'title': 'Stop'},
                  ],
                },
              ],
            },
          ]),
          200,
        );
      }
      return http.Response('[]', 200);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: MyTripScreen(currentCity: City.fromJson({'id': 'seoul'})),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Forecast unavailable for this date'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(
      find.text('Could not save completion. Please try again.'),
      findsOneWidget,
    );
  });
}
