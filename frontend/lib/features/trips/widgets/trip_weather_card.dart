import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class TripWeatherCard extends StatelessWidget {
  final TripDay day;

  const TripWeatherCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final forecast = day.dayWeather;
    final rain = forecast?.rainAlert ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rain ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            forecast == null
                ? Icons.cloud_off_outlined
                : rain
                    ? Icons.umbrella_outlined
                    : Icons.cloud_outlined,
            color: rain ? Colors.orange.shade800 : AppTheme.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.dateStr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast == null
                      ? 'Forecast unavailable for this date'
                      : '${forecast.condition} · ${forecast.tempMinC.round()}°~${forecast.tempMaxC.round()}°C · Rain ${forecast.precipProb}%',
                ),
                if (rain && forecast?.indoorTip != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    forecast!.indoorTip!,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
