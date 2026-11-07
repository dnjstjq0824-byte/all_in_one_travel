import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';

/// Cities: region selector. Single purpose — pick the active city.
class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      mobile: (_) => _list(context, 1),
      tablet: (_) => _list(context, 2),
      pc: (_) => _list(context, 3),
    );
  }

  Widget _list(BuildContext context, int columns) {
    final session = CityScope.of(context);
    final cities = session.cities;
    final currentId = session.current?.id;
    final text = Theme.of(context).textTheme;

    return LedgerMeasure(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                LedgerTokens.s16,
                LedgerTokens.s24,
                LedgerTokens.s16,
                LedgerTokens.s8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Regions', style: text.displaySmall),
                  const SizedBox(height: LedgerTokens.s4),
                  Text(
                    '${cities.length} verified cities · '
                    'unsupported regions are never listed',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(LedgerTokens.s16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 132,
                crossAxisSpacing: LedgerTokens.s12,
                mainAxisSpacing: LedgerTokens.s12,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _cityCard(
                  context,
                  cities[i],
                  cities[i].id == currentId,
                ),
                childCount: cities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityCard(BuildContext context, City city, bool active) {
    return InkWell(
      onTap: () async {
        await CityScope.read(context).select(city);
        if (context.mounted) context.go(Routes.home);
      },
      borderRadius: LedgerTokens.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(LedgerTokens.s16),
        decoration: active
            ? const BoxDecoration(
                color: LedgerTokens.night,
                borderRadius: LedgerTokens.cardRadius,
              )
            : LedgerTokens.ledgerCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    city.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: active ? Colors.white : LedgerTokens.ink,
                    ),
                  ),
                ),
                if (active)
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: LedgerTokens.signal,
                  ),
              ],
            ),
            Text(
              '${city.localName} · ${city.countryCode}',
              style: TextStyle(
                fontSize: 12,
                color: active
                    ? const Color(0xFF9FB0A6)
                    : LedgerTokens.inkFaint,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _levelDot(city.coverageLevel),
                const SizedBox(width: LedgerTokens.s8),
                Text(
                  city.coverageLevel.replaceFirst('LEVEL_', 'LEVEL '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: active
                        ? const Color(0xFF9FB0A6)
                        : LedgerTokens.inkSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelDot(String level) {
    final color = switch (level) {
      'LEVEL_A' => LedgerTokens.moss,
      'LEVEL_B' => LedgerTokens.signal,
      'LEVEL_C' => LedgerTokens.brass,
      _ => LedgerTokens.inkFaint,
    };
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
