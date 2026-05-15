import 'dart:math';
import 'package:flutter/material.dart';

/// A single directed edge between two elements on the wheel.
class GenerateEdge {
  final String from;
  final String to;
  const GenerateEdge(this.from, this.to);
}

/// Draws curved arrows on the five-element wheel.
///
/// Supports two modes:
/// - **Practice**: draw a single animated arrow ([completedEdges] empty,
///   [activeEdge] + [activeProgress] for the current answer).
/// - **Study accumulation**: draw multiple full arrows ([completedEdges])
///   plus one animated arrow ([activeEdge] + [activeProgress]).
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

  Offset? _center(String element) {
    final f = _positions[element];
    if (f == null) return null;
    return Offset(f.dx * containerSize, f.dy * containerSize);
  }

  /// Build a curved bezier path from [from] node edge to [to] node edge.
  (Path, double) _buildEdgePath(String from, String to) {
    final fromCenter = _center(from);
    final toCenter = _center(to);
    if (fromCenter == null || toCenter == null) return (Path(), 0);

    final nodeRadius = nodeSize / 2;
    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 0.001) return (Path(), 0);

    final nx = dx / dist;
    final ny = dy / dist;

    final start = Offset(fromCenter.dx + nx * nodeRadius, fromCenter.dy + ny * nodeRadius);
    final end = Offset(toCenter.dx - nx * nodeRadius, toCenter.dy - ny * nodeRadius);

    final wheelCenter = Offset(containerSize * 0.5, containerSize * 0.5);
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final outwardX = mid.dx - wheelCenter.dx;
    final outwardY = mid.dy - wheelCenter.dy;
    final outwardDist = sqrt(outwardX * outwardX + outwardY * outwardY);
    final push = containerSize * 0.12;
    final controlX = mid.dx + (outwardDist > 0.001 ? outwardX / outwardDist * push : push);
    final controlY = mid.dy + (outwardDist > 0.001 ? outwardY / outwardDist * push : push);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlX, controlY, end.dx, end.dy);

    return (path, dist);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw completed edges as full arrows
    for (final edge in completedEdges) {
      _drawArrow(canvas, edge.from, edge.to, 1.0, fullArrowhead: true);
    }

    // 2. Draw active edge with animation progress
    if (activeEdge != null) {
      _drawArrow(canvas, activeEdge!.from, activeEdge!.to, activeProgress,
          fullArrowhead: activeProgress > 0.85);
    }
  }

  void _drawArrow(Canvas canvas, String from, String to, double progress,
      {bool fullArrowhead = false}) {
    if (progress <= 0.001) return;

    final (path, dist) = _buildEdgePath(from, to);
    if (dist < 0.001) return;

    final metrics = path.computeMetrics();
    final metric = metrics.first;
    final totalLength = metric.length;
    final drawLength = totalLength * progress.clamp(0.0, 1.0);

    // Draw arrow shaft
    final arrowPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (drawLength > 0.5) {
      canvas.drawPath(metric.extractPath(0, drawLength), arrowPaint);
    }

    // Draw arrowhead
    final headProgress = fullArrowhead ? 1.0 : (progress - 0.85) / 0.15;
    if (headProgress > 0 && drawLength > 1) {
      final tangent = metric.getTangentForOffset(drawLength.clamp(0, totalLength));
      if (tangent != null) {
        final headSize = 13.0 * headProgress.clamp(0.0, 1.0);
        final angle = tangent.angle;
        final tip = tangent.position;

        final headPaint = Paint()
          ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

        final headPath = Path();
        headPath.moveTo(tip.dx, tip.dy);
        headPath.lineTo(
          tip.dx - headSize * cos(angle - pi / 7),
          tip.dy - headSize * sin(angle - pi / 7),
        );
        headPath.lineTo(
          tip.dx - headSize * cos(angle + pi / 7),
          tip.dy - headSize * sin(angle + pi / 7),
        );
        headPath.close();
        canvas.drawPath(headPath, headPaint);
      }
    }

    // Start dot
    if (progress == 1.0 || progress > 0.1) {
      final fromCenter = _center(from);
      final toCenter = _center(to);
      if (fromCenter != null && toCenter != null) {
        final nodeRadius = nodeSize / 2;
        final dx = toCenter.dx - fromCenter.dx;
        final dy = toCenter.dy - fromCenter.dy;
        final d = sqrt(dx * dx + dy * dy);
        if (d > 0.001) {
          final start = Offset(
            fromCenter.dx + dx / d * nodeRadius,
            fromCenter.dy + dy / d * nodeRadius,
          );
          final dotPaint = Paint()
            ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.55)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(start, 2.5, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(WuxingArrowPainter oldDelegate) {
    return oldDelegate.activeProgress != activeProgress ||
        oldDelegate.completedEdges.length != completedEdges.length ||
        oldDelegate.activeEdge != activeEdge;
  }
}
