import 'package:flutter/material.dart';

import 'app/router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/state/city_scope.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const GlobalTravelApp());
}

class GlobalTravelApp extends StatefulWidget {
  const GlobalTravelApp({super.key});

  @override
  State<GlobalTravelApp> createState() => _GlobalTravelAppState();
}

class _GlobalTravelAppState extends State<GlobalTravelApp> {
  late final CitySession _session;
  late final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    _session = CitySession();
    _session.load();
  }

  @override
  void dispose() {
    _session.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocale.currentLanguage,
      builder: (context, lang, _) {
        return CityScope(
          notifier: _session,
          child: MaterialApp.router(
            title: 'GLOBAL TRAVEL ESSENTIAL',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _router,
          ),
        );
      },
    );
  }
}
