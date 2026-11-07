import 'package:flutter/material.dart';

/// "Departure Ledger" design tokens — editorial timetable identity.
///
/// Deliberately avoids gradient heroes, purple accents, glassmorphism and
/// single-radius-everywhere styling. One palette serves user pages and the
/// admin console.
class LedgerTokens {
  LedgerTokens._();

  // Palette — deep green-black ink, signal orange action, fog wash.
  static const Color paper = Color(0xFFFFFFFF);
  static const Color fog = Color(0xFFEDF1EA);
  static const Color fogDeep = Color(0xFFE1E8DE);
  static const Color ink = Color(0xFF17251F);
  static const Color inkSoft = Color(0xFF3C4A43);
  static const Color inkFaint = Color(0xFF6B7A71);
  static const Color ledgerLine = Color(0xFFD7DED5);
  static const Color signal = Color(0xFFD9481C);
  static const Color signalDeep = Color(0xFFA93310);
  static const Color signalWash = Color(0xFFFBE9E1);
  static const Color moss = Color(0xFF2E6B4E);
  static const Color mossWash = Color(0xFFE3EFE7);
  static const Color brass = Color(0xFF8F6B1F);
  static const Color brassWash = Color(0xFFF7EFDA);
  static const Color alert = Color(0xFFB3261E);
  static const Color night = Color(0xFF17251F);
  static const Color nightSoft = Color(0xFF24352D);

  // Varied radii — each surface owns its shape, never one radius for all.
  static const double radiusChip = 6;
  static const double radiusCard = 10;
  static const double radiusSheet = 16;
  static const double radiusPill = 999;

  // Spacing scale.
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  // Motion — short, single-ease, respects reduced motion via callers.
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 220);

  static const BorderRadius chipRadius =
      BorderRadius.all(Radius.circular(radiusChip));
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(radiusSheet),
  );

  static BoxDecoration get ledgerCard => BoxDecoration(
        color: paper,
        borderRadius: cardRadius,
        border: Border.all(color: ledgerLine),
      );

  static BoxDecoration get nightBoard => const BoxDecoration(
        color: night,
        borderRadius: cardRadius,
      );

  /// Tabular figures for timetable numerals (times, counts, ratings).
  static TextStyle tabular(TextStyle base) => base.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
