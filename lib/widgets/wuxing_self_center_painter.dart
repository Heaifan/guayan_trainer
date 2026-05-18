import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws arrows and center ring for the self-center wheel.
class WuxingSelfCenterPainter extends CustomPainter {
  final double centerRadius;
  final double outerRadius;
  final bool showArrows;
  final String? activeRelation;

  const WuxingSelfCenterPainter({
    required this.centerRadius,
    required this.outerRadius,
    this.showArrows = true,
    this.activeRelation,
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
      '生我': Offset(s * 0.50, s * 0.20),
      '我生': Offset(s * 0.78, s * 0.50),
      '我克': Offset(s * 0.50, s * 0.80),
      '克我': Offset(s * 0.22, s * 0.50),
    };

    // Faint guide circle
    canvas.drawCircle(c, s * 0.32,
        Paint()
          ..color = const Color(0xFFE0C28A).withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    if (!showArrows) return;

    // Draw only the active arrow if specified, otherwise all four
    final arrowSpecs = [
      ('生我', pos['生我']!, c, _generateIn, false),
      ('我生', pos['我生']!, c, _generateOut, true),
      ('克我', pos['克我']!, c, _controlIn, false),
      ('我克', pos['我克']!, c, _controlOut, true),
    ];

    for (final (rel, from, to, color, fromCenter) in arrowSpecs) {
      if (activeRelation != null && rel != activeRelation) continue;
      if (fromCenter) {
        _drawArrow(canvas, to, from, color, centerRadius + 8, outerRadius + 4,
            dashed: rel == '我克');
      } else {
        _drawArrow(canvas, from, to, color, outerRadius + 4, centerRadius + 8);
      }
    }

    // Center double ring (always show when arrows visible)
    final rr = centerRadius;
    canvas.drawCircle(c, rr + 4,
        Paint()..color = _ringColor.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawCircle(c, rr - 2,
        Paint()..color = _ringColor.withValues(alpha: 0.45)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color,
      double startR, double endR,
      {double strokeWidth = 2.8, bool dashed = false}) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final ux = dx / dist;
    final uy = dy / dist;

    final sx = from.dx + ux * startR;
    final sy = from.dy + uy * startR;
    final ex = to.dx - ux * endR;
    final ey = to.dy - uy * endR;

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
        dashPath.lineTo(sx + (ex - sx) * t0, sy + (ey - sy) * t0);
        dashPath.lineTo(sx + (ex - sx) * t1.clamp(0, 1), sy + (ey - sy) * t1.clamp(0, 1));
        d += dash + gap;
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
    }

    final angle = math.atan2(ey - sy, ex - sx);
    final hs = 11.0;
    final hpath = Path()
      ..moveTo(ex, ey)
      ..lineTo(ex - hs * math.cos(angle - 0.5), ey - hs * math.sin(angle - 0.5))
      ..lineTo(ex - hs * math.cos(angle + 0.5), ey - hs * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(hpath, Paint()..color = color.withValues(alpha: 0.85)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
