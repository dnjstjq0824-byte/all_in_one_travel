import 'package:flutter/material.dart';

import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';

/// One city governance card with its capability matrix.
class CoverageCard extends StatelessWidget {
  final City city;
  final CoverageRegistry? coverage;

  const CoverageCard({
    super.key,
    required this.city,
    required this.coverage,
  });

  @override
  Widget build(BuildContext context) {
    final cov = coverage;
    final badge = switch (city.coverageLevel) {
      'LEVEL_A' => LedgerTokens.moss,
      'LEVEL_B' => LedgerTokens.signal,
      'LEVEL_C' => LedgerTokens.brass,
      _ => LedgerTokens.inkFaint,
    };
    return Container(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      decoration: LedgerTokens.ledgerCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${city.name} (${city.countryCode})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LedgerTokens.s8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badge.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  city.coverageLevel,
                  style: TextStyle(
                    color: badge,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LedgerTokens.s4),
          Text(
            city.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: LedgerTokens.inkFaint,
            ),
          ),
          const SizedBox(height: LedgerTokens.s12),
          if (cov != null) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _badge('Metro Map', cov.metroMapAvailable),
                _badge('Metro Route', cov.metroRoutesAvailable),
                _badge('Bus Route', cov.busRoutesAvailable),
                _badge('Schedule', cov.scheduleAvailable),
                _badge('Realtime', cov.realtimeAvailable),
                _badge('Fares', cov.faresAvailable),
                _badge('Access', cov.accessibilityAvailable),
              ],
            ),
            const Divider(height: LedgerTokens.s24),
            Text(
              'Provider: ${cov.officialDataProvider}\n'
              'License: ${cov.dataLicense}',
              style: const TextStyle(
                fontSize: 11,
                color: LedgerTokens.inkFaint,
                height: 1.4,
              ),
            ),
            const SizedBox(height: LedgerTokens.s4),
            Text(
              '${cov.validationStatus} · ${cov.dataFreshnessMinutes}m sync',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else
            const Text(
              'Connecting to registry…',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: LedgerTokens.inkFaint,
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, bool on) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: on ? LedgerTokens.mossWash : LedgerTokens.fog,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: on ? LedgerTokens.moss : LedgerTokens.ledgerLine,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            on ? Icons.check : Icons.close,
            size: 10,
            color: on ? LedgerTokens.moss : LedgerTokens.inkFaint,
          ),
          const SizedBox(width: LedgerTokens.s4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: on ? LedgerTokens.moss : LedgerTokens.inkFaint,
            ),
          ),
        ],
      ),
    );
  }
}
