import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/theme/design_tokens.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '404',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              color: LedgerTokens.ink,
            ),
          ),
          const Text(
            'This ledger page does not exist.',
            style: TextStyle(color: LedgerTokens.inkSoft),
          ),
          const SizedBox(height: LedgerTokens.s16),
          ElevatedButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
