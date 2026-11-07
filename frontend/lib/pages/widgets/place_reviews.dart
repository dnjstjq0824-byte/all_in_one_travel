import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/explore/widgets/place_review_card.dart';

/// Place review thread with a write-review entry point.
class PlaceReviews extends StatelessWidget {
  final List<Review> reviews;
  final bool loading;
  final VoidCallback onWrite;

  const PlaceReviews({
    super.key,
    required this.reviews,
    required this.loading,
    required this.onWrite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppLocale.tr('reviews')} (${reviews.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: onWrite,
              icon: const Icon(Icons.rate_review, size: 18),
              label: Text(AppLocale.tr('write_review')),
            ),
          ],
        ),
        const SizedBox(height: LedgerTokens.s8),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          const Text(
            'No reviews yet. Be the first to share.',
            style: TextStyle(color: LedgerTokens.inkFaint),
          )
        else
          for (final r in reviews) PlaceReviewCard(review: r),
      ],
    );
  }
}
