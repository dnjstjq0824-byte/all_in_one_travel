import 'package:flutter/material.dart';
import '../../core/api/travel_api_client.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/global_map_painter.dart';
import 'widgets/map_selected_item_card.dart';

class GlobalMapScreen extends StatefulWidget {
  final City currentCity;
  final WeatherReport? weather;
  final Function(Place place)? onPlanRoute;
  final Function(Place place)? onAddToTrip;

  const GlobalMapScreen({
    super.key,
    required this.currentCity,
    this.weather,
    this.onPlanRoute,
    this.onAddToTrip,
  });

  @override
  State<GlobalMapScreen> createState() => _GlobalMapScreenState();
}

class _GlobalMapScreenState extends State<GlobalMapScreen> {
  bool _showMetro = true;
  bool _showBus = true;
  bool _showAttractions = true;

  List<MetroStation> _stations = [];
  List<BusStop> _busStops = [];
  List<Place> _places = [];
  bool _loading = true;

  dynamic _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  void didUpdateWidget(covariant GlobalMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity.id != widget.currentCity.id) {
      _loadMapData();
    }
  }

  Future<void> _loadMapData() async {
    setState(() => _loading = true);
    final stations = await TravelApiClient.fetchMetroStations(widget.currentCity.id);
    final stops = await TravelApiClient.fetchBusStops(widget.currentCity.id);
    final places = await TravelApiClient.fetchPlaces(widget.currentCity.id);

    if (mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentCity.name} ${AppLocale.tr('tab_map')}'),
        actions: [
          if (widget.weather != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                avatar: const Icon(Icons.wb_sunny, color: Colors.orange, size: 16),
                label: Text(
                  '${widget.weather!.currentTempC.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(250),
                  minScale: 0.6,
                  maxScale: 3.0,
                  child: Center(
                    child: GestureDetector(
                      onTapUp: (details) => _handleMapTap(details.localPosition),
                      child: CustomPaint(
                        size: const Size(600, 600),
                        painter: GlobalMapPainter(
                          city: widget.currentCity,
                          stations: _showMetro ? _stations : [],
                          busStops: _showBus ? _busStops : [],
                          places: _showAttractions ? _places : [],
                          selectedItem: _selectedItem,
                        ),
                      ),
                    ),
                  ),
                ),

          // Layer Toggle Pills at Top
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLayerFilter('Metro', Icons.subway, _showMetro, (v) => setState(() => _showMetro = v)),
                  const SizedBox(width: 8),
                  _buildLayerFilter('Bus Stops', Icons.directions_bus, _showBus, (v) => setState(() => _showBus = v)),
                  const SizedBox(width: 8),
                  _buildLayerFilter('Attractions', Icons.place, _showAttractions, (v) => setState(() => _showAttractions = v)),
                ],
              ),
            ),
          ),

          // Bottom Slide-Up Card for Selected Item
          if (_selectedItem != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: MapSelectedItemCard(
                item: _selectedItem,
                weather: widget.weather,
                onPlanRoute: widget.onPlanRoute,
                onAddToTrip: widget.onAddToTrip,
                onClose: () => setState(() => _selectedItem = null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayerFilter(String label, IconData icon, bool active, Function(bool) onToggle) {
    return FilterChip(
      avatar: Icon(icon, size: 14, color: active ? Colors.white : AppTheme.textMuted),
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      selected: active,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(color: active ? Colors.white : AppTheme.textMain),
      onSelected: onToggle,
    );
  }

  void _handleMapTap(Offset tapPos) {
    dynamic tapped;
    double minD = 24.0;

    if (_showAttractions) {
      for (final p in _places) {
        final pos = _project(p.latitude, p.longitude, widget.currentCity);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          tapped = p;
        }
      }
    }
    if (_showMetro && tapped == null) {
      for (final s in _stations) {
        final pos = _project(s.latitude, s.longitude, widget.currentCity);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          tapped = s;
        }
      }
    }
    if (_showBus && tapped == null) {
      for (final b in _busStops) {
        final pos = _project(b.latitude, b.longitude, widget.currentCity);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          tapped = b;
        }
      }
    }

    if (tapped != null) {
      setState(() => _selectedItem = tapped);
    }
  }

  static Offset _project(double lat, double lng, City city) {
    final dx = (lng - city.longitude) * 6000 + 300;
    final dy = -(lat - city.latitude) * 6000 + 300;
    return Offset(dx.clamp(40.0, 560.0), dy.clamp(40.0, 560.0));
  }
}
