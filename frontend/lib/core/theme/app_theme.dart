import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// App theme built from [LedgerTokens].
///
/// Static color fields keep their historic names so existing data widgets
/// (cards, painters, dialogs) pick up the new palette without edits.
class AppTheme {
  static const Color primary = LedgerTokens.ink;
  static const Color primaryDark = LedgerTokens.night;
  static const Color secondary = LedgerTokens.inkSoft;
  static const Color accent = LedgerTokens.signal;
  static const Color accentLight = LedgerTokens.moss;
  static const Color surface = LedgerTokens.paper;
  static const Color cardBg = LedgerTokens.paper;
  static const Color border = LedgerTokens.ledgerLine;
  static const Color liveGreen = LedgerTokens.moss;
  static const Color warnAmber = LedgerTokens.brass;
  static const Color textMain = LedgerTokens.ink;
  static const Color textMuted = LedgerTokens.inkFaint;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: LedgerTokens.paper,
    colorScheme: const ColorScheme.light(
      primary: LedgerTokens.ink,
      secondary: LedgerTokens.signal,
      surface: LedgerTokens.paper,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: LedgerTokens.paper,
      foregroundColor: LedgerTokens.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: LedgerTokens.ink,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: LedgerTokens.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: LedgerTokens.cardRadius,
        side: const BorderSide(color: LedgerTokens.ledgerLine),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: LedgerTokens.ledgerLine,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: LedgerTokens.fog,
      selectedColor: LedgerTokens.signal,
      labelStyle: const TextStyle(
        color: LedgerTokens.ink,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LedgerTokens.radiusChip),
        side: const BorderSide(color: Colors.transparent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LedgerTokens.paper,
      hintStyle: const TextStyle(
        color: LedgerTokens.inkFaint,
        fontSize: 13,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LedgerTokens.s16,
        vertical: LedgerTokens.s12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LedgerTokens.radiusCard),
        borderSide: const BorderSide(color: LedgerTokens.ledgerLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LedgerTokens.radiusCard),
        borderSide: const BorderSide(color: LedgerTokens.ledgerLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LedgerTokens.radiusCard),
        borderSide: const BorderSide(color: LedgerTokens.signal, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LedgerTokens.signal,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LedgerTokens.radiusCard),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LedgerTokens.signal,
        side: const BorderSide(color: LedgerTokens.signal),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LedgerTokens.radiusCard),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LedgerTokens.paper,
      selectedItemColor: LedgerTokens.signal,
      unselectedItemColor: LedgerTokens.inkFaint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: LedgerTokens.paper,
      selectedIconTheme: IconThemeData(color: LedgerTokens.signal),
      unselectedIconTheme: IconThemeData(color: LedgerTokens.inkFaint),
      selectedLabelTextStyle: TextStyle(
        color: LedgerTokens.signal,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: LedgerTokens.inkFaint,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: LedgerTokens.ink,
        height: 1.1,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: LedgerTokens.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: LedgerTokens.ink,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: LedgerTokens.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: LedgerTokens.ink),
      bodySmall: TextStyle(fontSize: 12, color: LedgerTokens.inkSoft),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: LedgerTokens.inkFaint,
      ),
    ),
  );
}
