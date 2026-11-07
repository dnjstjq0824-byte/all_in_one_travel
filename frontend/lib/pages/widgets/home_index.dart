import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/theme/design_tokens.dart';

/// Timetable-style index rows linking to every ledger page.
class HomeIndex extends StatelessWidget {
  final int columns;

  const HomeIndex({super.key, this.columns = 1});

  @override
  Widget build(BuildContext context) {
    final entries = [...LedgerIndex.travel, ...LedgerIndex.console];
    if (columns <= 1) {
      return Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            _row(context, i + 1, entries[i]),
        ],
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 76,
        crossAxisSpacing: LedgerTokens.s12,
        mainAxisSpacing: LedgerTokens.s12,
      ),
      itemCount: entries.length,
      itemBuilder: (ctx, i) => _row(context, i + 1, entries[i]),
    );
  }

  Widget _row(BuildContext context, int no, LedgerIndexEntry e) {
    return InkWell(
      onTap: () => context.go(e.path),
      borderRadius: LedgerTokens.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LedgerTokens.s16,
          vertical: LedgerTokens.s12,
        ),
        decoration: LedgerTokens.ledgerCard,
        child: Row(
          children: [
            Text(
              no.toString().padLeft(2, '0'),
              style: LedgerTokens.tabular(
                const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: LedgerTokens.signal,
                ),
              ),
            ),
            const SizedBox(width: LedgerTokens.s12),
            Icon(e.icon, size: 20, color: LedgerTokens.inkSoft),
            const SizedBox(width: LedgerTokens.s12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    e.caption,
                    style: const TextStyle(
                      fontSize: 12,
                      color: LedgerTokens.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 17,
              color: LedgerTokens.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}
