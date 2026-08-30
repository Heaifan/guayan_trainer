import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 四柱条（任务书 §4 FourPillarsStrip SVG）。
///
/// 顺序固定：年 → 月 → 日 → 时 → 旬空（禁止旬空独立成卡）。
/// 横向紧凑 Strip：小屏压缩字号而非拆成五张大卡。
class ReviewFourPillarsStrip extends StatelessWidget {
  const ReviewFourPillarsStrip({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillarText(
              text: state.yearPillar ?? '—',
              color: CastingTokens.pillarTeal,
              align: TextAlign.center,
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.monthPillar ?? '—',
              color: CastingTokens.relationRed,
              align: TextAlign.center,
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.dayPillar ?? '—',
              color: CastingTokens.relationRed,
              align: TextAlign.center,
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.hourPillar ?? '—',
              color: CastingTokens.pillarTeal,
              align: TextAlign.center,
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.xunKong ?? '—',
              color: CastingTokens.pillarTeal,
              align: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarText extends StatelessWidget {
  const _PillarText({
    required this.text,
    required this.color,
    required this.align,
  });

  final String text;
  final Color color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      ),
    );
  }
}
