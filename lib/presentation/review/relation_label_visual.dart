import 'package:flutter/material.dart';

import 'relation_visual_tokens.dart';

/// 关系标签统一视觉协议：只保留文字，不绘制胶囊底色或边框。
abstract final class RelationLabelVisual {
  static TextPainter textPainter(String text, Color color) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: RelationVisualTokens.relationLabelFontSize,
        fontWeight: FontWeight.w500,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  static Size sizeFor(String text) {
    final painter = textPainter(text, const Color(0xFF243744));
    final height = painter.height > RelationVisualTokens.relationLabelHeight
        ? painter.height
        : RelationVisualTokens.relationLabelHeight;
    return Size(
      painter.width + RelationVisualTokens.relationLabelHorizontalPadding,
      height,
    );
  }

  static Rect paint(
    Canvas canvas, {
    required String text,
    required Offset center,
    required Color color,
  }) {
    final painter = textPainter(text, color);
    final size = sizeFor(text);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
    return rect;
  }
}
