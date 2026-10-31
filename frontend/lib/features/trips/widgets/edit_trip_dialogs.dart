import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';

class EditTripDialog {
  static Future<Map<String, dynamic>?> show(BuildContext context, Trip trip) {
    var title = trip.title;
    var start = trip.startDate;
    var end = trip.endDate;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit trip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: 'Trip name'),
              ),
              TextFormField(
                initialValue: start,
                onChanged: (value) => start = value,
                decoration: const InputDecoration(labelText: 'Start date (YYYY-MM-DD)'),
              ),
              TextFormField(
                initialValue: end,
                onChanged: (value) => end = value,
                decoration: const InputDecoration(labelText: 'End date (YYYY-MM-DD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, {
                'title': title.trim(),
                'start_date': start.trim(),
                'end_date': end.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class EditItemDialog {
  static Future<Map<String, dynamic>?> show(BuildContext context, ItineraryItem item) {
    var title = item.title;
    var time = item.timeScheduled;
    var duration = item.durationMin.toString();
    var notes = item.notes ?? '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: 'Activity name'),
              ),
              TextFormField(
                initialValue: time,
                onChanged: (value) => time = value,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
              ),
              TextFormField(
                initialValue: duration,
                onChanged: (value) => duration = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
              TextFormField(
                initialValue: notes,
                onChanged: (value) => notes = value,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(duration);
              if (title.trim().isEmpty || minutes == null || minutes < 0 || minutes > 1440) {
                return;
              }
              Navigator.pop(ctx, {
                'title': title.trim(),
                'time_scheduled': time.trim(),
                'duration_min': minutes,
                'notes': notes,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

