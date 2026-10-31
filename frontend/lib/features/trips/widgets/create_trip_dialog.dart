import 'package:flutter/material.dart';
import '../../../core/api/travel_api_client.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class CreateTripDialog {
  static Future<Trip?> show(BuildContext context, City city) async {
    final titleCtrl = TextEditingController(text: '${city.name} Highlights Tour');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final startCtrl = TextEditingController(text: today);
    final endCtrl = TextEditingController(text: today);

    return showDialog<Trip?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Trip', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Trip Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)', border: OutlineInputBorder()),
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
              final start = DateTime.tryParse(startCtrl.text.trim());
              final end = DateTime.tryParse(endCtrl.text.trim());
              if (titleCtrl.text.trim().isEmpty ||
                  start == null ||
                  end == null ||
                  end.isBefore(start) ||
                  end.difference(start).inDays > 365) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Enter a trip name and valid dates within 365 days.')),
                );
                return;
              }
              final newTrip = Trip(
                id: '',
                title: titleCtrl.text.trim(),
                countryCode: city.countryCode,
                cityId: city.id,
                cityName: city.name,
                startDate: startCtrl.text.trim(),
                endDate: endCtrl.text.trim(),
                days: [],
                collaborators: [],
              );
              final created = await TravelApiClient.createTrip(newTrip);
              if (ctx.mounted) {
                Navigator.pop(ctx, created);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

