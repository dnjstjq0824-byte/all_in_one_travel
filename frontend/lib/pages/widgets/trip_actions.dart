import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/api/travel_api_client.dart';
import '../../core/models/travel_models.dart';

/// Shared place actions: route planning handoff and trip capture.
///
/// Same behavior as the previous tab shell — add to Day 1 of the first
/// trip — now expressed as navigation instead of tab switching.
class TripActions {
  TripActions._();

  static void planRoute(BuildContext context, Place place) {
    context.go(Routes.transit, extra: place);
  }

  static Future<void> addToTrip(BuildContext context, Place place) async {
    final trips = await TravelApiClient.fetchTrips();
    if (!context.mounted) return;

    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a trip first on the Trips page.'),
        ),
      );
      return;
    }

    final target = trips.first;
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

    final updated =
        await TravelApiClient.addItineraryItem(target.id, 1, item);
    if (updated != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added "${place.name}" to Day 1 of "${target.title}".',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => context.go(Routes.trips),
          ),
        ),
      );
    }
  }
}
