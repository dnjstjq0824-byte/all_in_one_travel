import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class BusArrivalCard extends StatelessWidget {
  final RealtimeArrival arrival;

  const BusArrivalCard({super.key, required this.arrival});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (arrival.status == 'LIVE') {
      statusColor = AppTheme.liveGreen;
    } else if (arrival.status == 'SCHEDULED') {
      statusColor = AppTheme.accent;
    } else {
      statusColor = AppTheme.warnAmber;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
          child: Text(
            arrival.routeNumber,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          'Towards ${arrival.destination}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Crowding: ${arrival.crowdingLevel} • ${arrival.stopsRemaining} stops away',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${arrival.minutesAway} min',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                arrival.status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

