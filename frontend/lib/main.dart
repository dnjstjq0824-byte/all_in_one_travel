import 'package:flutter/material.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'shell/main_navigation_shell.dart';

void main() {
  runApp(const GlobalTravelApp());
}

class GlobalTravelApp extends StatelessWidget {
  const GlobalTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocale.currentLanguage,
      builder: (context, lang, _) {
        return MaterialApp(
          title: 'GLOBAL TRAVEL ESSENTIAL',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainNavigationShell(),
        );
      },
    );
  }
}
