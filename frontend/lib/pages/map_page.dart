import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import '../features/map/widgets/global_map_painter.dart';
import '../features/map/widgets/map_selected_item_card.dart';
import 'widgets/trip_actions.dart';

/// Map: live geographic canvas. Single purpose — inspect stations,
/// stops and attractions on one canvas; details live on their own page.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _showMetro = true;
  bool _showBus = true;
  bool _showAttractions = true;

  List<MetroStation> _stations = [];
  List<BusStop> _busStops = [];
  List<Place> _places = [];
  bool _loading = true;
  dynamic _selectedItem;
  String? _cityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = CityScope.of(context).current?.id;
    if (id != null && id != _cityId) {
      _cityId = id;
      _load(id);
    }
  }

  Future<void> _load(String cityId) async {
    setState(() => _loading = true);
    final stations = await TravelApiClient.fetchMetroStations(cityId);
    final stops = await TravelApiClient.fetchBusStops(cityId);
    final places = await TravelApiClient.fetchPlaces(cityId);
    if (mounted && _cityId == cityId) {
      setState(() {
        _stations = stations;
        _busStops = stops;
        _places = places;
        _loading = false;
        _selectedItem = places.isNotEmpty ? places.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      mobile: (_) => _stack(context, docked: false),
      tablet: (_) => _stack(context, docked: false),
      pc: (_) => _stack(context, docked: true),
    );
  }

  Widget _stack(BuildContext context, {required bool docked}) {
    final session = CityScope.of(context);
    final city = session.current!;
    return Stack(
      children: [
        Positioned.fill(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(250),
                  minScale: 0.6,
                  maxScale: 3.0,
                  child: Center(
                    child: GestureDetector(
                      onTapUp: (d) => _tap(d.localPosition, city),
                      child: CustomPaint(
                        size: const Size(600, 600),
                        painter: GlobalMapPainter(
                          city: city,
                          stations: _showMetro ? _stations : [],
                          busStops: _showBus ? _busStops : [],
                          places: _showAttractions ? _places : [],
                          selectedItem: _selectedItem,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Positioned(
          top: LedgerTokens.s12,
          left: LedgerTokens.s12,
          right: docked ? null : LedgerTokens.s12,
          width: docked ? 300 : null,
          child: _layerPanel(context),
        ),
        if (_selectedItem != null)
          Positioned(
            bottom: LedgerTokens.s16,
            left: LedgerTokens.s16,
            right: docked ? null : LedgerTokens.s16,
            width: docked ? 360 : null,
            child: MapSelectedItemCard(
              item: _selectedItem,
              weather: session.weather,
              onPlanRoute: (p) => TripActions.planRoute(context, p),
              onAddToTrip: (p) => TripActions.addToTrip(context, p),
              onClose: () => setState(() => _selectedItem = null),
            ),
          ),
      ],
    );
  }

  Widget _layerPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LedgerTokens.s12),
      decoration: LedgerTokens.ledgerCard.copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${CityScope.of(context).current!.name} canvas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: LedgerTokens.s8),
          Wrap(
            spacing: LedgerTokens.s8,
            runSpacing: LedgerTokens.s8,
            children: [
              _layer('Metro ${_stations.length}', Icons.subway, _showMetro,
                  (v) => setState(() => _showMetro = v)),
              _layer('Bus ${_busStops.length}', Icons.directions_bus,
                  _showBus, (v) => setState(() => _showBus = v)),
              _layer('Places ${_places.length}', Icons.place,
                  _showAttractions, (v) => setState(
                        () => _showAttractions = v,
                      )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _layer(
      String label, IconData icon, bool active, ValueChanged<bool> onTap) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 14,
        color: active ? Colors.white : LedgerTokens.inkFaint,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      selected: active,
      selectedColor: LedgerTokens.signal,
      labelStyle: TextStyle(
        color: active ? Colors.white : LedgerTokens.ink,
      ),
      onSelected: onTap,
    );
  }

  void _tap(Offset pos, City city) {
    dynamic tapped;
    double minD = 24.0;
    if (_showAttractions) {
      for (final p in _places) {
        final d = (_project(p.latitude, p.longitude, city) - pos).distance;
        if (d < minD) {
          minD = d;
          tapped = p;
        }
      }
    }
    if (_showMetro && tapped == null) {
      for (final s in _stations) {
        final d = (_project(s.latitude, s.longitude, city) - pos).distance;
        if (d < minD) {
          minD = d;
          tapped = s;
        }
      }
    }
    if (_showBus && tapped == null) {
      for (final b in _busStops) {
        final d = (_project(b.latitude, b.longitude, city) - pos).distance;
        if (d < minD) {
          minD = d;
          tapped = b;
        }
      }
    }
    if (tapped != null) setState(() => _selectedItem = tapped);
  }

  static Offset _project(double lat, double lng, City city) {
    final dx = (lng - city.longitude) * 6000 + 300;
    final dy = -(lat - city.latitude) * 6000 + 300;
    return Offset(dx.clamp(40.0, 560.0), dy.clamp(40.0, 560.0));
  }
}
