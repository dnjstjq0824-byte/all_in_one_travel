import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import 'transit_leg_row.dart';

class TransitRouteCard extends StatelessWidget {
  final RouteOption option;
  final bool isFirst;

  const TransitRouteCard({
    super.key,
    required this.option,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ExpansionTile(
        initiallyExpanded: isFirst,
        title: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${option.totalMinutes} min',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${option.walkMinutes} min walk',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${option.transfers} transfers',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
            Text(
              option.estimatedFare,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textMain,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            option.summary,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (option.accessibilityNote != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      option.accessibilityNote!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                ...option.legs.map((leg) => TransitLegRow(leg: leg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

