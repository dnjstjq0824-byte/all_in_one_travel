import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';

/// Metro toolbar: view-mode switch plus line filter chips.
class MetroToolbar extends StatelessWidget {
  final City city;
  final MetroViewMode mode;
  final ValueChanged<MetroViewMode> onMode;
  final List<MetroLine> lines;
  final String? lineId;
  final ValueChanged<String?> onLine;

  const MetroToolbar({
    super.key,
    required this.city,
    required this.mode,
    required this.onMode,
    required this.lines,
    required this.lineId,
    required this.onLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LedgerTokens.s12),
      decoration: const BoxDecoration(
        color: LedgerTokens.paper,
        border: Border(
          bottom: BorderSide(color: LedgerTokens.ledgerLine),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${city.name} ${AppLocale.tr('metro_network')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SegmentedButton<MetroViewMode>(
                segments: [
                  ButtonSegment(
                    value: MetroViewMode.schematic,
                    label: Text(
                      AppLocale.tr('schematic_view'),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  ButtonSegment(
                    value: MetroViewMode.geographic,
                    label: Text(
                      AppLocale.tr('geographic_view'),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
                selected: {mode},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onMode(s.first),
              ),
            ],
          ),
          if (lines.isNotEmpty) ...[
            const SizedBox(height: LedgerTokens.s8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text(
                      'All',
                      style: TextStyle(fontSize: 12),
                    ),
                    selected: lineId == null,
                    onSelected: (_) => onLine(null),
                  ),
                  const SizedBox(width: LedgerTokens.s8),
                  for (final l in lines) ...[
                    FilterChip(
                      label: Text(
                        l.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: lineId == l.id
                              ? Colors.white
                              : LedgerTokens.ink,
                        ),
                      ),
                      selected: lineId == l.id,
                      selectedColor: _parse(l.colorHex),
                      backgroundColor:
                          _parse(l.colorHex).withValues(alpha: 0.15),
                      onSelected: (v) => onLine(v ? l.id : null),
                    ),
                    const SizedBox(width: LedgerTokens.s8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _parse(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('0xFF$clean'));
    return LedgerTokens.signal;
  }
}
