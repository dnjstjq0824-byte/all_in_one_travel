import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';

/// Night departure board: city identity, weather strip, network counts.
class HomeBoard extends StatelessWidget {
  final City city;
  final WeatherReport? weather;
  final int lineCount;
  final int stationCount;
  final int placeCount;
  final bool loadingCounts;

  const HomeBoard({
    super.key,
    required this.city,
    required this.weather,
    required this.lineCount,
    required this.stationCount,
    required this.placeCount,
    required this.loadingCounts,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final w = weather;
    return Container(
      padding: const EdgeInsets.all(LedgerTokens.s24),
      decoration: LedgerTokens.nightBoard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LedgerTokens.s8,
                  vertical: LedgerTokens.s4,
                ),
                decoration: BoxDecoration(
                  color: LedgerTokens.moss,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  city.coverageLevel.replaceFirst('LEVEL_', 'LEVEL '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: LedgerTokens.s8),
              Text(
                city.countryCode,
                style: LedgerTokens.tabular(
                  const TextStyle(
                    color: Color(0xFF9FB0A6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LedgerTokens.s12),
          Text(
            city.name,
            style: text.displaySmall?.copyWith(color: Colors.white),
          ),
          Text(
            city.localName.isNotEmpty ? city.localName : city.englishName,
            style: const TextStyle(
              color: Color(0xFF9FB0A6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: LedgerTokens.s16),
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: LedgerTokens.s16),
          if (w != null)
            Wrap(
              spacing: LedgerTokens.s24,
              runSpacing: LedgerTokens.s8,
              children: [
                _figure(
                  '${w.currentTempC.toStringAsFixed(1)}°C',
                  w.condition,
                ),
                _figure('${w.feelsLikeC.toStringAsFixed(1)}°C', 'Feels like'),
                _figure('${w.humidity}%', 'Humidity'),
                _figure('${w.windSpeedKmH.toStringAsFixed(0)} km/h', 'Wind'),
              ],
            )
          else
            const Text(
              'Reading destination weather…',
              style: TextStyle(color: Color(0xFF9FB0A6), fontSize: 13),
            ),
          const SizedBox(height: LedgerTokens.s16),
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: LedgerTokens.s12),
          if (loadingCounts)
            const Text(
              'Counting network assets…',
              style: TextStyle(color: Color(0xFF9FB0A6), fontSize: 12),
            )
          else
            Wrap(
              spacing: LedgerTokens.s8,
              runSpacing: LedgerTokens.s8,
              children: [
                _countChip(context, '$lineCount lines', Routes.metro),
                _countChip(context, '$stationCount stations', Routes.metro),
                _countChip(context, '$placeCount places', Routes.explore),
              ],
            ),
        ],
      ),
    );
  }

  Widget _figure(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: LedgerTokens.tabular(
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9FB0A6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _countChip(BuildContext context, String label, String path) {
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(LedgerTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LedgerTokens.s12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(LedgerTokens.radiusPill),
        ),
        child: Text(
          label,
          style: LedgerTokens.tabular(
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
