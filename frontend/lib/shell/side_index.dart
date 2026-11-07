import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';

/// PC sidebar: full ledger index grouped into travel + console.
class SideIndex extends StatelessWidget {
  final String location;

  const SideIndex({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final city = CityScope.of(context).current;
    return Container(
      width: 236,
      decoration: const BoxDecoration(
        color: LedgerTokens.paper,
        border: Border(
          right: BorderSide(color: LedgerTokens.ledgerLine),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(LedgerTokens.s12),
              children: [
                _groupLabel(context, 'TRAVEL BOARD'),
                for (final e in LedgerIndex.travel)
                  _entry(context, e, location == e.path),
                const SizedBox(height: LedgerTokens.s16),
                _groupLabel(context, 'CONSOLE'),
                for (final e in LedgerIndex.console)
                  _entry(context, e, location == e.path),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(LedgerTokens.s12),
            padding: const EdgeInsets.all(LedgerTokens.s12),
            decoration: BoxDecoration(
              color: LedgerTokens.fog,
              borderRadius: LedgerTokens.cardRadius,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: LedgerTokens.moss,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: LedgerTokens.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${city?.name ?? '—'} active',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${city?.coverageLevel ?? ''} certified',
                        style: const TextStyle(
                          fontSize: 11,
                          color: LedgerTokens.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _entry(BuildContext context, LedgerIndexEntry e, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: selected ? LedgerTokens.signalWash : Colors.transparent,
        borderRadius: LedgerTokens.chipRadius,
        border: selected
            ? Border.all(color: LedgerTokens.signal.withValues(alpha: 0.35))
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          e.icon,
          size: 19,
          color: selected ? LedgerTokens.signal : LedgerTokens.inkSoft,
        ),
        title: Text(
          e.title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
            color: selected ? LedgerTokens.signalDeep : LedgerTokens.ink,
          ),
        ),
        subtitle: Text(
          e.caption,
          style: const TextStyle(
            fontSize: 11,
            color: LedgerTokens.inkFaint,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LedgerTokens.radiusChip),
        ),
        onTap: () => context.go(e.path),
      ),
    );
  }
}
