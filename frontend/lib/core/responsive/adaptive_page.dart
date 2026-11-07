import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'devices.dart';

/// Page scaffold that rebuilds per device class.
///
/// Each page supplies device-specific builders so tablet/PC get genuinely
/// redesigned layouts (rail, columns, side ledgers) instead of a stretched
/// phone column. Pane-local [LayoutBuilder] widths drive the decision, with
/// [MediaQuery] as the outer source.
class AdaptivePage extends StatelessWidget {
  final Widget Function(BuildContext context)? app;
  final Widget Function(BuildContext context)? mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) pc;
  final Widget Function(BuildContext context)? compactFallback;

  const AdaptivePage({
    super.key,
    this.app,
    this.mobile,
    this.tablet,
    required this.pc,
    this.compactFallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kind = deviceOfWidth(
          constraints.maxWidth,
          isWeb: kIsWeb,
        );
        switch (kind) {
          case DeviceKind.pc:
            return pc(context);
          case DeviceKind.tablet:
            if (tablet != null) return tablet!(context);
            return pc(context);
          case DeviceKind.mobile:
            if (mobile != null) return mobile!(context);
            return _fallback(context);
          case DeviceKind.app:
            if (app != null) return app!(context);
            if (mobile != null) return mobile!(context);
            return _fallback(context);
        }
      },
    );
  }

  Widget _fallback(BuildContext context) {
    if (compactFallback != null) return compactFallback!(context);
    return pc(context);
  }
}

/// Centers content with a device-appropriate reading measure.
class LedgerMeasure extends StatelessWidget {
  final Widget child;
  final double narrow;
  final double medium;
  final double wide;

  const LedgerMeasure({
    super.key,
    required this.child,
    this.narrow = Breakpoints.maxNarrow,
    this.medium = Breakpoints.maxMedium,
    this.wide = Breakpoints.maxWide,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kind = deviceOfWidth(
          constraints.maxWidth,
          isWeb: kIsWeb,
        );
        final max = switch (kind) {
          DeviceKind.pc =>
            constraints.maxWidth >= Breakpoints.wide ? wide : medium,
          DeviceKind.tablet => medium,
          DeviceKind.mobile || DeviceKind.app => narrow,
        };
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: max),
            child: child,
          ),
        );
      },
    );
  }
}

/// Hairline ledger divider with optional section label.
class LedgerRule extends StatelessWidget {
  final String? label;

  const LedgerRule({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Divider(height: 1);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LedgerTokens.s8),
      child: Row(
        children: [
          Text(label!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: LedgerTokens.s12),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}
