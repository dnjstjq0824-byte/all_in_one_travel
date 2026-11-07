import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';

/// Coverage registry header: title, governance note, level tallies.
class CoverageHeader extends StatelessWidget {
  final List<City> cities;
  final VoidCallback onRefresh;

  const CoverageHeader({
    super.key,
    required this.cities,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final counts = <String, int>{};
    for (final c in cities) {
      counts[c.coverageLevel] = (counts[c.coverageLevel] ?? 0) + 1;
    }
    return Container(
      padding: const EdgeInsets.all(LedgerTokens.s24),
      decoration: LedgerTokens.nightBoard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocale.tr('admin_console'),
                  style: text.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF9FB0A6),
                ),
              ),
            ],
          ),
          const Text(
            'Governance: realtime and schedules surface only where '
            'licensed and verified.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9FB0A6),
            ),
          ),
          const SizedBox(height: LedgerTokens.s12),
          Wrap(
            spacing: LedgerTokens.s16,
            runSpacing: LedgerTokens.s8,
            children: [
              for (final e in counts.entries)
                _stat(e.key.replaceFirst('LEVEL_', 'L'), '${e.value}'),
              _stat('CITIES', '${cities.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: LedgerTokens.tabular(
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9FB0A6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Level filter chip row shared by all device layouts.
class CoverageFilters extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const CoverageFilters({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in filters) ...[
            ChoiceChip(
              label: Text(
                f == 'ALL' ? 'All' : f.replaceFirst('LEVEL_', 'Level '),
                style: const TextStyle(fontSize: 12),
              ),
              selected: selected == f,
              selectedColor: LedgerTokens.signal,
              labelStyle: TextStyle(
                color: selected == f ? Colors.white : LedgerTokens.ink,
                fontWeight: selected == f
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
              onSelected: (_) => onSelect(f),
            ),
            const SizedBox(width: LedgerTokens.s8),
          ],
        ],
      ),
    );
  }
}
