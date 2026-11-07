import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import '../features/metro/metro_canvas_painter.dart';
import '../features/metro/station_detail_sheet.dart';
import 'widgets/metro_toolbar.dart';

/// Metro: schematic/geographic network canvas. Single purpose — inspect
/// lines and stations. Reaches the traveler as a first-class page.
class MetroPage extends StatefulWidget {
  const MetroPage({super.key});

  @override
  State<MetroPage> createState() => _MetroPageState();
}

class _MetroPageState extends State<MetroPage> {
  MetroViewMode _mode = MetroViewMode.schematic;
  String? _lineId;
  MetroStation? _selected;
  List<MetroLine> _lines = [];
  List<MetroStation> _stations = [];
  bool _loading = true;
  String? _cityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = CityScope.of(context).current?.id;
    if (id != null && id != _cityId) {
      _cityId = id;
      _lineId = null;
      _selected = null;
      _load(id);
    }
  }

  Future<void> _load(String cityId) async {
    setState(() => _loading = true);
    final lines = await TravelApiClient.fetchMetroLines(cityId);
    final stations = await TravelApiClient.fetchMetroStations(cityId);
    if (mounted && _cityId == cityId) {
      setState(() {
        _lines = lines;
        _stations = stations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = CityScope.of(context).current!;
    final filtered = _lineId == null
        ? _lines
        : _lines.where((l) => l.id == _lineId).toList();
    return AdaptivePage(
      mobile: (_) => _mobile(city, filtered),
      tablet: (_) => _mobile(city, filtered),
      pc: (_) => _pc(city, filtered),
    );
  }

  Widget _toolbar(City city) => MetroToolbar(
        city: city,
        mode: _mode,
        onMode: (m) => setState(() => _mode = m),
        lines: _lines,
        lineId: _lineId,
        onLine: (id) => setState(() => _lineId = id),
      );

  Widget _canvas(City city, List<MetroLine> filtered) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stations.isEmpty) {
      return Center(
        child: Text(
          'No metro data for ${city.name}.',
          style: const TextStyle(color: LedgerTokens.inkFaint),
        ),
      );
    }
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(300),
      minScale: 0.5,
      maxScale: 3.5,
      child: Center(
        child: GestureDetector(
          onTapUp: (d) => _tap(d.localPosition, city),
          child: CustomPaint(
            size: const Size(600, 600),
            painter: MetroCanvasPainter(
              viewMode: _mode,
              lines: filtered,
              stations: _stations,
              selectedStation: _selected,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobile(City city, List<MetroLine> filtered) {
    return Column(
      children: [
        _toolbar(city),
        Expanded(child: _canvas(city, filtered)),
      ],
    );
  }

  Widget _pc(City city, List<MetroLine> filtered) {
    return Column(
      children: [
        _toolbar(city),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _canvas(city, filtered)),
              Container(
                width: 300,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: LedgerTokens.ledgerLine),
                  ),
                ),
                child: _stationLedger(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stationLedger() {
    if (_selected == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(LedgerTokens.s24),
          child: Text(
            'Select a station on the canvas to inspect it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: LedgerTokens.inkFaint, fontSize: 13),
          ),
        ),
      );
    }
    final s = _selected!;
    return ListView(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      children: [
        const LedgerRule(label: 'STATION'),
        Text(s.name, style: Theme.of(context).textTheme.titleLarge),
        Text(
          '${s.englishName} · Code ${s.code}',
          style: const TextStyle(color: LedgerTokens.inkFaint, fontSize: 12),
        ),
        const SizedBox(height: LedgerTokens.s12),
        StationDetailSheet(station: s, allLines: _lines),
      ],
    );
  }

  void _tap(Offset pos, City city) {
    MetroStation? tapped;
    double minD = 24.0;
    for (final s in _stations) {
      final Offset p = _mode == MetroViewMode.schematic
          ? Offset(s.schematicX, s.schematicY)
          : _project(s.latitude, s.longitude, city);
      final d = (p - pos).distance;
      if (d < minD) {
        minD = d;
        tapped = s;
      }
    }
    if (tapped == null) return;
    setState(() => _selected = tapped);
    final kind = MediaQuery.sizeOf(context).width;
    if (kind >= 1000) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          StationDetailSheet(station: tapped!, allLines: _lines),
    );
  }

  static Offset _project(double lat, double lng, City city) {
    final dx = (lng - city.longitude) * 6000 + 300;
    final dy = -(lat - city.latitude) * 6000 + 300;
    return Offset(dx.clamp(40.0, 560.0), dy.clamp(40.0, 560.0));
  }
}
