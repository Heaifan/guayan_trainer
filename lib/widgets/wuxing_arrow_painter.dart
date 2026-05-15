import 'dart:math';
import 'package:flutter/material.dart';

/// Draws an animated arrow from [sourceElement] to [targetElement] on the
/// five-element wheel, using the same node positions as [WuxingWheel].
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

  Offset _center(String element) {
    final f = _positions[element]!;
    return Offset(f.dx * containerSize, f.dy * containerSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final from = _center(sourceElement);
    final to = _center(targetElement);
    final paint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final totalDist = sqrt(dx * dx + dy * dy);

    // Animate: draw line from source toward target
    final drawnDist = totalDist * progress;
    final ratio = drawnDist / totalDist;
    final lineEnd = Offset(from.dx + dx * ratio, from.dy + dy * ratio);

    // Draw the line segment
    canvas.drawLine(from, lineEnd, paint);

    // Draw arrowhead when progress is near complete (last 15%)
    if (progress > 0.85) {
      final arrowProgress = (progress - 0.85) / 0.15; // 0→1 in the tail
      final headSize = 12.0 * arrowProgress;

      if (headSize > 1) {
        final angle = atan2(dy, dx);
        final arrowPaint = Paint()
          ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(lineEnd.dx, lineEnd.dy);
        path.lineTo(
          lineEnd.dx - headSize * cos(angle - pi / 6),
          lineEnd.dy - headSize * sin(angle - pi / 6),
        );
        path.lineTo(
          lineEnd.dx - headSize * cos(angle + pi / 6),
          lineEnd.dy - headSize * sin(angle + pi / 6),
        );
        path.close();
        canvas.drawPath(path, arrowPaint);
      }
    }

    // Draw start circle
    final startPaint = Paint()
      ..color = const Color(0xFF2F6F5E).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(from, 4.0, startPaint);
  }

  @override
  bool shouldRepaint(WuxingArrowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
