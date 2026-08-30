import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../../../presentation/shared/moving_marker.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 六爻排盘单行（UI-CORRECTION-R2 §7/§8/§11，SVG #12 列结构）。
///
/// 冻结 11 列：六神 | 伏神1 | 伏神2 | 主卦文字 | 主卦爻槽 |
/// 主卦世/应 | 动爻 | 箭头 | 变卦文字 | 变卦爻槽 | 变卦世/应。
/// 爻槽（24×6）、世应槽、动爻槽全部固定宽度，文本列 Ellipsis 裁剪，
/// 文字永远不得侵占爻槽 / 世应槽（硬门禁）。
class ReviewHexagramLineRow extends StatelessWidget {
  const ReviewHexagramLineRow({super.key, required this.line});

  final ReviewLineView line;

  // 固定槽位宽度（冻结，禁止文字挤占）。
  static const double _spiritW = 32;
  static const double _hiddenW = 26;
  static const double _shiYingW = 16;
  static const double _markerW = 12;
  static const double _arrowW = 8;
  static const double _gap = 2;

  /// 主卦爻槽种类：空亡优先于阴阳（isVoid 由排盘引擎提供，Widget 不计算）。
  YaoKind get _mainYaoKind {
    if (line.isVoid) return YaoKind.voidYao;
    return line.isYang ? YaoKind.yang : YaoKind.yin;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('review_line_${line.position}'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        children: [
          _slot(
            _spiritW,
            Text(
              line.sixSpirit ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.8,
                fontWeight: FontWeight.w700,
                color: CastingTokens.spiritGold,
                height: 1.2,
              ),
            ),
          ),
          _gapW,
          _slot(
            _hiddenW,
            _minorStrong(line.hiddenSpirit1),
          ),
          _slot(
            _hiddenW,
            _minorStrong(line.hiddenSpirit2),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _slot(
              null,
              Text(
                line.mainPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.2,
                  color: CastingTokens.textBody,
                  height: 1.2,
                ),
              ),
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
                      fontSize: 8.9,
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
            child: _slot(
              null,
              Text(
                line.changed?.primaryLabel ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.2,
                  color: CastingTokens.textBody,
                  height: 1.2,
                ),
              ),
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
                      fontSize: 8.9,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.shiYingRed,
                      height: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static const SizedBox _gapW = SizedBox(width: _gap);

  Widget _slot(double? width, Widget? child) {
    if (width == null) return Align(alignment: Alignment.centerLeft, child: child);
    return SizedBox(width: width, child: child);
  }

  Widget _minorStrong(String? text) {
    return Text(
      text ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 8.9,
        fontWeight: FontWeight.w700,
        color: CastingTokens.textPrimary,
        height: 1.2,
      ),
    );
  }
}

/// 动爻箭头（→，矢量，arrowTeal #4F8685 w1.5 圆头）。
class _MovingArrow extends StatelessWidget {
  const _MovingArrow();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(8, 12),
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
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0.5, cy), Offset(size.width - 3, cy), paint);
    final head = Path()
      ..moveTo(size.width - 5.5, cy - 3)
      ..lineTo(size.width - 0.5, cy)
      ..lineTo(size.width - 5.5, cy + 3);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
