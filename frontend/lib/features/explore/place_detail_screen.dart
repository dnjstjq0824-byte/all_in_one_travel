import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';

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

  void _showAddReviewDialog() {
    int rating = 5;
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final tipCtrl = TextEditingController();
    String travelType = 'Solo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocale.tr('write_review'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star Rating Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                      onPressed: () {
                        setDlgState(() => rating = star);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Review Title',
                    hintText: 'e.g. Unbelievable morning view!',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Experience',
                    hintText: 'Share transit tips, photo spots, and highlights...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Insider Tip (Optional)',
                    hintText: 'e.g. Arrive before 10 AM',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: travelType,
                  decoration: const InputDecoration(labelText: 'Travel Type', border: OutlineInputBorder()),
                  items: ['Solo', 'Couple', 'Family', 'Friends'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDlgState(() => travelType = v ?? 'Solo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              onPressed: () async {
                if (contentCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final newRev = Review(
                  id: '',
                  placeId: widget.place.id,
                  authorName: 'Traveler',
                  rating: rating,
                  title: titleCtrl.text.trim().isEmpty ? 'Great Experience' : titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  visitPeriod: 'October 2026',
                  travelType: travelType,
                  visitTip: tipCtrl.text.trim(),
                  helpfulCount: 0,
                  verifiedVisit: false,
                  language: 'en',
                );
                final created = await TravelApiClient.submitReview(widget.place.id, newRev);
                if (created != null && mounted) {
                  setState(() {
                    _reviews.insert(0, created);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted! Thank you for sharing.')),
                  );
                }
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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

                  // ARTICLE 12: Complete Transit Connection Card
                  Card(
                    color: Colors.blue.shade50.withOpacity(0.5),
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
                                child: Text('Nearest Station: ${p.nearestMetroStationName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.directions_bus_outlined, size: 16, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Nearest Bus Stop: ${p.nearestBusStopId.isNotEmpty ? p.nearestBusStopId : "Connected Bus Network"}', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weather Card
                  if (widget.weather != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                        title: Text('Destination Weather: ${widget.weather!.currentTempC.toStringAsFixed(1)}°C (${widget.weather!.condition})'),
                        subtitle: Text('Feels like ${widget.weather!.feelsLikeC.toStringAsFixed(1)}°C • Humidity ${widget.weather!.humidity}% • Rain ${widget.weather!.precipProb}%'),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Practical Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.access_time, 'Hours', p.openingHours),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.confirmation_number_outlined, 'Admission', p.admissionFee),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.location_on_outlined, 'Address', p.address),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.accessible, 'Accessibility', p.accessibilityInfo),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.tips_and_updates_outlined, 'Best Time', p.bestTimeToVisit),
                        ],
                      ),
                    ),
                  ),
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
                    ..._reviews.map((r) => _buildReviewCard(r)),

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
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

  Widget _buildReviewCard(Review r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(r.authorName[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    ),
                    const SizedBox(width: 8),
                    Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                if (r.verifiedVisit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text('VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < r.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  )),
                ),
                const SizedBox(width: 8),
                Text('${r.travelType} • ${r.visitPeriod}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(r.content, style: const TextStyle(fontSize: 13, height: 1.4)),
            if (r.visitTip != null && r.visitTip!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Tip: ${r.visitTip}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
