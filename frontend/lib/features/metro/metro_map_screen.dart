import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import 'station_detail_sheet.dart';
import 'metro_canvas_painter.dart';

class MetroMapScreen extends StatefulWidget {
  final City city;
  final List<MetroLine> lines;
  final List<MetroStation> stations;
  final Function(MetroStation origin, MetroStation destination)? onRouteRequested;

  const MetroMapScreen({
    super.key,
    required this.city,
    required this.lines,
    required this.stations,
    this.onRouteRequested,
  });

  @override
  State<MetroMapScreen> createState() => _MetroMapScreenState();
}

class _MetroMapScreenState extends State<MetroMapScreen> {
  MetroViewMode _viewMode = MetroViewMode.schematic;
  String? _selectedLineId;
  MetroStation? _selectedStation;
  final TransformationController _transformController = TransformationController();

  @override
  Widget build(BuildContext context) {
    final filteredLines = _selectedLineId == null
        ? widget.lines
        : widget.lines.where((l) => l.id == _selectedLineId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city.name} ${AppLocale.tr('metro_network')}'),
        actions: [
          // Toggle View Mode
          SegmentedButton<MetroViewMode>(
            segments: [
              ButtonSegment(
                value: MetroViewMode.schematic,
                label: Text(AppLocale.tr('schematic_view'), style: const TextStyle(fontSize: 11)),
                icon: const Icon(Icons.schema_outlined, size: 14),
              ),
              ButtonSegment(
                value: MetroViewMode.geographic,
                label: Text(AppLocale.tr('geographic_view'), style: const TextStyle(fontSize: 11)),
                icon: const Icon(Icons.map_outlined, size: 14),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (set) {
              setState(() {
                _viewMode = set.first;
              });
            },
            showSelectedIcon: false,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Line Filter Chips
          if (widget.lines.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('All Lines', style: TextStyle(fontSize: 12)),
                    selected: _selectedLineId == null,
                    onSelected: (val) {
                      setState(() => _selectedLineId = null);
                    },
                  ),
                  const SizedBox(width: 6),
                  ...widget.lines.map((l) {
                    final isSel = _selectedLineId == l.id;
                    final c = _parseColor(l.colorHex);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          l.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppTheme.textMain,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: c,
                        backgroundColor: c.withValues(alpha: 0.15),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setState(() {
                            _selectedLineId = val ? l.id : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Main Map Canvas
          Expanded(
            child: widget.stations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.subway_outlined, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text('No metro data available for ${widget.city.name}', style: const TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : InteractiveViewer(
                    transformationController: _transformController,
                    boundaryMargin: const EdgeInsets.all(300),
                    minScale: 0.5,
                    maxScale: 3.5,
                    child: Center(
                      child: GestureDetector(
                        onTapUp: (details) {
                          _handleCanvasTap(details.localPosition);
                        },
                        child: CustomPaint(
                          size: const Size(600, 600),
                          painter: MetroCanvasPainter(
                            viewMode: _viewMode,
                            lines: filteredLines,
                            stations: widget.stations,
                            selectedStation: _selectedStation,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleCanvasTap(Offset tapPos) {
    // Find closest station within 24 pixels
    MetroStation? tapped;
    double minD = 24.0;

    for (final stn in widget.stations) {
      Offset pos;
      if (_viewMode == MetroViewMode.schematic) {
        pos = Offset(stn.schematicX, stn.schematicY);
      } else {
        pos = _projectGeoToOffset(stn.latitude, stn.longitude, widget.city);
      }

      final d = (pos - tapPos).distance;
      if (d < minD) {
        minD = d;
        tapped = stn;
      }
    }

    if (tapped != null) {
      setState(() {
        _selectedStation = tapped;
      });
      _showStationSheet(tapped);
    }
  }

  void _showStationSheet(MetroStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StationDetailSheet(
        station: station,
        allLines: widget.lines,
        onSetAsOrigin: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Origin set to ${station.name}')),
          );
        },
        onSetAsDestination: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Destination set to ${station.name}')),
          );
        },
      ),
    );
  }

  static Offset _projectGeoToOffset(double lat, double lng, City city) {
    // Normalize coordinates relative to city center onto a 600x600 canvas
    final dx = (lng - city.longitude) * 6000 + 300;
    final dy = -(lat - city.latitude) * 6000 + 300;
    return Offset(dx.clamp(40.0, 560.0), dy.clamp(40.0, 560.0));
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return AppTheme.accent;
  }
}

