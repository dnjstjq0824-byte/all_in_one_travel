import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/design_tokens.dart';

/// Compact navigation chrome for tablet rail and mobile/app bottom bar.
class CompactNav {
  CompactNav._();

  static List<(IconData, IconData, String)> destinations(BuildContext context) {
    return [
      (Icons.departure_board_outlined, Icons.departure_board,
          AppLocale.tr('tab_home')),
      (Icons.map_outlined, Icons.map, AppLocale.tr('tab_map')),
      (Icons.route_outlined, Icons.route, AppLocale.tr('tab_transit')),
      (Icons.explore_outlined, Icons.explore, AppLocale.tr('tab_explore')),
      (Icons.luggage_outlined, Icons.luggage, AppLocale.tr('tab_my_trip')),
    ];
  }

  static Widget rail(BuildContext context, String location) {
    final items = destinations(context);
    final index = PrimaryDestinations.indexOf(location);
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: (i) =>
          context.go(PrimaryDestinations.paths[i]),
      labelType: NavigationRailLabelType.selected,
      groupAlignment: 0,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: LedgerTokens.s16),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LedgerTokens.signal,
            borderRadius:
                BorderRadius.circular(LedgerTokens.radiusChip),
          ),
          child: const Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: LedgerTokens.s16),
            child: IconButton(
              tooltip: AppLocale.tr('admin_console'),
              icon: Icon(
                Icons.verified_user_outlined,
                color: location == Routes.coverage
                    ? LedgerTokens.signal
                    : LedgerTokens.inkFaint,
              ),
              onPressed: () => context.go(Routes.coverage),
            ),
          ),
        ),
      ),
      destinations: [
        for (final d in items)
          NavigationRailDestination(
            icon: Icon(d.$1),
            selectedIcon: Icon(d.$2),
            label: Text(d.$3),
          ),
      ],
    );
  }

  static Widget bottomBar(BuildContext context, String location) {
    final items = destinations(context);
    final index = PrimaryDestinations.indexOf(location);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => context.go(PrimaryDestinations.paths[i]),
            items: [
              for (final d in items)
                BottomNavigationBarItem(
                  icon: Icon(d.$1),
                  activeIcon: Icon(d.$2),
                  label: d.$3,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
