import 'dart:math';
import 'package:flutter/material.dart';

/// A single directed edge between two elements on the wheel.
class GenerateEdge {
  final String from;
  final String to;
  const GenerateEdge(this.from, this.to);
}

/// Draws circular-arc arrows along the wheel perimeter.
///
/// Supports two modes:
/// - **Practice** (single animated arrow): [completedEdges] empty,
///   [activeEdge] + [activeProgress] for the current answer.
/// - **Study accumulation** (multiple full arrows + one animated):
///   [completedEdges] drawn fully, [activeEdge] drawn with animation.
class WuxingArrowPainter extends CustomPainter {
  final List<GenerateEdge> completedEdges;
  final GenerateEdge? activeEdge;
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

  Offset _center(String element) {
    final f = _positions[element]!;
    return Offset(f.dx * containerSize, f.dy * containerSize);
  }

  /// Build a circular-arc path from [from] to [to] along the wheel perimeter.
  /// Returns the path and the total arc length.
  (Path, double) _buildArcPath(String from, String to) {
    final center = Offset(containerSize * 0.5, containerSize * 0.5);
    final ringRadius = containerSize * 0.32;
    final nodeRadius = nodeSize / 2;

    final fromPos = _center(from);
    final toPos = _center(to);

    final sourceAngle = atan2(fromPos.dy - center.dy, fromPos.dx - center.dx);
    final targetAngle = atan2(toPos.dy - center.dy, toPos.dx - center.dx);

    // Clockwise sweep
    double sweep = targetAngle - sourceAngle;
    if (sweep < 0) sweep += 2 * pi;

    // Shorten at both ends so arrow goes node-edge to node-edge
    final nodeAngular = nodeRadius / ringRadius;
    final startAngle = sourceAngle + nodeAngular;
    final adjustedSweep = sweep - 2 * nodeAngular;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: ringRadius),
      startAngle,
      adjustedSweep,
    );

    return (path, adjustedSweep * ringRadius);
  }

  /// Position at the end of the arc and its tangent angle (clockwise direction).
  (Offset, double) _arcEndpoint(String from, String to, double progress) {
    final center = Offset(containerSize * 0.5, containerSize * 0.5);
    final ringRadius = containerSize * 0.32;
    final nodeRadius = nodeSize / 2;

    final fromPos = _center(from);
    final toPos = _center(to);

    final sourceAngle = atan2(fromPos.dy - center.dy, fromPos.dx - center.dx);
    final targetAngle = atan2(toPos.dy - center.dy, toPos.dx - center.dx);

    double sweep = targetAngle - sourceAngle;
    if (sweep < 0) sweep += 2 * pi;

    final nodeAngular = nodeRadius / ringRadius;
    final startAngle = sourceAngle + nodeAngular;
    final adjustedSweep = sweep - 2 * nodeAngular;

    final endAngle = startAngle + adjustedSweep * progress.clamp(0.0, 1.0);
    final x = center.dx + ringRadius * cos(endAngle);
    final y = center.dy + ringRadius * sin(endAngle);
    // Clockwise tangent angle = radius angle + π/2
    final tangentAngle = endAngle + pi / 2;

    return (Offset(x, y), tangentAngle);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw all completed edges in full
    for (final edge in completedEdges) {
      _drawArcArrow(canvas, edge.from, edge.to, 1.0, fullHead: true);
    }

    // 2. Draw the active (animating) edge
    if (activeEdge != null && activeProgress > 0.001) {
      final fullHead = activeProgress >= 0.92;
      _drawArcArrow(canvas, activeEdge!.from, activeEdge!.to, activeProgress,
          fullHead: fullHead);
    }
  }

  void _drawArcArrow(
    Canvas canvas,
    String from,
    String to,
    double progress, {
    bool fullHead = false,
  }) {
    // Arc shaft
    final (path, _) = _buildArcPath(from, to);
    final metrics = path.computeMetrics();
    final metric = metrics.first;
    final totalLength = metric.length;
    final drawLength = totalLength * progress;

    final shaftPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (drawLength > 0.5) {
      canvas.drawPath(metric.extractPath(0, drawLength), shaftPaint);
    }

    // Arrowhead
    final headProgress = fullHead ? 1.0 : (progress - 0.85) / 0.15;
    if (headProgress > 0 && drawLength > 1) {
      final (tip, tangentAngle) = _arcEndpoint(from, to, progress);
      final headSize = 13.0 * headProgress.clamp(0.0, 1.0);

      final headPaint = Paint()
        ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      final headPath = Path();
      headPath.moveTo(tip.dx, tip.dy);
      headPath.lineTo(
        tip.dx - headSize * cos(tangentAngle - pi / 7),
        tip.dy - headSize * sin(tangentAngle - pi / 7),
      );
      headPath.lineTo(
        tip.dx - headSize * cos(tangentAngle + pi / 7),
        tip.dy - headSize * sin(tangentAngle + pi / 7),
      );
      headPath.close();
      canvas.drawPath(headPath, headPaint);
    }

    // Start dot (only for animated arrows or when visible enough)
    if (progress > 0.1) {
      final center = Offset(containerSize * 0.5, containerSize * 0.5);
      final ringRadius = containerSize * 0.32;
      final nodeRadius = nodeSize / 2;

      final fromPos = _center(from);
      final toPos = _center(to);
      final srcAngle = atan2(fromPos.dy - center.dy, fromPos.dx - center.dx);
      final tgtAngle = atan2(toPos.dy - center.dy, toPos.dx - center.dx);
      double sweep = tgtAngle - srcAngle;
      if (sweep < 0) sweep += 2 * pi;
      final startAngle = srcAngle + nodeRadius / ringRadius;

      final sx = center.dx + ringRadius * cos(startAngle);
      final sy = center.dy + ringRadius * sin(startAngle);

      final dotPaint = Paint()
        ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(WuxingArrowPainter oldDelegate) {
    return oldDelegate.activeProgress != activeProgress ||
        oldDelegate.completedEdges.length != completedEdges.length ||
        oldDelegate.activeEdge != activeEdge;
  }
}
