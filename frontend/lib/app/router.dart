import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/travel_models.dart';
import '../pages/arrivals_page.dart';
import '../pages/cities_page.dart';
import '../pages/coverage_page.dart';
import '../pages/explore_page.dart';
import '../pages/home_page.dart';
import '../pages/map_page.dart';
import '../pages/metro_page.dart';
import '../pages/not_found_page.dart';
import '../pages/offline_page.dart';
import '../pages/place_detail_page.dart';
import '../pages/transit_page.dart';
import '../pages/trips_page.dart';
import '../shell/app_shell.dart';
import 'routes.dart';

/// One route renders exactly one page — no merged multi-section screens.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: buildRouteTable(),
  );
}

/// Exposed for tests: the full route table without a router instance.
List<RouteBase> buildRouteTable() {
  return [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (c, s) => _page(const HomePage(), s),
          ),
          GoRoute(
            path: Routes.cities,
            pageBuilder: (c, s) => _page(const CitiesPage(), s),
          ),
          GoRoute(
            path: Routes.map,
            pageBuilder: (c, s) => _page(const MapPage(), s),
          ),
          GoRoute(
            path: Routes.transit,
            pageBuilder: (c, s) {
              final extra = s.extra;
              return _page(
                TransitPage(
                  initialTarget: extra is Place ? extra : null,
                ),
                s,
              );
            },
          ),
          GoRoute(
            path: Routes.arrivals,
            pageBuilder: (c, s) => _page(const ArrivalsPage(), s),
          ),
          GoRoute(
            path: Routes.metro,
            pageBuilder: (c, s) => _page(const MetroPage(), s),
          ),
          GoRoute(
            path: Routes.explore,
            pageBuilder: (c, s) => _page(const ExplorePage(), s),
          ),
          GoRoute(
            path: '${Routes.place}/:placeId',
            pageBuilder: (c, s) {
              final placeId = s.pathParameters['placeId'] ?? '';
              final cityId = s.uri.queryParameters['cityId'] ?? '';
              final extra = s.extra;
              return _page(
                PlaceDetailPage(
                  placeId: placeId,
                  cityId: cityId,
                  initialPlace: extra is Place ? extra : null,
                ),
                s,
              );
            },
          ),
          GoRoute(
            path: Routes.trips,
            pageBuilder: (c, s) => _page(const TripsPage(), s),
          ),
          GoRoute(
            path: Routes.offline,
            pageBuilder: (c, s) => _page(const OfflinePage(), s),
          ),
          GoRoute(
            path: Routes.coverage,
            pageBuilder: (c, s) => _page(const CoveragePage(), s),
          ),
        ],
      ),
    ];
}

CustomTransitionPage<void> _page(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
