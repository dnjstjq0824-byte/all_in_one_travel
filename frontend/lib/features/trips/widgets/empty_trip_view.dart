import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmptyTripView extends StatelessWidget {
  final VoidCallback onCreateTrip;

  const EmptyTripView({super.key, required this.onCreateTrip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.luggage_outlined, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text('No travel itineraries yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Create your first trip or add destinations from Explore.', style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onCreateTrip,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Create Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}

