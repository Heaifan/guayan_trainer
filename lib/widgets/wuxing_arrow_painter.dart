import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a curved animated arrow from [sourceElement] to [targetElement] on the
/// five-element wheel. The arrow follows a bezier curve outward from the wheel
/// center and goes from node edge to node edge with a proper arrowhead.
class WuxingArrowPainter extends CustomPainter {
  final String sourceElement;
  final String targetElement;
  final double progress;
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
    required this.sourceElement,
    required this.targetElement,
    required this.progress,
    required this.containerSize,
    required this.nodeSize,
  });

  Offset? _center(String element) {
    final f = _positions[element];
    if (f == null) return null;
    return Offset(f.dx * containerSize, f.dy * containerSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fromCenter = _center(sourceElement);
    final toCenter = _center(targetElement);
    if (fromCenter == null || toCenter == null) return;

    final nodeRadius = nodeSize / 2;
    final pw = containerSize; // shorthand

    // Direction from source to target (normalized)
    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 0.001) return;

    final nx = dx / dist;
    final ny = dy / dist;

    // Edge points: start at source perimeter toward target, end at target perimeter
    final start = Offset(fromCenter.dx + nx * nodeRadius, fromCenter.dy + ny * nodeRadius);
    final end = Offset(toCenter.dx - nx * nodeRadius, toCenter.dy - ny * nodeRadius);

    // Control point: outward from wheel center for a nice arc
    final wheelCenter = Offset(pw * 0.5, pw * 0.5);
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final outwardX = mid.dx - wheelCenter.dx;
    final outwardY = mid.dy - wheelCenter.dy;
    final outwardDist = sqrt(outwardX * outwardX + outwardY * outwardY);
    final push = pw * 0.12;
    final controlX = mid.dx + (outwardDist > 0.001 ? outwardX / outwardDist * push : push);
    final controlY = mid.dy + (outwardDist > 0.001 ? outwardY / outwardDist * push : push);
    final control = Offset(controlX, controlY);

    // Build bezier path
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    // Animate via path metrics
    final metrics = path.computeMetrics();
    final metric = metrics.first;
    final totalLength = metric.length;
    final drawLength = totalLength * progress.clamp(0.0, 1.0);

    final arrowPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    if (drawLength > 0.5) {
      final extractPath = metric.extractPath(0, drawLength);
      canvas.drawPath(extractPath, arrowPaint);
    }

    // Arrowhead at the end
    final arrowProgress = (progress - 0.85) / 0.15;
    if (arrowProgress > 0 && drawLength > 1) {
      final tangent = metric.getTangentForOffset(drawLength.clamp(0, totalLength));
      if (tangent != null) {
        final headSize = 14.0 * arrowProgress.clamp(0.0, 1.0);
        final angle = tangent.angle;
        final tip = tangent.position;

        final headPaint = Paint()
          ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.88)
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

    // Small dot at arrow start
    final dotPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(WuxingArrowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sourceElement != sourceElement ||
        oldDelegate.targetElement != targetElement;
  }
}
