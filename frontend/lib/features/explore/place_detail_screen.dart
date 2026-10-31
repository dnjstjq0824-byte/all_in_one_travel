import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import 'widgets/add_review_dialog.dart';
import 'widgets/place_info_section.dart';
import 'widgets/place_review_card.dart';
import 'widgets/popular_times_chart.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  final WeatherReport? weather;
  final Function(Place place)? onPlanRoute;
  final Function(Place place)? onAddToTrip;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    this.weather,
    this.onPlanRoute,
    this.onAddToTrip,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<Review> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final list = await TravelApiClient.fetchReviews(widget.place.id);
    if (mounted) {
      setState(() {
        _reviews = list;
        _loadingReviews = false;
      });
    }
  }

  void _showAddReviewDialog() async {
    final created = await AddReviewDialog.show(context, widget.place);
    if (created != null && mounted) {
      setState(() => _reviews.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted! Thank you for sharing.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    p.photoUrls.isNotEmpty ? p.photoUrls.first : 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: AppTheme.primary,
                      alignment: Alignment.center,
                      child: const Icon(Icons.place, size: 48, color: Colors.white24),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & Rating
                  Row(
                    children: [
                      Chip(
                        label: Text(p.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${p.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(' (${p.reviewCount})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(p.englishName, style: const TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                  const SizedBox(height: 14),

                  // Description
                  Text(p.description, style: const TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textMain)),
                  const SizedBox(height: 16),

                  // Transit & Practical Info Section
                  PlaceInfoSection(place: p, weather: widget.weather),
                  const SizedBox(height: 12),

                  // ARTICLE 1 & P1: Popular Times (Peak Hours Bar Chart)
                  if (p.popularTimes.isNotEmpty)
                    PopularTimesChart(place: p),
                  const SizedBox(height: 20),

                  // Reviews Header & Write Review Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${AppLocale.tr('reviews')} (${_reviews.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _showAddReviewDialog,
                        icon: const Icon(Icons.rate_review, size: 18, color: AppTheme.accent),
                        label: Text(AppLocale.tr('write_review'), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Review list
                  if (_loadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    const Text('No reviews yet. Be the first to share your experience!', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ..._reviews.map((r) => PlaceReviewCard(review: r)),

                  const SizedBox(height: 80), // bottom space for fixed action bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom Action Bar (Plan Route & Add to Trip)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => widget.onPlanRoute?.call(p),
                icon: const Icon(Icons.directions, color: AppTheme.accent),
                label: Text(AppLocale.tr('start_route'), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.accent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.onAddToTrip?.call(p),
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
                label: Text(AppLocale.tr('add_to_trip'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
