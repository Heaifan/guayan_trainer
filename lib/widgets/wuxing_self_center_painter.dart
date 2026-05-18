import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/wuxing_self_center_data.dart';

/// Draws four directional arrows and center double ring for the self-center wheel.
class WuxingSelfCenterPainter extends CustomPainter {
  final double centerRadius;
  final double outerRadius;

  const WuxingSelfCenterPainter({
    required this.centerRadius,
    required this.outerRadius,
  });

  static const _generateIn = Color(0xFF2F8F5B);
  static const _generateOut = Color(0xFFC65A2E);
  static const _controlIn = Color(0xFF8A3A2A);
  static const _controlOut = Color(0xFF8A6A32);
  static const _ringColor = Color(0xFF2F6F5E);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.width;

    final pos = {
      '生我': Offset(s * 0.50, s * 0.18),
      '我生': Offset(s * 0.82, s * 0.50),
      '我克': Offset(s * 0.50, s * 0.80),
      '克我': Offset(s * 0.22, s * 0.50),
    };

    // Faint guide circle
    canvas.drawCircle(c, s * 0.32,
        Paint()
          ..color = const Color(0xFFE0C28A).withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Arrows
    _drawArrow(canvas, pos['生我']!, c, _generateIn, outerRadius + 4, centerRadius + 8);
    _drawArrow(canvas, c, pos['我生']!, _generateOut, centerRadius + 8, outerRadius + 4);
    _drawArrow(canvas, pos['克我']!, c, _controlIn, outerRadius + 4, centerRadius + 8, strokeWidth: 3.2);
    _drawArrow(canvas, c, pos['我克']!, _controlOut, centerRadius + 8, outerRadius + 4, dashed: true);

    // Center double ring
    final rr = centerRadius;
    canvas.drawCircle(c, rr + 4,
        Paint()
          ..color = _ringColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.drawCircle(c, rr - 2,
        Paint()
          ..color = _ringColor.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color,
      double startRadius, double endRadius,
      {double strokeWidth = 2.8, bool dashed = false}) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final ux = dx / dist;
    final uy = dy / dist;

    final sx = from.dx + ux * startRadius;
    final sy = from.dy + uy * startRadius;
    final ex = to.dx - ux * endRadius;
    final ey = to.dy - uy * endRadius;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (dashed) {
      final dashPath = Path();
      dashPath.moveTo(sx, sy);
      const dash = 6.0;
      const gap = 5.0;
      final len = math.sqrt((ex - sx) * (ex - sx) + (ey - sy) * (ey - sy));
      var d = 0.0;
      while (d < len) {
        final t0 = d / len;
        final t1 = (d + dash) / len;
        dashPath.lineTo(
            sx + (ex - sx) * t0, sy + (ey - sy) * t0);
        dashPath.lineTo(
            sx + (ex - sx) * t1.clamp(0, 1), sy + (ey - sy) * t1.clamp(0, 1));
        d += dash + gap;
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
    }

    // Arrowhead
    final angle = math.atan2(ey - sy, ex - sx);
    final hs = 11.0;
    final hpath = Path()
      ..moveTo(ex, ey)
      ..lineTo(ex - hs * math.cos(angle - 0.5), ey - hs * math.sin(angle - 0.5))
      ..lineTo(ex - hs * math.cos(angle + 0.5), ey - hs * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(hpath, Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
