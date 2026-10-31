import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/models/travel_models.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/admin_coverage_screen.dart';

class DesktopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final List<City> cities;
  final City currentCity;
  final WeatherReport? weather;
  final ValueChanged<City> onCityChanged;

  const DesktopNavigationBar({
    super.key,
    required this.cities,
    required this.currentCity,
    required this.weather,
    required this.onCityChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Brand Logo
          Row(
            children: [
              const Icon(Icons.travel_explore, color: AppTheme.accentLight, size: 28),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GLOBAL TRAVEL ESSENTIAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Booking Network Co., Ltd. • Production Edition',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),

          // City Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<City>(
                dropdownColor: AppTheme.primaryDark,
                value: cities.firstWhere((x) => x.id == currentCity.id, orElse: () => currentCity),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                      '${city.name} (${city.countryCode})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (newCity) {
                  if (newCity != null) onCityChanged(newCity);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Weather Indicator
          if (weather != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${weather!.currentTempC.toStringAsFixed(1)}°C • ${weather!.condition}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Language Selector
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppTheme.primaryDark,
              value: AppLocale.currentLanguage.value,
              icon: const Icon(Icons.language, color: Colors.white70, size: 18),
              items: const [
                DropdownMenuItem(value: 'ko', child: Text('한국어 (KO)', style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(value: 'en', child: Text('English (EN)', style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(value: 'ja', child: Text('日本語 (JA)', style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(value: 'zh', child: Text('中文 (ZH)', style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(value: 'fr', child: Text('Français (FR)', style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(value: 'es', child: Text('Español (ES)', style: TextStyle(color: Colors.white, fontSize: 12))),
              ],
              onChanged: (val) {
                if (val != null) AppLocale.setLanguage(val);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Admin Console Button
          IconButton(
            tooltip: 'Coverage & Governance Console',
            icon: const Icon(Icons.shield_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AdminCoverageScreen(cities: cities)),
              );
            },
          ),
        ],
      ),
    );
  }
}

