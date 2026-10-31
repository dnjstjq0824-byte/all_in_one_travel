import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class PlaceInfoSection extends StatelessWidget {
  final Place place;
  final WeatherReport? weather;

  const PlaceInfoSection({super.key, required this.place, this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transit Access Card
        Card(
          color: Colors.blue.shade50.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_subway, color: AppTheme.accent, size: 20),
                    SizedBox(width: 6),
                    Text('Transit Access (Verified)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accent)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    const Icon(Icons.subway_outlined, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Nearest Station: ${place.nearestMetroStationName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.directions_bus_outlined, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Nearest Bus Stop: ${place.nearestBusStopId.isNotEmpty ? place.nearestBusStopId : "Connected Bus Network"}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Destination Weather Card
        if (weather != null) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
              title: Text('Destination Weather: ${weather!.currentTempC.toStringAsFixed(1)}°C (${weather!.condition})'),
              subtitle: Text('Feels like ${weather!.feelsLikeC.toStringAsFixed(1)}°C • Humidity ${weather!.humidity}% • Rain ${weather!.precipProb}%'),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Practical Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                _buildRow(Icons.access_time, 'Hours', place.openingHours),
                const Divider(height: 16),
                _buildRow(Icons.confirmation_number_outlined, 'Admission', place.admissionFee),
                const Divider(height: 16),
                _buildRow(Icons.location_on_outlined, 'Address', place.address),
                const Divider(height: 16),
                _buildRow(Icons.accessible, 'Accessibility', place.accessibilityInfo),
                const Divider(height: 16),
                _buildRow(Icons.tips_and_updates_outlined, 'Best Time', place.bestTimeToVisit),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.accent),
        const SizedBox(width: 10),
        SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMuted))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textMain))),
      ],
    );
  }
}

