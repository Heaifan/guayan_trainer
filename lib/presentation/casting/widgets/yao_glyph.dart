import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../casting_tokens.dart';

/// 一爻矢量图形（任务书 §10 动爻符号，禁止 Unicode ○/× 充当图标）。
///
/// - 阳爻：整段实线；阴爻：两段断线；
/// - 老阴（动）：爻线右侧空心圆（#B0905F）；
/// - 老阳（动）：爻线右侧 X（#567866）。
/// 爻线宽度自适应父级约束，动爻标记固定占右侧 26 逻辑像素。
class YaoGlyph extends StatelessWidget {
  const YaoGlyph({super.key, required this.movementType});

  final MovementType movementType;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _YaoPainter(movementType),
    );
  }
}

class _YaoPainter extends CustomPainter {
  _YaoPainter(this.movementType);

  final MovementType movementType;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const markW = 26.0;
    final lineW = size.width - markW;
    if (lineW <= 0) return;

    final linePaint = Paint()
      ..color = CastingTokens.yao
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final yang = movementType == MovementType.shaoYang ||
        movementType == MovementType.laoYang;
    if (yang) {
      canvas.drawLine(Offset(0, cy), Offset(lineW, cy), linePaint);
    } else {
      final gap = lineW * 0.14;
      canvas.drawLine(Offset(0, cy), Offset(lineW / 2 - gap / 2, cy), linePaint);
      canvas.drawLine(
          Offset(lineW / 2 + gap / 2, cy), Offset(lineW, cy), linePaint);
    }

    if (movementType.isMoving) {
      final cx = lineW + markW / 2;
      if (movementType == MovementType.laoYin) {
        final circle = Paint()
          ..color = CastingTokens.movingCircle
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        canvas.drawCircle(Offset(cx, cy), 6, circle);
      } else {
        final x = Paint()
          ..color = CastingTokens.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.square;
        canvas.drawLine(Offset(cx - 5, cy - 8), Offset(cx + 5, cy + 8), x);
        canvas.drawLine(Offset(cx + 5, cy - 8), Offset(cx - 5, cy + 8), x);
      }
    }
  }

  @override
  bool shouldRepaint(_YaoPainter oldDelegate) =>
      oldDelegate.movementType != movementType;
}
