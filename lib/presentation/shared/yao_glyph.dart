import 'package:flutter/material.dart';

import '../../domain/line_state.dart';
import '../casting/casting_tokens.dart';

/// 爻象统一绘制组件（GUAYAN-2.0-UI-CORRECTION-R2 冻结规格）。
///
/// 爻槽外部尺寸固定 24 × 6 DIP：
/// - [YaoKind.yang]：24 × 6 实心；
/// - [YaoKind.yin]：左 8 × 6 + 右 8 × 6（中间 8 空）；
/// - [YaoKind.voidYao]：24 × 6 空心描边（rx 1，stroke #7E9098 w1.5）。
///
/// 三种状态宽度 / 高度 / 基线 / 占位完全一致，只允许内部填充方式不同。
/// 排卦页与审卦页必须统一复用本组件，禁止各自另画一套。
enum YaoKind { yang, yin, voidYao }

class YaoGlyph extends StatelessWidget {
  const YaoGlyph({super.key, required this.kind});

  /// 空亡爻（旬空）。
  const YaoGlyph.voidYao({super.key}) : kind = YaoKind.voidYao;

  /// 便捷工厂：由 [MovementType] 推导（老阴/少阴 → 阴，老阳/少阳 → 阳）。
  static YaoGlyph fromMovement(MovementType type) =>
      (type == MovementType.shaoYang || type == MovementType.laoYang)
          ? const YaoGlyph(kind: YaoKind.yang)
          : const YaoGlyph(kind: YaoKind.yin);

  /// 爻槽外部尺寸（冻结，不得更改）。
  static const double slotWidth = 24;
  static const double slotHeight = 6;

  final YaoKind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: slotWidth,
      height: slotHeight,
      child: CustomPaint(painter: _YaoSlotPainter(kind)),
    );
  }
}

class _YaoSlotPainter extends CustomPainter {
  const _YaoSlotPainter(this.kind);

  final YaoKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = CastingTokens.yao;
    switch (kind) {
      case YaoKind.yang:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          fill,
        );
      case YaoKind.yin:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width / 3, size.height),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTWH(size.width * 2 / 3, 0, size.width / 3, size.height),
          fill,
        );
      case YaoKind.voidYao:
        final stroke = Paint()
          ..color = CastingTokens.voidYaoStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
            const Radius.circular(1),
          ),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(_YaoSlotPainter oldDelegate) => oldDelegate.kind != kind;
}
