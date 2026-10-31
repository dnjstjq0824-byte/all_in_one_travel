import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../metro/metro_map_screen.dart';

class HomeQuickActions extends StatelessWidget {
  final City city;
  final List<MetroLine> metroLines;
  final List<MetroStation> metroStations;
  final ValueChanged<int> onNavigateTab;

  const HomeQuickActions({
    super.key,
    required this.city,
    required this.metroLines,
    required this.metroStations,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildAction(
            icon: Icons.subway,
            label: AppLocale.tr('metro_network'),
            color: const Color(0xFF0284C7),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => MetroMapScreen(
                    city: city,
                    lines: metroLines,
                    stations: metroStations,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildAction(
            icon: Icons.directions_bus,
            label: AppLocale.tr('bus_arrivals'),
            color: const Color(0xFF10B981),
            onTap: () => onNavigateTab(2),
          ),
          const SizedBox(width: 10),
          _buildAction(
            icon: Icons.alt_route,
            label: AppLocale.tr('tab_transit'),
            color: const Color(0xFF6366F1),
            onTap: () => onNavigateTab(2),
          ),
          const SizedBox(width: 10),
          _buildAction(
            icon: Icons.download_for_offline,
            label: 'Offline',
            color: const Color(0xFFF59E0B),
            onTap: () => onNavigateTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

