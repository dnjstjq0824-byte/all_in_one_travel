import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class TransitLegRow extends StatelessWidget {
  final TransitLeg leg;

  const TransitLegRow({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (leg.type == 'METRO') {
      icon = Icons.subway;
      color = leg.lineColorHex != null ? _parseColor(leg.lineColorHex!) : AppTheme.accent;
    } else if (leg.type == 'BUS') {
      icon = Icons.directions_bus;
      color = Colors.indigo;
    } else {
      icon = Icons.directions_walk;
      color = AppTheme.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leg.instruction,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${leg.fromStationName} ➔ ${leg.toStationName} (${leg.durationMinutes} min)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                if (leg.fastTransferDoor != null && leg.fastTransferDoor!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.transfer_within_a_station, size: 13, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          leg.fastTransferDoor!,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return AppTheme.accent;
  }
}

