import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/l10n/app_localizations.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import '../features/transit/widgets/bus_arrivals_section.dart';

/// Arrivals: live bus board. Single purpose — realtime departures per
/// stop. Split out of the former merged transit screen.
class ArrivalsPage extends StatefulWidget {
  const ArrivalsPage({super.key});

  @override
  State<ArrivalsPage> createState() => _ArrivalsPageState();
}

class _ArrivalsPageState extends State<ArrivalsPage> {
  List<BusStop> _stops = [];
  BusStop? _selected;
  List<RealtimeArrival> _arrivals = [];
  bool _loading = true;
  String? _cityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = CityScope.of(context).current?.id;
    if (id != null && id != _cityId) {
      _cityId = id;
      _loadStops(id);
    }
  }

  Future<void> _loadStops(String cityId) async {
    setState(() => _loading = true);
    final stops = await TravelApiClient.fetchBusStops(cityId);
    if (!mounted || _cityId != cityId) return;
    setState(() {
      _stops = stops;
      _selected = stops.isNotEmpty ? stops.first : null;
    });
    if (_selected != null) {
      await _loadArrivals(_selected!.id);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadArrivals(String stopId) async {
    setState(() => _loading = true);
    final arrivals = await TravelApiClient.fetchRealtimeArrivals(stopId);
    if (mounted) {
      setState(() {
        _arrivals = arrivals;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = CityScope.of(context).current!;
    final text = Theme.of(context).textTheme;
    return LedgerMeasure(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocale.tr('bus_arrivals'), style: text.titleLarge),
                  Text(
                    '${city.name} · ${_stops.length} stops',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(LedgerTokens.s16),
              child: _stopStrip(),
            ),
          ),
          SliverToBoxAdapter(
            child: BusArrivalsSection(
              busStops: _stops,
              selectedBusStop: _selected,
              liveArrivals: _arrivals,
              loadingBus: _loading,
              onSelectStop: (s) {
                setState(() => _selected = s);
                _loadArrivals(s.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopStrip() {
    if (_stops.isEmpty && !_loading) {
      return const Text(
        'No bus stops published for this city.',
        style: TextStyle(color: LedgerTokens.inkFaint),
      );
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _stops.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: LedgerTokens.s8),
        itemBuilder: (ctx, i) {
          final stop = _stops[i];
          final sel = stop.id == _selected?.id;
          return ChoiceChip(
            label: Text(
              stop.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            selected: sel,
            selectedColor: LedgerTokens.signal,
            labelStyle: TextStyle(
              color: sel ? Colors.white : LedgerTokens.ink,
            ),
            onSelected: (_) {
              setState(() => _selected = stop);
              _loadArrivals(stop.id);
            },
          );
        },
      ),
    );
  }
}
