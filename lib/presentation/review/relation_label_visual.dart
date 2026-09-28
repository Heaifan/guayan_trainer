import 'package:flutter/material.dart';

import 'relation_visual_tokens.dart';

/// 关系标签的统一视觉协议。
///
/// 当前生/克、回头生/回头克共用；后续六冲、六合、月破等进入卦盘 Overlay
/// 时也必须复用这里，禁止各自再画一套标签。
abstract final class RelationLabelVisual {
  static TextPainter textPainter(String text, Color color) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: RelationVisualTokens.relationLabelFontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  static Size sizeFor(String text) {
    final painter = textPainter(text, const Color(0xFF243744));
    return Size(
      painter.width + RelationVisualTokens.relationLabelHorizontalPadding,
      RelationVisualTokens.relationLabelHeight,
    );
  }

  static Rect paint(
    Canvas canvas, {
    required String text,
    required Offset center,
    required Color color,
  }) {
    final painter = textPainter(text, color);
    final rect = Rect.fromCenter(
      center: center,
      width: painter.width + RelationVisualTokens.relationLabelHorizontalPadding,
      height: RelationVisualTokens.relationLabelHeight,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(RelationVisualTokens.relationLabelRadius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.alphaBlend(
          color.withValues(alpha: RelationVisualTokens.relationLabelFillOpacity),
          const Color(0xFFFCFDFC),
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(
          alpha: RelationVisualTokens.relationLabelBorderOpacity,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = RelationVisualTokens.relationLabelBorderWidth,
    );
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
    return rect;
  }
}
