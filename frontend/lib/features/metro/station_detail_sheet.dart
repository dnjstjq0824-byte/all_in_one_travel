import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';

class StationDetailSheet extends StatelessWidget {
  final MetroStation station;
  final List<MetroLine> allLines;
  final VoidCallback? onSetAsOrigin;
  final VoidCallback? onSetAsDestination;

  const StationDetailSheet({
    super.key,
    required this.station,
    required this.allLines,
    this.onSetAsOrigin,
    this.onSetAsDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Station Title & Lines
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                    ),
                    Text(
                      '${station.englishName} • Code ${station.code}',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              // Accessibility chips
              if (station.elevatorAccessible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.elevator, size: 16, color: AppTheme.accent),
                      SizedBox(width: 4),
                      Text('Elevator', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Lines passing through
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: station.lines.map((lineId) {
              final line = allLines.firstWhere((l) => l.id == lineId, orElse: () => MetroLine(
                id: lineId, cityId: station.cityId, lineNumber: lineId, name: lineId,
                englishName: lineId, colorHex: '#0052A4', textColorHex: '#FFFFFF',
                stationIds: [], isCircular: false, operatingHours: '',
              ));
              final c = _parseColor(line.colorHex);
              return Chip(
                backgroundColor: c,
                label: Text(
                  line.name,
                  style: TextStyle(
                    color: _parseColor(line.textColorHex),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Operating hours & First/Last train
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCol('First Train', station.firstTrain.isNotEmpty ? station.firstTrain : '05:30', Icons.wb_sunny_outlined),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                _buildInfoCol('Last Train', station.lastTrain.isNotEmpty ? station.lastTrain : '24:00', Icons.nightlight_round_outlined),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                _buildInfoCol('Wheelchair', station.wheelchairBoarding ? 'Supported' : 'Standard', Icons.accessible),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Exits section
          if (station.exits.isNotEmpty) ...[
            const Text('Station Exits & Landmarks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: station.exits.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final ex = station.exits[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exit ${ex.exitNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accent)),
                        Text(ex.destinations.join(', '), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSetAsOrigin,
                  icon: const Icon(Icons.trip_origin, size: 18),
                  label: const Text('From Here'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSetAsDestination,
                  icon: const Icon(Icons.place, size: 18, color: Colors.white),
                  label: const Text('To Here', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppTheme.accent;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return AppTheme.accent;
  }
}
