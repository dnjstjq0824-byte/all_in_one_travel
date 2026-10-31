import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../explore/place_detail_screen.dart';

class HomePlaceMiniCard extends StatelessWidget {
  final Place place;
  final WeatherReport? weather;
  final Function(Place)? onPlanRoute;
  final Function(Place)? onAddToTrip;

  const HomePlaceMiniCard({
    super.key,
    required this.place,
    this.weather,
    this.onPlanRoute,
    this.onAddToTrip,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              place.photoUrls.isNotEmpty
                  ? place.photoUrls.first
                  : 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=400&q=80',
              height: 110,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 110,
                width: 200,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.place, size: 28, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(' (${place.reviewCount})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.nearestMetroStationName,
                    style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

