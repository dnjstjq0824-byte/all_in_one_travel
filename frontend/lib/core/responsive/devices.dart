import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Four device classes for layout redesign (never mere scaling).
///
/// Widths follow [MediaQuery]/[LayoutBuilder] measurements:
/// app + mobile share the compact window but differ in chrome
/// (native app shell vs mobile browser), tablet uses a rail,
/// PC uses a full sidebar with multi-column content.
enum DeviceKind { app, mobile, tablet, pc }

class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;
  static const double pc = 1000;
  static const double wide = 1440;

  static const double maxNarrow = 720;
  static const double maxMedium = 1080;
  static const double maxWide = 1320;
}

/// Resolves the device class from the current window.
///
/// Must be called with a [MediaQuery] ancestor; pages additionally wrap
/// content in [LayoutBuilder] so embedded panes re-resolve on their own
/// constraints instead of the full window.
DeviceKind deviceOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.pc) return DeviceKind.pc;
  if (width >= Breakpoints.tablet) return DeviceKind.tablet;
  if (!kIsWeb) return DeviceKind.app;
  return DeviceKind.mobile;
}

/// Resolves the device class from layout constraints (pane-local).
DeviceKind deviceOfWidth(double width, {required bool isWeb}) {
  if (width >= Breakpoints.pc) return DeviceKind.pc;
  if (width >= Breakpoints.tablet) return DeviceKind.tablet;
  return isWeb ? DeviceKind.mobile : DeviceKind.app;
}

extension DeviceKindX on DeviceKind {
  bool get isCompact =>
      this == DeviceKind.app || this == DeviceKind.mobile;
  bool get isExpanded => this == DeviceKind.pc;
}
