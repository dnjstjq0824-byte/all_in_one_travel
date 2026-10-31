import 'package:flutter/material.dart';
import '../../../core/api/travel_api_client.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class AddReviewDialog {
  static Future<Review?> show(BuildContext context, Place place) {
    int rating = 5;
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final tipCtrl = TextEditingController();
    String travelType = 'Solo';

    return showDialog<Review?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocale.tr('write_review'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                      onPressed: () => setDlgState(() => rating = star),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Review Title',
                    hintText: 'e.g. Unbelievable morning view!',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Experience',
                    hintText: 'Share transit tips, photo spots, and highlights...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Insider Tip (Optional)',
                    hintText: 'e.g. Arrive before 10 AM',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: travelType,
                  decoration: const InputDecoration(labelText: 'Travel Type', border: OutlineInputBorder()),
                  items: ['Solo', 'Couple', 'Family', 'Friends'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDlgState(() => travelType = v ?? 'Solo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              onPressed: () async {
                if (contentCtrl.text.trim().isEmpty) return;
                final newRev = Review(
                  id: '',
                  placeId: place.id,
                  authorName: 'Traveler',
                  rating: rating,
                  title: titleCtrl.text.trim().isEmpty ? 'Great Experience' : titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  visitPeriod: 'October 2026',
                  travelType: travelType,
                  visitTip: tipCtrl.text.trim(),
                  helpfulCount: 0,
                  verifiedVisit: false,
                  language: 'en',
                );
                final created = await TravelApiClient.submitReview(place.id, newRev);
                if (ctx.mounted) {
                  Navigator.pop(ctx, created);
                }
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

