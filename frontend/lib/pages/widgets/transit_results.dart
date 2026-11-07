import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/transit/widgets/transit_route_card.dart';

/// Transit result list and the handoff link to live arrivals.
class TransitResults {
  TransitResults._();

  static Widget list(
    BuildContext context,
    City city, {
    required bool calculating,
    required List<RouteOption> options,
  }) {
    if (calculating) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No transit paths between these locations in ${city.name}.',
            style: const TextStyle(color: LedgerTokens.inkFaint),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LedgerTokens.s16,
            vertical: LedgerTokens.s8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Routes (${options.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                city.coverageLevel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: LedgerTokens.signal,
                ),
              ),
            ],
          ),
        ),
        for (final opt in options)
          TransitRouteCard(option: opt, isFirst: opt == options.first),
      ],
    );
  }

  static Widget arrivalsLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: InkWell(
        onTap: () => context.go(Routes.arrivals),
        borderRadius: LedgerTokens.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(LedgerTokens.s12),
          decoration: BoxDecoration(
            color: LedgerTokens.mossWash,
            borderRadius: LedgerTokens.cardRadius,
            border: Border.all(color: LedgerTokens.moss),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.directions_bus_outlined,
                color: LedgerTokens.moss,
              ),
              const SizedBox(width: LedgerTokens.s12),
              Expanded(
                child: Text(
                  AppLocale.tr('bus_arrivals'),
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
