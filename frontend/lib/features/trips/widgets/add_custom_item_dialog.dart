import 'package:flutter/material.dart';
import '../../../core/api/travel_api_client.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class AddCustomItemDialog {
  static Future<Trip?> show(
    BuildContext context, {
    required Trip trip,
    required int dayNumber,
    required City city,
  }) async {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '14:00');
    final notesCtrl = TextEditingController();

    return showDialog<Trip?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Stop to Day', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Stop / Activity Name',
                hintText: 'e.g. Afternoon Tea or Museum',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final newItem = ItineraryItem(
                id: '',
                title: titleCtrl.text.trim(),
                subtitle: 'Custom Activity',
                category: 'Activity',
                order: 1,
                timeScheduled: timeCtrl.text.trim(),
                latitude: city.latitude,
                longitude: city.longitude,
                durationMin: 60,
                notes: notesCtrl.text.trim(),
                isCompleted: false,
              );
              final updated = await TravelApiClient.addItineraryItem(
                trip.id,
                dayNumber,
                newItem,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx, updated);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

