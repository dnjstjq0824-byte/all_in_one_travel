import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/design_tokens.dart';

/// Trips page chrome: title header and the offline handoff link.
class TripsChrome {
  TripsChrome._();

  static Widget header(
    BuildContext context, {
    required int count,
    required VoidCallback onCreate,
  }) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocale.tr('tab_my_trip'), style: text.titleLarge),
                Text('$count itineraries', style: text.bodySmall),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Trip'),
          ),
        ],
      ),
    );
  }

  static Widget offlineLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      child: InkWell(
        onTap: () => context.go(Routes.offline),
        borderRadius: LedgerTokens.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(LedgerTokens.s12),
          decoration: BoxDecoration(
            color: LedgerTokens.fog,
            borderRadius: LedgerTokens.cardRadius,
            border: Border.all(color: LedgerTokens.ledgerLine),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.download_outlined,
                color: LedgerTokens.inkSoft,
              ),
              const SizedBox(width: LedgerTokens.s12),
              Expanded(
                child: Text(
                  AppLocale.tr('offline_package'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
