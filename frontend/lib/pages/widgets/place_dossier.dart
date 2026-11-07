import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';
import 'trip_actions.dart';

/// Place dossier blocks: photo hero, heading and action row.
class PlaceDossier {
  PlaceDossier._();

  static const _fallbackPhoto =
      'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80';

  static Widget hero(Place p, double height) {
    return Stack(
      children: [
        Image.network(
          p.photoUrls.isNotEmpty ? p.photoUrls.first : _fallbackPhoto,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: height,
            color: LedgerTokens.night,
            alignment: Alignment.center,
            child: const Icon(
              Icons.place,
              size: 48,
              color: Colors.white24,
            ),
          ),
        ),
        Positioned(
          left: LedgerTokens.s16,
          bottom: LedgerTokens.s12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LedgerTokens.s8,
              vertical: LedgerTokens.s4,
            ),
            color: LedgerTokens.night,
            child: Text(
              p.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget heading(BuildContext context, Place p) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(p.name, style: text.titleLarge),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LedgerTokens.s8,
                vertical: LedgerTokens.s4,
              ),
              decoration: BoxDecoration(
                color: LedgerTokens.brassWash,
                borderRadius: BorderRadius.circular(
                  LedgerTokens.radiusChip,
                ),
              ),
              child: Text(
                '★ ${p.rating} (${p.reviewCount})',
                style: LedgerTokens.tabular(
                  const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: LedgerTokens.brass,
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          p.englishName,
          style: const TextStyle(
            fontSize: 14,
            color: LedgerTokens.inkFaint,
          ),
        ),
        const SizedBox(height: LedgerTokens.s8),
        Text(p.description, style: text.bodyLarge),
      ],
    );
  }

  static Widget actions(BuildContext context, Place p) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => TripActions.planRoute(context, p),
            icon: const Icon(Icons.directions, size: 18),
            label: Text(AppLocale.tr('start_route')),
          ),
        ),
        const SizedBox(width: LedgerTokens.s12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => TripActions.addToTrip(context, p),
            icon: const Icon(Icons.bookmark_add, size: 18),
            label: Text(AppLocale.tr('add_to_trip')),
          ),
        ),
      ],
    );
  }
}
