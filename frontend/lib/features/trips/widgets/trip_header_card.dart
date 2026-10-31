import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class TripHeaderCard extends StatelessWidget {
  final Trip trip;
  final List<Trip> trips;
  final bool busy;
  final ValueChanged<Trip> onSelectTrip;
  final VoidCallback onEditTrip;
  final VoidCallback onDeleteTrip;

  const TripHeaderCard({
    super.key,
    required this.trip,
    required this.trips,
    required this.busy,
    required this.onSelectTrip,
    required this.onEditTrip,
    required this.onDeleteTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(trip.id),
                  initialValue: trip.id,
                  decoration: const InputDecoration(
                    labelText: 'Select trip',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: trips.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(t.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: busy
                      ? null
                      : (id) {
                          final match = trips.where((t) => t.id == id);
                          if (match.isNotEmpty) onSelectTrip(match.first);
                        },
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Trip actions',
                enabled: !busy,
                onSelected: (action) {
                  if (action == 'edit') {
                    onEditTrip();
                  } else {
                    onDeleteTrip();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit trip')),
                  PopupMenuItem(value: 'delete', child: Text('Delete trip')),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            color: AppTheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trip.cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${trip.startDate} ~ ${trip.endDate}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${trip.days.length} Days Itinerary • Linked Transit & Weather',
                    style: TextStyle(color: Colors.blue.shade200, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

