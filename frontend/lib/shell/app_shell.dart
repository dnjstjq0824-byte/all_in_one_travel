import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/responsive/devices.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import 'compact_nav.dart';
import 'ledger_topbar.dart';
import 'side_index.dart';

/// Root shell: masthead plus device-specific navigation chrome.
///
/// PC gets the full ledger sidebar, tablet a slim rail, mobile/app a
/// bottom bar. The routed page renders as [child] — the shell never merges
/// page content itself.
class AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    final session = CityScope.of(context);
    if (session.loading && session.current == null) {
      return const Scaffold(body: _LedgerSplash());
    }
    if (session.current == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: LedgerTokens.inkFaint,
              ),
              const SizedBox(height: LedgerTokens.s12),
              const Text(
                'Could not reach the travel registry.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: LedgerTokens.s8),
              ElevatedButton(
                onPressed: session.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final kind = deviceOfWidth(
          constraints.maxWidth,
          isWeb: kIsWeb,
        );
        switch (kind) {
          case DeviceKind.pc:
            return Scaffold(
              appBar: const LedgerTopBar(),
              body: Row(
                children: [
                  SideIndex(location: location),
                  Expanded(child: child),
                ],
              ),
            );
          case DeviceKind.tablet:
            return Scaffold(
              appBar: const LedgerTopBar(),
              body: Row(
                children: [
                  CompactNav.rail(context, location),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              ),
            );
          case DeviceKind.mobile:
          case DeviceKind.app:
            return Scaffold(
              appBar: const LedgerTopBar(),
              body: SafeArea(bottom: false, child: child),
              bottomNavigationBar:
                  CompactNav.bottomBar(context, location),
            );
        }
      },
    );
  }
}

class _LedgerSplash extends StatelessWidget {
  const _LedgerSplash();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SplashPlate(),
          SizedBox(height: LedgerTokens.s16),
          SizedBox(
            width: 180,
            child: LinearProgressIndicator(
              color: LedgerTokens.signal,
              backgroundColor: LedgerTokens.fogDeep,
            ),
          ),
          SizedBox(height: LedgerTokens.s12),
          Text(
            'Opening the travel ledger…',
            style: TextStyle(color: LedgerTokens.inkFaint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SplashPlate extends StatelessWidget {
  const _SplashPlate();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LedgerTokens.s24,
        vertical: LedgerTokens.s16,
      ),
      decoration: const BoxDecoration(
        color: LedgerTokens.night,
        borderRadius: LedgerTokens.cardRadius,
      ),
      child: const Column(
        children: [
          Text(
            'GLOBAL TRAVEL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ),
          Text(
            'ESSENTIAL LEDGER',
            style: TextStyle(
              color: LedgerTokens.signal,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
