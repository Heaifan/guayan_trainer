import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';

/// Draws the five-pointed star control lines ("克") between wuxing nodes.
///
/// Lines:
///   木→土  土→水  水→火  火→金  金→木
class WuxingControlPainter extends CustomPainter {
  final double containerSize;
  final double nodeSize;

  const WuxingControlPainter({
    required this.containerSize,
    required this.nodeSize,
  });

  static const Map<String, Offset> positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  /// Control pairs  (克 relations).
  static const _controlPairs = [
    ('木', '土'),
    ('土', '水'),
    ('水', '火'),
    ('火', '金'),
    ('金', '木'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9C3B2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = const Color(0xFF9C3B2E)
      ..style = PaintingStyle.fill;

    for (final (from, to) in _controlPairs) {
      final p1 = _center(from);
      final p2 = _center(to);
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist == 0) continue;

      // Shorten by node radius on both ends
      final nr = nodeSize / 2;
      final ux = dx / dist;
      final uy = dy / dist;
      final sx = p1.dx + ux * nr;
      final sy = p1.dy + uy * nr;
      final ex = p2.dx - ux * nr;
      final ey = p2.dy - uy * nr;

      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);

      // Arrowhead at endpoint
      final angle = math.atan2(ey - sy, ex - sx);
      final hs = 12.0;
      final hx = ex;
      final hy = ey;
      final ha = angle;
      final hpath = Path()
        ..moveTo(hx, hy)
        ..lineTo(hx - hs * math.cos(ha - 0.45), hy - hs * math.sin(ha - 0.45))
        ..lineTo(hx - hs * math.cos(ha + 0.45), hy - hs * math.sin(ha + 0.45))
        ..close();
      canvas.drawPath(hpath, arrowPaint);
    }
  }

  Offset _center(String e) => positions[e]! * containerSize;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
