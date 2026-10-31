import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import 'bus_arrival_card.dart';

class BusArrivalsSection extends StatelessWidget {
  final List<BusStop> busStops;
  final BusStop? selectedBusStop;
  final List<RealtimeArrival> liveArrivals;
  final bool loadingBus;
  final ValueChanged<BusStop> onSelectStop;

  const BusArrivalsSection({
    super.key,
    required this.busStops,
    required this.selectedBusStop,
    required this.liveArrivals,
    required this.loadingBus,
    required this.onSelectStop,
  });

  @override
  Widget build(BuildContext context) {
    if (busStops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocale.tr('bus_arrivals'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text('GTFS Realtime', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
        // Stop Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BusStop>(
                  isExpanded: true,
                  value: selectedBusStop,
                  items: busStops.map((s) {
                    return DropdownMenuItem(value: s, child: Text('${s.name} (${s.code})'));
                  }).toList(),
                  onChanged: (s) {
                    if (s != null) onSelectStop(s);
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Arrivals Cards
        if (loadingBus)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (liveArrivals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No real-time buses currently en-route for this stop.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          )
        else
          ...liveArrivals.map((arr) => BusArrivalCard(arrival: arr)),
      ],
    );
  }
}

