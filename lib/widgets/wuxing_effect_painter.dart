import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a flame/fire effect for the 木→火 relationship.
/// Positioned at a given center point with animated flickering.
class FlameEffectPainter extends CustomPainter {
  final Offset center;
  final double size;
  final double opacity;

  FlameEffectPainter({
    required this.center,
    required this.size,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final alpha = (opacity * 255).round().clamp(0, 255);

    // Spark dots floating upward
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (int i = 0; i < 5; i++) {
      final phase = t * 1.5 + i * 1.2;
      final floatY = -sin(phase) * size * 0.3 - size * 0.1;
      final driftX = cos(phase * 0.7 + i) * size * 0.15;
      final sparkAlpha = ((0.6 + 0.4 * sin(phase + 2)) * alpha).round().clamp(0, 255);

      sparkPaint.color = Color.fromARGB(sparkAlpha, 250, 210, 1);
      final r = (1.5 + sin(phase * 0.5 + i * 2) * 0.5).clamp(0.5, 2.5);
      canvas.drawCircle(
        Offset(center.dx + driftX, center.dy + floatY),
        r,
        sparkPaint,
      );
    }

    // Flame shapes (red → orange → yellow, overlapping)
    final flames = [
      _FlameLayer(0.0, const Color(0xFFD9381E), 1.0),   // outer red
      _FlameLayer(0.15, const Color(0xFFF27D0C), 0.75),  // mid orange
      _FlameLayer(0.3, const Color(0xFFFAD201), 0.5),    // inner yellow
    ];

    for (final layer in flames) {
      final flicker = 1.0 + 0.04 * sin(t * 3 + layer.offset * 10);
      final w = size * layer.widthRatio * flicker;
      final h = size * 1.1 * flicker;
      final layerAlpha = (layer.widthRatio * alpha).round().clamp(0, alpha);

      final path = Path();
      // Flame teardrop shape: starts at bottom, curves up to a point
      final flameTop = center.dy - h * 0.7;
      final flameBottom = center.dy + h * 0.3;

      path.moveTo(center.dx, flameTop);
      path.cubicTo(
        center.dx + w * 0.3, center.dy - h * 0.2,
        center.dx + w * 0.6, center.dy - h * 0.05,
        center.dx + w * 0.4, flameBottom * 0.7,
      );
      path.cubicTo(
        center.dx + w * 0.25, flameBottom * 0.85,
        center.dx - w * 0.25, flameBottom * 0.85,
        center.dx - w * 0.4, flameBottom * 0.7,
      );
      path.cubicTo(
        center.dx - w * 0.6, center.dy - h * 0.05,
        center.dx - w * 0.3, center.dy - h * 0.2,
        center.dx, flameTop,
      );
      path.close();

      final flamePaint = Paint()
        ..color = Color.fromARGB(layerAlpha, layer.color.r.toInt(), layer.color.g.toInt(), layer.color.b.toInt())
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, flamePaint);
    }

    // Glow around the flame
    final glowPaint = Paint()
      ..color = const Color(0xFFF27D0C).withValues(alpha: 0.15 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center + Offset(0, -size * 0.2), size * 0.5, glowPaint);
  }

  @override
  bool shouldRepaint(FlameEffectPainter oldDelegate) => true;
}

class _FlameLayer {
  final double offset;
  final Color color;
  final double widthRatio;

  const _FlameLayer(this.offset, this.color, this.widthRatio);
}
