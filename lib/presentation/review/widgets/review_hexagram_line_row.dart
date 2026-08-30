import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../../../presentation/shared/moving_marker.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 六爻排盘单行（审卦首屏 R3 舒适紧凑版：48 DIP 行高）。
///
/// 冻结 11 列：六神 | 伏神1 | 伏神2 | 主卦文字 | 主卦爻槽 |
/// 主卦世/应 | 动爻 | 箭头 | 变卦文字 | 变卦爻槽 | 变卦世/应。
/// 六亲地支与纳音拆成上下两行，**无省略号**；爻槽（24×6）、世应槽、
/// 动爻槽固定，文字不侵占槽位。整行可点击：高亮该爻并打开关系焦点弹层。
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

  // 固定槽位宽度（冻结；按 R3 SVG 等比，360 DIP 不横向溢出）。
  static const double _spiritW = 24;
  static const double _hiddenW = 28;
  static const double _shiYingW = 12;
  static const double _markerW = 12;
  static const double _arrowW = 6;
  static const double _gap = 2;

  /// 主卦爻槽种类：空亡优先于阴阳（isVoid 由排盘引擎提供，Widget 不计算）。
  YaoKind get _mainYaoKind {
    if (line.isVoid) return YaoKind.voidYao;
    return line.isYang ? YaoKind.yang : YaoKind.yin;
  }

  @override
  Widget build(BuildContext context) {
    final row = Container(
      key: Key('review_line_${line.position}'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? CastingTokens.surfaceActive : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: CastingTokens.divider),
        ),
      ),
      child: Row(
        children: [
          _slot(
            _spiritW,
            Text(
              line.sixSpirit ?? '—',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 9.8,
                fontWeight: FontWeight.w700,
                color: CastingTokens.spiritGold,
                height: 1.2,
              ),
            ),
          ),
          _gapW,
          _slot(_hiddenW, _hiddenStrong(line.hiddenSpirit1)),
          _gapW,
          _slot(_hiddenW, _hiddenStrong(line.hiddenSpirit2)),
          const SizedBox(width: 4),
          Expanded(
            child: _LineTextBlock(
              line1: line.sixRelative ?? line.branch ?? '—',
              line2: line.displayExtra ?? '',
            ),
          ),
          _gapW,
          _slot(
            YaoGlyph.slotWidth,
            Center(
              child: YaoGlyph(
                key: Key('yao_glyph_${line.position}'),
                kind: _mainYaoKind,
              ),
            ),
          ),
          _gapW,
          _slot(
            _shiYingW,
            line.shiYing == null
                ? null
                : Text(
                    line.shiYing!,
                    key: Key('shi_ying_${line.position}'),
                    style: const TextStyle(
                      fontSize: 8.8,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.shiYingRed,
                      height: 1.2,
                    ),
                  ),
          ),
          _gapW,
          _slot(
            _markerW,
            line.movementType.isMoving
                ? Center(
                    child: MovingMarker(
                      key: Key('moving_marker_${line.position}'),
                      isYin: line.movementType == MovementType.laoYin,
                    ),
                  )
                : null,
          ),
          _gapW,
          _slot(
            _arrowW,
            line.movementType.isMoving ? const _MovingArrow() : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _LineTextBlock(
              line1: line.changed == null
                  ? '—'
                  : (line.changed!.sixRelative ??
                      line.changed!.earthlyBranch ??
                      '—'),
              line2: line.changed?.displayExtra ?? '',
            ),
          ),
          _gapW,
          _slot(
            YaoGlyph.slotWidth,
            Center(
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
          ),
          _gapW,
          _slot(
            _shiYingW,
            line.changedShiYing == null
                ? null
                : Text(
                    line.changedShiYing!,
                    key: Key('changed_shi_ying_${line.position}'),
                    style: const TextStyle(
                      fontSize: 8.8,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.shiYingRed,
                      height: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }

  static const SizedBox _gapW = SizedBox(width: _gap);

  Widget _slot(double width, Widget? child) =>
      SizedBox(width: width, child: child);

  Widget _hiddenStrong(String? text) {
    return Text(
      text ?? '',
      maxLines: 1,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: CastingTokens.textPrimary,
        height: 1.2,
      ),
    );
  }
}

/// 两行文字块：六亲地支（body 10）+ 纳音（small 8.8）。无省略号，超长裁切。
class _LineTextBlock extends StatelessWidget {
  const _LineTextBlock({required this.line1, required this.line2});

  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line1,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,
            color: CastingTokens.textBody,
            height: 1.2,
          ),
        ),
        Text(
          line2,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 8.8,
            color: CastingTokens.textSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
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
