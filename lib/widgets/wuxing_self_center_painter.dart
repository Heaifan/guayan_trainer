import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws the four directional arrows and center ring for the self-center wheel.
class WuxingSelfCenterPainter extends CustomPainter {
  final String self;

  const WuxingSelfCenterPainter({required this.self});

  static const _positions = {
    '生我': Offset(0.50, 0.16),
    '我生': Offset(0.84, 0.50),
    '我克': Offset(0.50, 0.84),
    '克我': Offset(0.16, 0.50),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final nr = size.width * 0.09; // node radius for offset

    // Helper: draw arrow from -> to
    void drawArrow(Offset from, Offset to, Color color, {double width = 3}) {
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 1) return;
      final ux = dx / dist;
      final uy = dy / dist;

      // Shorten by node radius
      final sx = from.dx + ux * nr;
      final sy = from.dy + uy * nr;
      final ex = to.dx - ux * nr;
      final ey = to.dy - uy * nr;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      // Draw dashed for 我克
      if (color == const Color(0xFF8A6A32)) {
        final dashPath = Path();
        dashPath.moveTo(sx, sy);
        final len = dist - nr * 2;
        const dash = 6.0;
        const gap = 4.0;
        double d = 0;
        while (d < len) {
          final t0 = d / len;
          final t1 = (d + dash) / len;
          final px = sx + (ex - sx) * t0;
          final py = sy + (ey - sy) * t0;
          final qx = sx + (ex - sx) * t1.clamp(0.0, 1.0);
          final qy = sy + (ey - sy) * t1.clamp(0.0, 1.0);
          dashPath.lineTo(px, py);
          dashPath.lineTo(qx, qy);
          d += dash + gap;
        }
        canvas.drawPath(dashPath, paint);
      } else {
        canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
      }

      // Arrowhead
      final angle = math.atan2(ey - sy, ex - sx);
      final hs = 12.0;
      final ha = angle;
      final hx = ex;
      final hy = ey;
      final hpath = Path()
        ..moveTo(hx, hy)
        ..lineTo(hx - hs * math.cos(ha - 0.5), hy - hs * math.sin(ha - 0.5))
        ..lineTo(hx - hs * math.cos(ha + 0.5), hy - hs * math.sin(ha + 0.5))
        ..close();
      canvas.drawPath(hpath, Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill);
    }

    final s = size.width;

    // 生我 (green, outer → center)
    drawArrow(Offset(s * 0.50, s * 0.16), c, const Color(0xFF2F8F5B));

    // 我生 (orange-red, center → outer)
    drawArrow(c, Offset(s * 0.84, s * 0.50), const Color(0xFFC65A2E));

    // 克我 (deep red, outer → center)
    drawArrow(Offset(s * 0.16, s * 0.50), c, const Color(0xFF8A3A2A));

    // 我克 (brown, center → outer, dashed)
    drawArrow(c, Offset(s * 0.50, s * 0.84), const Color(0xFF8A6A32));

    // Center double ring (同我 / 旺)
    final rr = s * 0.14;
    final ringPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(c, rr, ringPaint);

    final innerRing = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(c, rr - 5, innerRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
