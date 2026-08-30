import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../../../presentation/shared/moving_marker.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 六爻排盘单行（审卦首屏 R4 · Baseline Alignment 定稿版）。
///
/// 数学上强制两条水平线（不允许"看起来差不多"）：
/// - PRIMARY BASELINE = RowTop + 19：六神 / 伏神1 / 伏神2 / 主卦正文 /
///   主卦世应 / 变卦正文 / 变卦世应，全部共用同一基线；
/// - NAYIN BASELINE = RowTop + 35：主卦纳音 / 变卦纳音。
///
/// 行高固定 48；设计坐标空间宽 400（对应 402 卡片内宽），列中心冻结：
/// 六神22 伏神1·62 伏神2·100 主卦正文174 主卦爻222 世应250 动爻268 箭头280
/// 变卦正文318 变卦爻358 变卦世应388。整行 FittedBox(scaleDown) 自适应窄屏，
/// 任何宽度不溢出、文本不侵占爻槽/世应槽。
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

  /// 设计坐标空间（宽 400 = 402 卡片内宽）。
  static const double _designW = 400;
  static const double _rowH = 48;
  static const double _primaryBaseline = 19;
  static const double _naYinBaseline = 35;

  /// 主卦爻槽种类：空亡优先于阴阳（isVoid 由排盘引擎提供，Widget 不计算）。
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
          // 六神 / 伏神（辅助信息：不加大、不加粗）
          _primaryText(22, 28, line.sixSpirit ?? '—', _spiritStyle),
          _primaryText(62, 32, line.hiddenSpirit1 ?? '', _hiddenStyle),
          _primaryText(100, 32, line.hiddenSpirit2 ?? '', _hiddenStyle),
          // 主卦正文 + 纳音（重点：加粗加大）
          _primaryText(
            174,
            56,
            line.sixRelative ?? line.branch ?? '—',
            _linePrimaryStyle,
          ),
          if (line.displayExtra != null && line.displayExtra!.isNotEmpty)
            _naYinText(174, 56, line.displayExtra!),
          // 主卦爻槽（24×6，槽顶 = PrimaryBaseline - 6 = 13）
          Positioned(
            left: 222 - YaoGlyph.slotWidth / 2,
            top: _primaryBaseline - YaoGlyph.slotHeight,
            width: YaoGlyph.slotWidth,
            height: YaoGlyph.slotHeight,
            child: YaoGlyph(
              key: Key('yao_glyph_${line.position}'),
              kind: _mainYaoKind,
            ),
          ),
          // 主卦世应
          if (line.shiYing != null)
            _primaryText(
              250,
              16,
              line.shiYing!,
              _shiYingStyle,
              textKey: Key('shi_ying_${line.position}'),
            ),
          // 动爻标记（12×12，中心 = PrimaryBaseline - 3）
          if (line.movementType.isMoving)
            Positioned(
              left: 268 - MovingMarker.markerSize / 2,
              top: _primaryBaseline - 3 - MovingMarker.markerSize / 2,
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
              left: 280 - 3,
              top: _primaryBaseline - 3 - 6,
              width: 6,
              height: 12,
              child: const _MovingArrow(),
            ),
          // 变卦正文 + 纳音
          _primaryText(
            318,
            56,
            line.changed == null
                ? '—'
                : (line.changed!.sixRelative ??
                    line.changed!.earthlyBranch ??
                    '—'),
            _linePrimaryStyle,
          ),
          if (line.changed?.displayExtra != null &&
              line.changed!.displayExtra!.isNotEmpty)
            _naYinText(318, 56, line.changed!.displayExtra!),
          // 变卦爻槽
          Positioned(
            left: 358 - YaoGlyph.slotWidth / 2,
            top: _primaryBaseline - YaoGlyph.slotHeight,
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
            _primaryText(
              388,
              16,
              line.changedShiYing!,
              _shiYingStyle,
              textKey: Key('changed_shi_ying_${line.position}'),
            ),
        ],
      ),
    );

    final row = Container(
      key: Key('review_line_${line.position}'),
      height: _rowH,
      width: double.infinity,
      // 注意：行内不带底边框（边框由表格层独立分割线绘制），
      // 保证 FittedBox 父高恰为 48，行内容不做任何纵向缩放。
      decoration: BoxDecoration(
        color: selected ? CastingTokens.surfaceActive : Colors.transparent,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: content,
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }

  /// 主基线文本：Baseline 数学锁定在 RowTop + 19，列内水平居中。
  Widget _primaryText(
    double center,
    double width,
    String text,
    TextStyle style, {
    Key? textKey,
  }) {
    return Positioned(
      left: center - width / 2,
      top: 0,
      width: width,
      height: _rowH,
      child: Align(
        alignment: Alignment.topCenter,
        child: Baseline(
          baseline: _primaryBaseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(text, key: textKey, maxLines: 1, style: style),
        ),
      ),
    );
  }

  /// 纳音文本：Baseline 数学锁定在 RowTop + 35。
  Widget _naYinText(double center, double width, String text) {
    return Positioned(
      left: center - width / 2,
      top: 0,
      width: width,
      height: _rowH,
      child: Align(
        alignment: Alignment.topCenter,
        child: Baseline(
          baseline: _naYinBaseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(text, maxLines: 1, style: _naYinStyle),
        ),
      ),
    );
  }

  static const TextStyle _spiritStyle = TextStyle(
    fontSize: 9.4,
    fontWeight: FontWeight.w400,
    color: CastingTokens.spiritGold,
    height: 1.2,
  );

  static const TextStyle _hiddenStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: CastingTokens.textBody,
    height: 1.2,
  );

  static const TextStyle _linePrimaryStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: CastingTokens.linePrimary,
    height: 1.2,
  );

  static const TextStyle _naYinStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: CastingTokens.textSecondary,
    height: 1.2,
  );

  static const TextStyle _shiYingStyle = TextStyle(
    fontSize: 8.8,
    fontWeight: FontWeight.w400,
    color: CastingTokens.shiYingRed,
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
