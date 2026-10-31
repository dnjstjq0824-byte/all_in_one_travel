import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/models/travel_models.dart';
import '../core/theme/app_theme.dart';

class DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final City? currentCity;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.currentCity,
  });

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1,
              ),
            ),
          ),
          ...List.generate(navItems.length, (idx) {
            final isSel = currentIndex == idx;
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
                leading: Icon(
                  isSel ? item.$2 : item.$1,
                  color: isSel ? AppTheme.accent : AppTheme.textMuted,
                ),
                title: Text(
                  item.$3,
                  style: TextStyle(
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? AppTheme.accent : AppTheme.textMain,
                    fontSize: 14,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () => onSelectTab(idx),
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
                      '${currentCity?.name} Active',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentCity?.coverageLevel ?? "LEVEL_A"} Certified',
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
}

class TabletNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  const TabletNavRail({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelectTab,
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

