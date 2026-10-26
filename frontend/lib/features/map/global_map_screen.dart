import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import '../explore/place_detail_screen.dart';

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

  dynamic _selectedItem; // Place or MetroStation or BusStop

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
                label: Text('${widget.weather!.currentTempC.toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map Canvas with InteractiveViewer
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
              child: _buildSelectedItemCard(_selectedItem),
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
      checkmarkColor: Colors.white,
      onSelected: onToggle,
    );
  }

  void _handleMapTap(Offset tapPos) {
    // Check tapped place or station
    final city = widget.currentCity;
    dynamic closest;
    double minD = 28.0;

    if (_showAttractions) {
      for (final p in _places) {
        final pos = _project(p.latitude, p.longitude, city);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          closest = p;
        }
      }
    }

    if (_showMetro) {
      for (final s in _stations) {
        final pos = _project(s.latitude, s.longitude, city);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          closest = s;
        }
      }
    }

    if (_showBus) {
      for (final b in _busStops) {
        final pos = _project(b.latitude, b.longitude, city);
        final d = (pos - tapPos).distance;
        if (d < minD) {
          minD = d;
          closest = b;
        }
      }
    }

    if (closest != null) {
      setState(() => _selectedItem = closest);
    }
  }

  Widget _buildSelectedItemCard(dynamic item) {
    if (item is Place) {
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
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${item.category} • ★ ${item.rating}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onPlanRoute?.call(item),
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
                              place: item,
                              weather: widget.weather,
                              onPlanRoute: widget.onPlanRoute,
                              onAddToTrip: widget.onAddToTrip,
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
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.subway, color: AppTheme.accent, size: 20),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.englishName} • Code ${item.code} • ${item.lines.length} Lines'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedItem = null),
          ),
        ),
      );
    } else if (item is BusStop) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.directions_bus, color: Colors.green, size: 20),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Bus Stop ${item.code}'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedItem = null),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static Offset _project(double lat, double lng, City city) {
    final dx = (lng - city.longitude) * 6000 + 300;
    final dy = -(lat - city.latitude) * 6000 + 300;
    return Offset(dx.clamp(40.0, 560.0), dy.clamp(40.0, 560.0));
  }
}

class GlobalMapPainter extends CustomPainter {
  final City city;
  final List<MetroStation> stations;
  final List<BusStop> busStops;
  final List<Place> places;
  final dynamic selectedItem;

  GlobalMapPainter({
    required this.city,
    required this.stations,
    required this.busStops,
    required this.places,
    this.selectedItem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Street-style background
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // River / waterway simulation
    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final riverPath = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.45, size.width, size.height * 0.7);
    canvas.drawPath(riverPath, riverPaint);

    // Road Grid Lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5;
    for (double i = 60; i < size.width; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), roadPaint);
    }
    for (double i = 60; i < size.height; i += 80) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), roadPaint);
    }

    // Draw Metro Stations
    for (final s in stations) {
      final pos = _project(s.latitude, s.longitude, size);
      final isSel = selectedItem is MetroStation && selectedItem.id == s.id;

      final p = Paint()
        ..color = isSel ? Colors.amber : const Color(0xFF0284C7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSel ? 9 : 7, p);

      final border = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, isSel ? 9 : 7, border);
    }

    // Draw Bus Stops
    for (final b in busStops) {
      final pos = _project(b.latitude, b.longitude, size);
      final isSel = selectedItem is BusStop && selectedItem.id == b.id;

      final p = Paint()
        ..color = isSel ? Colors.amber : const Color(0xFF10B981)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromCenter(center: pos, width: isSel ? 12 : 9, height: isSel ? 12 : 9), p);
    }

    // Draw Attractions (Places)
    for (final pl in places) {
      final pos = _project(pl.latitude, pl.longitude, size);
      final isSel = selectedItem is Place && selectedItem.id == pl.id;

      // Pin marker
      final pinBg = Paint()
        ..color = isSel ? Colors.amber.shade700 : const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSel ? 12 : 9, pinBg);

      final whiteInner = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSel ? 5 : 3.5, whiteInner);

      // Label
      final span = TextSpan(
        text: pl.name,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isSel ? 11 : 9,
          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(pos.dx + 12, pos.dy - 6));
    }
  }

  Offset _project(double lat, double lng, Size size) {
    final dx = (lng - city.longitude) * 6000 + (size.width / 2);
    final dy = -(lat - city.latitude) * 6000 + (size.height / 2);
    return Offset(dx.clamp(30.0, size.width - 30), dy.clamp(30.0, size.height - 30));
  }

  @override
  bool shouldRepaint(covariant GlobalMapPainter oldDelegate) {
    return oldDelegate.selectedItem != selectedItem ||
        oldDelegate.stations != stations ||
        oldDelegate.busStops != busStops ||
        oldDelegate.places != places;
  }
}

