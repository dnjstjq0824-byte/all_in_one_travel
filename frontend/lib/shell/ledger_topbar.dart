import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/l10n/app_localizations.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';

/// Ledger masthead: brand plate, city switch, weather strip, language.
class LedgerTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LedgerTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  static const _langs = [
    ('ko', 'KO'),
    ('en', 'EN'),
    ('ja', 'JA'),
    ('zh', 'ZH'),
    ('fr', 'FR'),
    ('es', 'ES'),
  ];

  @override
  Widget build(BuildContext context) {
    final session = CityScope.of(context);
    final city = session.current;
    final weather = session.weather;

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: LedgerTokens.night,
        border: Border(
          bottom: BorderSide(color: LedgerTokens.signal, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: LedgerTokens.s16),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go(Routes.home),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LedgerTokens.signal,
                    borderRadius: BorderRadius.circular(
                        LedgerTokens.radiusChip),
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: LedgerTokens.s8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GLOBAL TRAVEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'ESSENTIAL LEDGER',
                      style: TextStyle(
                        color: Color(0xFF9FB0A6),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: LedgerTokens.s16),
          if (city != null)
            _CitySwitch(
              label: '${city.name} (${city.countryCode})',
              level: city.coverageLevel,
            ),
          if (weather != null) ...[
            const SizedBox(width: LedgerTokens.s8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LedgerTokens.s12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: LedgerTokens.nightSoft,
                borderRadius:
                    BorderRadius.circular(LedgerTokens.radiusPill),
              ),
              child: Text(
                '${weather.currentTempC.toStringAsFixed(1)}°C · ${weather.condition}',
                style: LedgerTokens.tabular(
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          ValueListenableBuilder<String>(
            valueListenable: AppLocale.currentLanguage,
            builder: (context, lang, _) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: LedgerTokens.nightSoft,
                  value: lang,
                  icon: const Icon(
                    Icons.language,
                    color: Color(0xFF9FB0A6),
                    size: 18,
                  ),
                  items: [
                    for (final l in _langs)
                      DropdownMenuItem(
                        value: l.$1,
                        child: Text(
                          l.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) AppLocale.setLanguage(v);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: LedgerTokens.s8),
          IconButton(
            tooltip: AppLocale.tr('admin_console'),
            icon: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF9FB0A6),
            ),
            onPressed: () => context.go(Routes.coverage),
          ),
        ],
      ),
    );
  }
}

class _CitySwitch extends StatelessWidget {
  final String label;
  final String level;

  const _CitySwitch({required this.label, required this.level});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(Routes.cities),
      borderRadius: LedgerTokens.chipRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LedgerTokens.s12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: LedgerTokens.chipRadius,
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, color: Colors.white, size: 15),
            const SizedBox(width: LedgerTokens.s8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: LedgerTokens.s8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: LedgerTokens.moss,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                level.replaceFirst('LEVEL_', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
