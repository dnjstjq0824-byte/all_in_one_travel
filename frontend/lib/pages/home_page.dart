import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import 'widgets/home_board.dart';
import 'widgets/home_index.dart';

/// Home: departure board plus the ledger index. Single purpose — orient
/// the traveler, then hand off to dedicated pages via links only.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _lines = 0;
  int _stations = 0;
  int _places = 0;
  bool _loading = true;
  String? _cityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = CityScope.of(context).current?.id;
    if (id != null && id != _cityId) {
      _cityId = id;
      _loadCounts(id);
    }
  }

  Future<void> _loadCounts(String cityId) async {
    setState(() => _loading = true);
    final lines = await TravelApiClient.fetchMetroLines(cityId);
    final stations = await TravelApiClient.fetchMetroStations(cityId);
    final places = await TravelApiClient.fetchPlaces(cityId);
    if (mounted && _cityId == cityId) {
      setState(() {
        _lines = lines.length;
        _stations = stations.length;
        _places = places.length;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = CityScope.of(context);
    final city = session.current!;

    return AdaptivePage(
      mobile: (_) => _mobile(context, city),
      tablet: (_) => _tablet(context, city),
      pc: (_) => _pc(context, city),
    );
  }

  Widget _mobile(BuildContext context, city) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeBoard(
            city: city,
            weather: CityScope.of(context).weather,
            lineCount: _lines,
            stationCount: _stations,
            placeCount: _places,
            loadingCounts: _loading,
          ),
          const SizedBox(height: LedgerTokens.s16),
          const LedgerRule(label: 'LEDGER INDEX'),
          const SizedBox(height: LedgerTokens.s8),
          const HomeIndex(),
        ],
      ),
    );
  }

  Widget _tablet(BuildContext context, city) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s24),
      child: LedgerMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeBoard(
              city: city,
              weather: CityScope.of(context).weather,
              lineCount: _lines,
              stationCount: _stations,
              placeCount: _places,
              loadingCounts: _loading,
            ),
            const SizedBox(height: LedgerTokens.s16),
            const LedgerRule(label: 'LEDGER INDEX'),
            const SizedBox(height: LedgerTokens.s8),
            const HomeIndex(columns: 2),
          ],
        ),
      ),
    );
  }

  Widget _pc(BuildContext context, city) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s32),
      child: LedgerMeasure(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: HomeBoard(
                city: city,
                weather: CityScope.of(context).weather,
                lineCount: _lines,
                stationCount: _stations,
                placeCount: _places,
                loadingCounts: _loading,
              ),
            ),
            const SizedBox(width: LedgerTokens.s24),
            const Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LedgerRule(label: 'LEDGER INDEX'),
                  SizedBox(height: LedgerTokens.s8),
                  HomeIndex(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
