import 'package:flutter/material.dart';

/// Single source of truth for UI routes: exactly one route per page.
///
/// Backend `/api/v1` contracts are untouched; these paths are Flutter-side
/// only and every page keeps the same API calls as its predecessor.
class Routes {
  Routes._();

  static const home = '/';
  static const cities = '/cities';
  static const map = '/map';
  static const transit = '/transit';
  static const arrivals = '/arrivals';
  static const metro = '/metro';
  static const explore = '/explore';
  static const place = '/place';
  static const trips = '/trips';
  static const offline = '/offline';
  static const coverage = '/admin/coverage';

  static String placeDetail(String placeId, String cityId) =>
      '$place/$placeId?cityId=$cityId';
}

/// Compact (mobile/app) primary destinations — the five daily actions.
class PrimaryDestinations {
  PrimaryDestinations._();

  static const paths = [
    Routes.home,
    Routes.map,
    Routes.transit,
    Routes.explore,
    Routes.trips,
  ];

  static int indexOf(String location) {
    for (var i = 0; i < paths.length; i++) {
      if (location == paths[i]) return i;
    }
    if (location.startsWith(Routes.place)) return 3;
    return 0;
  }
}

/// Full ledger index shown on PC sidebar and the home board.
class LedgerIndexEntry {
  final String path;
  final IconData icon;
  final String title;
  final String caption;

  const LedgerIndexEntry(this.path, this.icon, this.title, this.caption);
}

class LedgerIndex {
  LedgerIndex._();

  static const travel = [
    LedgerIndexEntry(
        Routes.home, Icons.departure_board, 'Home', 'Departure board'),
    LedgerIndexEntry(Routes.cities, Icons.public, 'Cities', '18 regions'),
    LedgerIndexEntry(Routes.map, Icons.map_outlined, 'Map', 'Live canvas'),
    LedgerIndexEntry(
        Routes.transit, Icons.route_outlined, 'Transit', 'Route planner'),
    LedgerIndexEntry(
        Routes.arrivals, Icons.directions_bus_outlined, 'Arrivals', 'Live bus'),
    LedgerIndexEntry(
        Routes.metro, Icons.subway_outlined, 'Metro', 'Schematic map'),
    LedgerIndexEntry(
        Routes.explore, Icons.explore_outlined, 'Explore', 'Attractions'),
    LedgerIndexEntry(
        Routes.trips, Icons.luggage_outlined, 'Trips', 'Itineraries'),
    LedgerIndexEntry(
        Routes.offline, Icons.download_outlined, 'Offline', 'Packages'),
  ];

  static const console = [
    LedgerIndexEntry(Routes.coverage, Icons.verified_user_outlined,
        'Coverage', 'Admin registry'),
  ];
}
