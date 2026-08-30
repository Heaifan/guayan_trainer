import 'package:flutter/material.dart';

import '../../domain/line_state.dart';
import '../casting/casting_tokens.dart';

/// 动爻标记统一组件（GUAYAN-2.0-UI-CORRECTION-R2 冻结规格）。
///
/// 老阴 → 空心圆 ○（stroke #A17F45 w1.7）
/// 老阳 → ×（stroke #567866 w1.7，圆头）
///
/// Bounding Box 固定 12 × 12 DIP，两者必须完全一致。
/// 排卦页与审卦页必须统一复用本组件，禁止各自另画一套。
class MovingMarker extends StatelessWidget {
  /// 显式指定类型（老阴 true / 老阳 false）。
  const MovingMarker({super.key, required this.isYin});

  /// 老阴（空心圆）。
  const MovingMarker.oldYin({super.key}) : isYin = true;

  /// 老阳（×）。
  const MovingMarker.oldYang({super.key}) : isYin = false;

  /// 便捷工厂：由 [MovementType] 推导（仅动爻使用）。
  static MovingMarker of(MovementType type) => type == MovementType.laoYin
      ? const MovingMarker.oldYin()
      : const MovingMarker.oldYang();

  final bool isYin;

  /// 动爻标记外部尺寸（冻结，不得更改）。
  static const double markerSize = 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: markerSize,
      height: markerSize,
      child: CustomPaint(painter: _MovingMarkerPainter(isYin)),
    );
  }
}

class _MovingMarkerPainter extends CustomPainter {
  const _MovingMarkerPainter(this.isYin);

  final bool isYin;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    if (isYin) {
      stroke.color = CastingTokens.spiritGold;
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2, stroke);
    } else {
      stroke.color = CastingTokens.accent;
      canvas.drawLine(Offset(0, 0), Offset(w, h), stroke);
      canvas.drawLine(Offset(w, 0), Offset(0, h), stroke);
    }
  }

  @override
  bool shouldRepaint(_MovingMarkerPainter oldDelegate) =>
      oldDelegate.isYin != isYin;
}
