import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF1E293B);
  static const Color accent = Color(0xFF2563EB); // Royal Blue
  static const Color accentLight = Color(0xFF38BDF8); // Sky 400
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color liveGreen = Color(0xFF10B981);
  static const Color warnAmber = Color(0xFFF59E0B);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: primary,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: accent,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}

