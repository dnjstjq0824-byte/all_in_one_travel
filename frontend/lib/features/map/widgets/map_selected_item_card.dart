import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../explore/place_detail_screen.dart';

class MapSelectedItemCard extends StatelessWidget {
  final dynamic item;
  final WeatherReport? weather;
  final Function(Place)? onPlanRoute;
  final Function(Place)? onAddToTrip;
  final VoidCallback onClose;

  const MapSelectedItemCard({
    super.key,
    required this.item,
    this.weather,
    this.onPlanRoute,
    this.onAddToTrip,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (item is Place) {
      final place = item as Place;
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(Icons.place, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${place.category} • ★ ${place.rating}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(place.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onPlanRoute?.call(place),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => PlaceDetailScreen(
                              place: place,
                              weather: weather,
                              onPlanRoute: onPlanRoute,
                              onAddToTrip: onAddToTrip,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                      icon: const Icon(Icons.info_outline, size: 16, color: Colors.white),
                      label: const Text('Details', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (item is MetroStation) {
      final stn = item as MetroStation;
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.subway, color: AppTheme.accent, size: 20),
          ),
          title: Text(stn.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${stn.englishName} • Code ${stn.code} • ${stn.lines.length} Lines'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ),
      );
    } else if (item is BusStop) {
      final stop = item as BusStop;
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.directions_bus, color: Colors.green, size: 20),
          ),
          title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Bus Stop ${stop.code}'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

