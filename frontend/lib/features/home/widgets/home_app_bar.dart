import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/admin_coverage_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<City> cities;
  final City currentCity;
  final ValueChanged<City> onCityChanged;

  const HomeAppBar({
    super.key,
    required this.cities,
    required this.currentCity,
    required this.onCityChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: DropdownButtonHideUnderline(
        child: DropdownButton<City>(
          value: cities.firstWhere((x) => x.id == currentCity.id, orElse: () => currentCity),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textMain),
          items: cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_city, size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text('${city.name} (${city.countryCode})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            );
          }).toList(),
          onChanged: (newCity) {
            if (newCity != null) onCityChanged(newCity);
          },
        ),
      ),
      actions: [
        ValueListenableBuilder<String>(
          valueListenable: AppLocale.currentLanguage,
          builder: (ctx, lang, _) {
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: lang,
                icon: const Icon(Icons.language, size: 20, color: AppTheme.primary),
                items: const [
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                ],
                onChanged: (newLang) {
                  if (newLang != null) {
                    AppLocale.setLanguage(newLang);
                  }
                },
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.primary),
          tooltip: AppLocale.tr('admin_console'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => AdminCoverageScreen(cities: cities)),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

