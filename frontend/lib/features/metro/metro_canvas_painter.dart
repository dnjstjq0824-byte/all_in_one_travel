import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';

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
      ..color = Colors.grey.withValues(alpha: 0.08)
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
          ..color = Colors.black.withValues(alpha: 0.12)
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
          backgroundColor: Colors.white.withValues(alpha: 0.85),
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
