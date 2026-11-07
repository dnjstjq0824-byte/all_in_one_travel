import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import '../features/explore/widgets/add_review_dialog.dart';
import '../features/explore/widgets/place_info_section.dart';
import '../features/explore/widgets/popular_times_chart.dart';
import 'widgets/place_dossier.dart';
import 'widgets/place_reviews.dart';

/// Place detail: one attraction. Single purpose — full dossier of that
/// place plus its reviews. Reached from explore/map; never embedded.
class PlaceDetailPage extends StatefulWidget {
  final String placeId;
  final String cityId;
  final Place? initialPlace;

  const PlaceDetailPage({
    super.key,
    required this.placeId,
    required this.cityId,
    this.initialPlace,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Place? _place;
  List<Review> _reviews = [];
  bool _loadingPlace = true;
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    if (_place != null) _loadingPlace = false;
    _load();
  }

  Future<void> _load() async {
    final cityId = widget.cityId.isNotEmpty
        ? widget.cityId
        : CityScope.read(context).current?.id ?? '';
    if (_place == null && cityId.isNotEmpty) {
      final places = await TravelApiClient.fetchPlaces(cityId);
      if (!mounted) return;
      try {
        _place = places.firstWhere((p) => p.id == widget.placeId);
      } catch (_) {
        _place = null;
      }
      setState(() => _loadingPlace = false);
    }
    final reviews = await TravelApiClient.fetchReviews(widget.placeId);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    }
  }

  Future<void> _addReview() async {
    final created = await AddReviewDialog.show(context, _place!);
    if (created != null && mounted) {
      setState(() => _reviews.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted. Thank you.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPlace) {
      return const Center(child: CircularProgressIndicator());
    }
    final place = _place;
    if (place == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Place not found in this city.'),
            const SizedBox(height: LedgerTokens.s12),
            ElevatedButton(
              onPressed: () => context.go(Routes.explore),
              child: const Text('Back to Explore'),
            ),
          ],
        ),
      );
    }
    return AdaptivePage(
      mobile: (_) => _mobile(place),
      tablet: (_) => _mobile(place),
      pc: (_) => _pc(place),
    );
  }

  Widget _reviewsSection() => PlaceReviews(
        reviews: _reviews,
        loading: _loadingReviews,
        onWrite: _addReview,
      );

  Widget _facts(Place p) {
    final weather = CityScope.of(context).weather;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlaceInfoSection(place: p, weather: weather),
        if (p.popularTimes.isNotEmpty) ...[
          const SizedBox(height: LedgerTokens.s12),
          PopularTimesChart(place: p),
        ],
      ],
    );
  }

  Widget _mobile(Place p) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaceDossier.hero(p, 240),
          Padding(
            padding: const EdgeInsets.all(LedgerTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaceDossier.heading(context, p),
                const SizedBox(height: LedgerTokens.s16),
                PlaceDossier.actions(context, p),
                const SizedBox(height: LedgerTokens.s16),
                _facts(p),
                const SizedBox(height: LedgerTokens.s16),
                _reviewsSection(),
                const SizedBox(height: LedgerTokens.s24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pc(Place p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s32),
      child: LedgerMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: LedgerTokens.cardRadius,
              child: PlaceDossier.hero(p, 320),
            ),
            const SizedBox(height: LedgerTokens.s16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlaceDossier.heading(context, p),
                      const SizedBox(height: LedgerTokens.s16),
                      PlaceDossier.actions(context, p),
                      const SizedBox(height: LedgerTokens.s16),
                      _facts(p),
                    ],
                  ),
                ),
                const SizedBox(width: LedgerTokens.s24),
                Expanded(flex: 5, child: _reviewsSection()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
