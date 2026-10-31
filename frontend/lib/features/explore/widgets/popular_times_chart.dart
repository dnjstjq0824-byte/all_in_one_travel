import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class PopularTimesChart extends StatelessWidget {
  final Place place;

  const PopularTimesChart({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: AppTheme.accent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Popular Times & Visitor Density',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.red),
                      SizedBox(width: 4),
                      Text('14:00 Peak', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bar Chart Area
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: place.popularTimes.map((pt) {
                  final isCurrentPeak = pt.hour == 14;
                  final heightRatio = (pt.popularity / 100.0).clamp(0.1, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: '${pt.hour}:00 - ${pt.popularity}% busy',
                            child: Container(
                              height: 50 * heightRatio,
                              decoration: BoxDecoration(
                                color: isCurrentPeak
                                    ? Colors.orange.shade600
                                    : (pt.popularity > 70 ? AppTheme.accent : Colors.blue.shade100),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pt.hour % 3 == 0 ? '${pt.hour}' : '·',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: pt.hour % 3 == 0 ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentPeak ? Colors.orange.shade800 : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Tip Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tips_and_updates, size: 16, color: AppTheme.accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Best time to visit: Before 11:00 AM or after 17:00 for minimal crowd.',
                      style: TextStyle(fontSize: 12, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

