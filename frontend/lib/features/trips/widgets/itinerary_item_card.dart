import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class ItineraryItemCard extends StatelessWidget {
  final ItineraryItem item;
  final bool busy;
  final ValueChanged<bool> onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onMove;

  const ItineraryItemCard({
    super.key,
    required this.item,
    required this.busy,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Order Indicator
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.timeScheduled,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.durationMin}m',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.routeFromPrevious != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'From previous stop: ${item.routeFromPrevious!.summary}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accent),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Checkbox(
                          value: item.isCompleted,
                          onChanged: busy ? null : (val) => onComplete(val ?? false),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Activity actions',
                          enabled: !busy,
                          onSelected: (action) {
                            if (action == 'edit') onEdit();
                            if (action == 'delete') onDelete();
                            if (action == 'up') onMove(-1);
                            if (action == 'down') onMove(1);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit activity')),
                            PopupMenuItem(value: 'up', child: Text('Move earlier')),
                            PopupMenuItem(value: 'down', child: Text('Move later')),
                            PopupMenuItem(value: 'delete', child: Text('Delete activity')),
                          ],
                        ),
                      ],
                    ),
                    Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${item.notes}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

