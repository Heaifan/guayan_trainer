import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../../../presentation/shared/moving_marker.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 六爻排盘单行（审卦首屏 SVG 定稿 · 3c00187 版）。
///
/// 数学上强制三条水平基线（不允许"看起来差不多"）：
/// - 正文基线 RowTop+18：主卦/变卦六亲正文；
/// - 神系基线 RowTop+24：六神 / 伏神 / 世应 / 变卦世应；
/// - 纳音基线 RowTop+34：主卦/变卦纳音。
///
/// 行高固定 48；设计坐标空间宽 402，列左缘冻结：六神18 伏神1·44 伏神2·70
/// 主卦文136 主卦爻212 世应244 动爻260 箭头277 变卦文278 变卦爻368 变卦世应396。
/// 主/变卦文本列宽封顶（74 / 88），超长文本在列缘裁剪（无省略号），
/// 任何情况下不侵占爻槽；整行 FittedBox(contain) 自适应缩放。
class ReviewHexagramLineRow extends StatelessWidget {
  const ReviewHexagramLineRow({
    super.key,
    required this.line,
    this.selected = false,
    this.onTap,
  });

  final ReviewLineView line;
  final bool selected;
  final VoidCallback? onTap;

  static const double _designW = 402;
  static const double _rowH = 48;

  static const double _mainBaseline = 18;
  static const double _naYinBaseline = 34;
  static const double _spiritBaseline = 24;
  static const double _yaoCenterY = 24;

  /// 主卦文本列宽封顶：136 → 210，主卦爻槽 212（留 2px 安全距）。
  static const double _mainTextW = 74;

  /// 变卦文本列宽封顶：278 → 366，变卦爻槽 368（留 2px 安全距）。
  static const double _changedTextW = 88;

  YaoKind get _mainYaoKind {
    if (line.isVoid) return YaoKind.voidYao;
    return line.isYang ? YaoKind.yang : YaoKind.yin;
  }

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: _designW,
      height: _rowH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 六神 / 伏神
          _leftText(18, line.sixSpirit ?? '—', _spiritStyle, _spiritBaseline),
          if (line.hiddenSpirit1 != null || line.hiddenSpirit2 != null) ...[
            if (line.hiddenSpirit1 != null)
              _leftText(44, line.hiddenSpirit1!, _hiddenStyle, _spiritBaseline),
            if (line.hiddenSpirit2 != null)
              _leftText(70, line.hiddenSpirit2!, _hiddenStyle, _spiritBaseline),
          ] else
            _centerText(72, '—', _hiddenStyle, _spiritBaseline),
          
          // 主卦正文 + 纳音（列宽封顶，超长在列缘裁剪，不压爻槽）
          _leftText(136, line.mainPrimary, _linePrimaryStyle, _mainBaseline,
              width: _mainTextW),
          if (line.displayExtra != null && line.displayExtra!.isNotEmpty)
            _leftText(136, line.displayExtra!, _naYinStyle, _naYinBaseline,
                width: _mainTextW),

          // 主卦爻槽
          Positioned(
            left: 212,
            top: _yaoCenterY - YaoGlyph.slotHeight / 2,
            width: YaoGlyph.slotWidth,
            height: YaoGlyph.slotHeight,
            child: YaoGlyph(
              key: Key('yao_glyph_${line.position}'),
              kind: _mainYaoKind,
            ),
          ),
          // 主卦世应
          if (line.shiYing != null)
            _leftText(244, line.shiYing!, _shiYingStyle, _spiritBaseline, textKey: Key('shi_ying_${line.position}')),
            
          // 动爻标记
          if (line.movementType.isMoving)
            Positioned(
              left: 260 - MovingMarker.markerSize / 2,
              top: _yaoCenterY - MovingMarker.markerSize / 2,
              width: MovingMarker.markerSize,
              height: MovingMarker.markerSize,
              child: MovingMarker(
                key: Key('moving_marker_${line.position}'),
                isYin: line.movementType == MovementType.laoYin,
              ),
            ),
            
          // 箭头
          if (line.movementType.isMoving)
            Positioned(
              left: 277,
              top: _yaoCenterY - 6,
              width: 6,
              height: 12,
              child: const _MovingArrow(),
            ),

          // 变卦正文 + 纳音（列宽封顶，超长在列缘裁剪，不压爻槽）
          _leftText(278, line.changed?.primaryLabel ?? '—', _linePrimaryStyle,
              _mainBaseline,
              width: _changedTextW),
          if (line.changed?.displayExtra != null &&
              line.changed!.displayExtra!.isNotEmpty)
            _leftText(
                278, line.changed!.displayExtra!, _naYinStyle, _naYinBaseline,
                width: _changedTextW),

          // 变卦爻槽
          Positioned(
            left: 368,
            top: _yaoCenterY - YaoGlyph.slotHeight / 2,
            width: YaoGlyph.slotWidth,
            height: YaoGlyph.slotHeight,
            child: line.changed?.movementType == null
                ? const SizedBox(
                    width: YaoGlyph.slotWidth,
                    height: YaoGlyph.slotHeight,
                  )
                : YaoGlyph(
                    key: Key('changed_yao_glyph_${line.position}'),
                    kind: line.changed!.isVoid
                        ? YaoKind.voidYao
                        : (line.changed!.isYang
                            ? YaoKind.yang
                            : YaoKind.yin),
                  ),
          ),
          // 变卦世应
          if (line.changedShiYing != null)
            _leftText(396, line.changedShiYing!, _shiYingStyle, _spiritBaseline, textKey: Key('changed_shi_ying_${line.position}')),
        ],
      ),
    );

    final row = Container(
      key: Key('review_line_${line.position}'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE6F0EB) : Colors.transparent,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: content,
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }

  Widget _leftText(
    double left,
    String text,
    TextStyle style,
    double baseline, {
    double? width,
    Key? textKey,
  }) {
    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: Align(
        // 有列宽封顶时左对齐（列左缘即文本起点），否则按内容自适应。
        alignment: width == null ? Alignment.topCenter : Alignment.topLeft,
        child: Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(text, key: textKey, maxLines: 1, style: style),
        ),
      ),
    );
  }

  Widget _centerText(
    double centerX,
    String text,
    TextStyle style,
    double baseline, {
    Key? textKey,
  }) {
    return Positioned(
      left: centerX - 50,
      top: 0,
      width: 100,
      bottom: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(text, key: textKey, maxLines: 1, textAlign: TextAlign.center, style: style),
        ),
      ),
    );
  }

  static const TextStyle _spiritStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF9A7B45),
    height: 1.2,
  );

  static const TextStyle _hiddenStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: Color(0xFF71838B),
    height: 1.2,
  );

  static const TextStyle _linePrimaryStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF243744),
    height: 1.2,
  );

  static const TextStyle _naYinStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF71838B),
    height: 1.2,
  );

  static const TextStyle _shiYingStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: Color(0xFFB66F6F),
    height: 1.2,
  );
}

/// 动爻箭头（→，矢量，arrowTeal #4F8685 w1.4 圆头）。
class _MovingArrow extends StatelessWidget {
  const _MovingArrow();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(6, 12),
      painter: _ArrowPainter(),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CastingTokens.arrowTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0.5, cy), Offset(size.width - 2.5, cy), paint);
    final head = Path()
      ..moveTo(size.width - 4.5, cy - 3)
      ..lineTo(size.width - 0.5, cy)
      ..lineTo(size.width - 4.5, cy + 3);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
