import 'dart:math';
import 'package:flutter/material.dart';

/// A single directed edge between two elements on the wheel.
class WuxingEdge {
  final String from;
  final String to;
  const WuxingEdge(this.from, this.to);
}

/// All five generate pairs in clockwise order.
const generateEdges = [
  WuxingEdge('木', '火'),
  WuxingEdge('火', '土'),
  WuxingEdge('土', '金'),
  WuxingEdge('金', '水'),
  WuxingEdge('水', '木'),
];

/// Draws circular-arc arrows along the wheel perimeter.
///
/// [completedEdges] are drawn in full (progress = 1.0).
/// [activeEdge] is drawn with [activeProgress] (animated).
class WuxingArrowPainter extends CustomPainter {
  final List<WuxingEdge> completedEdges;
  final WuxingEdge? activeEdge;
  final double activeProgress;
  final double containerSize;
  final double nodeSize;

  static const _positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  WuxingArrowPainter({
    required this.completedEdges,
    this.activeEdge,
    this.activeProgress = 0,
    required this.containerSize,
    required this.nodeSize,
  });

  Offset _center(String e) => _positions[e]! * containerSize;

  /// Build a circular-arc path from [from] to [to] along the wheel perimeter.
  (Path, double) _buildArcPath(String from, String to) {
    final c = Offset(containerSize * 0.5, containerSize * 0.5);
    final rr = containerSize * 0.32;
    final nr = nodeSize / 2;

    final a1 = atan2(_center(from).dy - c.dy, _center(from).dx - c.dx);
    final a2 = atan2(_center(to).dy - c.dy, _center(to).dx - c.dx);

    double sw = a2 - a1;
    if (sw < 0) sw += 2 * pi;

    final na = nr / rr;
    final path = Path();
    path.addArc(Rect.fromCircle(center: c, radius: rr), a1 + na, sw - 2 * na);
    return (path, (sw - 2 * na) * rr);
  }

  /// Arc endpoint position and clockwise tangent angle.
  (Offset, double) _arcEnd(String from, String to, double p) {
    final c = Offset(containerSize * 0.5, containerSize * 0.5);
    final rr = containerSize * 0.32;
    final nr = nodeSize / 2;

    final a1 = atan2(_center(from).dy - c.dy, _center(from).dx - c.dx);
    final a2 = atan2(_center(to).dy - c.dy, _center(to).dx - c.dx);
    double sw = a2 - a1;
    if (sw < 0) sw += 2 * pi;

    final ea = a1 + nr / rr + (sw - 2 * nr / rr) * p.clamp(0.0, 1.0);
    return (Offset(c.dx + rr * cos(ea), c.dy + rr * sin(ea)), ea + pi / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Completed edges — full arrows
    for (final e in completedEdges) {
      _drawOne(canvas, e.from, e.to, 1.0, fullHead: true);
    }
    // 2. Active (animating) edge
    if (activeEdge != null && activeProgress > 0.001) {
      _drawOne(canvas, activeEdge!.from, activeEdge!.to, activeProgress,
          fullHead: activeProgress >= 0.92);
    }
  }

  void _drawOne(Canvas canvas, String from, String to, double p,
      {bool fullHead = false}) {
    final (path, _) = _buildArcPath(from, to);
    final metric = path.computeMetrics().first;
    final dl = metric.length * p;

    final paint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (dl > 0.5) canvas.drawPath(metric.extractPath(0, dl), paint);

    // Arrowhead
    final hp = fullHead ? 1.0 : (p - 0.85) / 0.15;
    if (hp > 0 && dl > 1) {
      final (tip, ta) = _arcEnd(from, to, p);
      final hs = 13.0 * hp.clamp(0.0, 1.0);
      final hpaint = Paint()
        ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      final hpath = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - hs * cos(ta - pi / 7), tip.dy - hs * sin(ta - pi / 7))
        ..lineTo(tip.dx - hs * cos(ta + pi / 7), tip.dy - hs * sin(ta + pi / 7))
        ..close();
      canvas.drawPath(hpath, hpaint);
    }

    // Start dot
    if (p > 0.1) {
      final c = Offset(containerSize * 0.5, containerSize * 0.5);
      final rr = containerSize * 0.32;
      final nr = nodeSize / 2;
      final a1 = atan2(_center(from).dy - c.dy, _center(from).dx - c.dx);
      final a2 = atan2(_center(to).dy - c.dy, _center(to).dx - c.dx);
      double sw = a2 - a1;
      if (sw < 0) sw += 2 * pi;
      final sx = c.dx + rr * cos(a1 + nr / rr);
      final sy = c.dy + rr * sin(a1 + nr / rr);
      final dp = Paint()
        ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 2.5, dp);
    }
  }

  @override
  bool shouldRepaint(WuxingArrowPainter o) =>
      o.activeProgress != activeProgress ||
      o.completedEdges.length != completedEdges.length;
}
