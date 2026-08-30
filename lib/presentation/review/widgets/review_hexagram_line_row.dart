import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../../casting/widgets/yao_glyph.dart';
import '../review_page_state.dart';

/// 六爻排盘单行（任务书 §6 HexagramResultTable 行结构）。
///
/// 三列心智：六神 | 主卦（含伏神） | 变卦。
/// 行内表达：六神 / 伏神 / 六亲+地支+纳音 / 主卦爻象 / 世应 /
/// 动爻标记（矢量）/ 变卦爻象。爻象统一复用 [YaoGlyph] 矢量绘制。
class ReviewHexagramLineRow extends StatelessWidget {
  const ReviewHexagramLineRow({super.key, required this.line});

  final ReviewLineView line;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('review_line_${line.position}'),
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 六神
          SizedBox(
            width: 46,
            child: Text(
              line.sixSpirit ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CastingTokens.traditionalGold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 主卦（含伏神）
          Expanded(
            flex: 3,
            child: _ZoneColumn(
              topText: line.hiddenSpirit == null
                  ? null
                  : '伏：${line.hiddenSpirit}',
              primaryText: line.mainPrimary,
              bottom: Row(
                children: [
                  Expanded(
                    child: YaoGlyph(
                      key: Key('yao_glyph_${line.position}'),
                      movementType: line.movementType,
                    ),
                  ),
                  if (line.shiYing != null)
                    Text(
                      line.shiYing!,
                      key: Key('shi_ying_${line.position}'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.relationRed,
                        height: 1.2,
                      ),
                    ),
                  if (line.movementType.isMoving)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: _MovingArrow(
                        key: Key('moving_arrow_${line.position}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 变卦
          Expanded(
            flex: 3,
            child: _ZoneColumn(
              primaryText: line.changed?.primaryLabel ?? '—',
              bottom: Row(
                children: [
                  Expanded(
                    child: line.changed?.movementType == null
                        ? const SizedBox.shrink()
                        : YaoGlyph(
                            key: Key('changed_yao_glyph_${line.position}'),
                            movementType: line.changed!.movementType!,
                          ),
                  ),
                  if (line.changedShiYing != null)
                    Text(
                      line.changedShiYing!,
                      key: Key('changed_shi_ying_${line.position}'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.relationRed,
                        height: 1.2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 爻区文本 + 底部爻象行（上下两区槽位等高，保证爻象横向对齐）。
class _ZoneColumn extends StatelessWidget {
  const _ZoneColumn({
    required this.primaryText,
    required this.bottom,
    this.topText,
  });

  final String? topText;
  final String primaryText;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 13,
          child: topText == null
              ? null
              : Text(
                  topText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
        ),
        SizedBox(
          height: 17,
          child: Text(
            primaryText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: CastingTokens.textBody,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 22, child: bottom),
      ],
    );
  }
}

/// 动爻箭头（→，矢量；老阴/老阳标记由 [YaoGlyph] 在爻线内绘制）。
class _MovingArrow extends StatelessWidget {
  const _MovingArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(14, 12),
      painter: _ArrowPainter(),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CastingTokens.pillarTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cy = size.height / 2;
    final tipX = size.width - 2;
    canvas.drawLine(Offset(1, cy), Offset(tipX - 4, cy), paint);
    final head = Path()
      ..moveTo(tipX - 7, cy - 4)
      ..lineTo(tipX, cy)
      ..lineTo(tipX - 7, cy + 4);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
