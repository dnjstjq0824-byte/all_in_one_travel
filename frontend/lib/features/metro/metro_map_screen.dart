import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import 'station_detail_sheet.dart';

enum MetroViewMode { schematic, geographic }

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
                        backgroundColor: c.withOpacity(0.15),
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

class MetroCanvasPainter extends CustomPainter {
  final MetroViewMode viewMode;
  final List<MetroLine> lines;
  final List<MetroStation> stations;
  final MetroStation? selectedStation;

  MetroCanvasPainter({
    required this.viewMode,
    required this.lines,
    required this.stations,
    this.selectedStation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.08)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final stnMap = {for (var s in stations) s.id: s};

    // Draw Line Tracks
    for (final line in lines) {
      final linePaint = Paint()
        ..color = _parseColor(line.colorHex)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool first = true;

      for (final sid in line.stationIds) {
        final s = stnMap[sid];
        if (s == null) continue;

        final pos = _getPos(s, size);
        if (first) {
          path.moveTo(pos.dx, pos.dy);
          first = false;
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }

      if (line.isCircular && !first) {
        path.close();
      }

      canvas.drawPath(path, linePaint);
    }

    // Draw Stations
    for (final s in stations) {
      final pos = _getPos(s, size);
      final isSel = selectedStation?.id == s.id;
      final isTransfer = s.lines.length > 1;

      // Transfer outer halo
      if (isTransfer) {
        final haloPaint = Paint()
          ..color = Colors.black.withOpacity(0.12)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 12, haloPaint);
      }

      // Station node
      final stnPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isTransfer ? 8 : 6, stnPaint);

      final borderPaint = Paint()
        ..color = isSel ? Colors.amber.shade700 : (isTransfer ? Colors.black87 : AppTheme.primary)
        ..strokeWidth = isSel ? 3.5 : (isTransfer ? 2.5 : 2.0)
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, isTransfer ? 8 : 6, borderPaint);

      // Station Name label
      final textSpan = TextSpan(
        text: s.name,
        style: TextStyle(
          color: isSel ? Colors.black : Colors.black87,
          fontSize: isTransfer ? 11 : 10,
          fontWeight: isTransfer ? FontWeight.bold : FontWeight.w500,
          backgroundColor: Colors.white.withOpacity(0.85),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 10, pos.dy - 6));
    }
  }

  Offset _getPos(MetroStation s, Size size) {
    if (viewMode == MetroViewMode.schematic) {
      return Offset(s.schematicX, s.schematicY);
    } else {
      // Simple relative center
      final dx = (s.longitude - 126.9780) * 8000 + 300;
      final dy = -(s.latitude - 37.5665) * 8000 + 300;
      return Offset(dx.clamp(40.0, size.width - 40), dy.clamp(40.0, size.height - 40));
    }
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return AppTheme.accent;
  }

  @override
  bool shouldRepaint(covariant MetroCanvasPainter oldDelegate) {
    return oldDelegate.viewMode != viewMode ||
        oldDelegate.selectedStation != selectedStation ||
        oldDelegate.lines != lines;
  }
}
