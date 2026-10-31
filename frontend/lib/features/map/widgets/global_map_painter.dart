import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';

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

