import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'wuxing_arrow_painter.dart';

/// Draws pentagram-style control arrows.
///
/// - Faint background: all 5 lines as a reference map
/// - Active: one highlighted arrow for the current relation
class WuxingControlArrowPainter extends CustomPainter {
  final WuxingEdge? activeEdge;
  final double activeProgress;
  final double containerSize;
  final double nodeSize;
  final bool showBaseLines;
  final bool showActiveArrow;

  const WuxingControlArrowPainter({
    this.activeEdge,
    this.activeProgress = 0,
    required this.containerSize,
    required this.nodeSize,
    this.showBaseLines = true,
    this.showActiveArrow = true,
  });

  static const _positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  /// All five control pairs in order.
  static const _allPairs = [
    ('木', '土'),
    ('土', '水'),
    ('水', '火'),
    ('火', '金'),
    ('金', '木'),
  ];

  static const _activeColor = Color(0xFF9C3B2E);
  static const _faintColor = Color(0x2E9C3B2E); // opacity ~0.18

  Offset _center(String e) => _positions[e]! * containerSize;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Faint background pentagram (all 5 lines)
    if (showBaseLines) {
    for (final (from, to) in _allPairs) {
      final p1 = _center(from);
      final p2 = _center(to);
      final nr = nodeSize / 2;
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist == 0) continue;
      final ux = dx / dist;
      final uy = dy / dist;
      final sx = p1.dx + ux * nr;
      final sy = p1.dy + uy * nr;
      final ex = p2.dx - ux * nr;
      final ey = p2.dy - uy * nr;

      final isActive = activeEdge != null &&
          from == activeEdge!.from &&
          to == activeEdge!.to;

      if (!isActive) {
        final fpaint = Paint()
          ..color = _faintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(sx, sy), Offset(ex, ey), fpaint);
      }
    }

    } // end showBaseLines

    // 2. Active arrow (animated)
    if (!showActiveArrow || activeEdge == null || activeProgress <= 0.001) return;
    _drawOne(canvas, activeEdge!.from, activeEdge!.to, activeProgress,
        fullHead: activeProgress >= 0.92);
  }

  void _drawOne(Canvas canvas, String from, String to, double p,
      {bool fullHead = false}) {
    final p1 = _center(from);
    final p2 = _center(to);
    final nr = nodeSize / 2;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    final sx = p1.dx + ux * nr;
    final sy = p1.dy + uy * nr;
    final ex = p2.dx - ux * nr;
    final ey = p2.dy - uy * nr;
    final cex = sx + (ex - sx) * p;
    final cey = sy + (ey - sy) * p;

    final paint = Paint()
      ..color = _activeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(sx, sy), Offset(cex, cey), paint);

    final hp = fullHead ? 1.0 : (p - 0.85) / 0.15;
    if (hp > 0) {
      final angle = math.atan2(ey - sy, ex - sx);
      final hs = 13.0 * hp.clamp(0.0, 1.0);
      final hpaint = Paint()
        ..color = _activeColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      final hpath = Path()
        ..moveTo(cex, cey)
        ..lineTo(cex - hs * math.cos(angle - math.pi / 7),
            cey - hs * math.sin(angle - math.pi / 7))
        ..lineTo(cex - hs * math.cos(angle + math.pi / 7),
            cey - hs * math.sin(angle + math.pi / 7))
        ..close();
      canvas.drawPath(hpath, hpaint);
    }

    if (p > 0.1) {
      final dp = Paint()
        ..color = _activeColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 2.5, dp);
    }
  }

  @override
  bool shouldRepaint(WuxingControlArrowPainter o) =>
      o.activeProgress != activeProgress || o.activeEdge != activeEdge;
}
