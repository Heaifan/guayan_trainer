import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 四柱条（审卦一屏版总 SVG：soft 底、44 高、teal/warm 双色）。
///
/// 顺序固定：年 → 月 → 日 → 时 → 旬空（右对齐）。
class ReviewFourPillarsStrip extends StatelessWidget {
  const ReviewFourPillarsStrip({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: CastingTokens.surfaceSoft,
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
              color: CastingTokens.pillarWarm,
              align: TextAlign.center,
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.dayPillar ?? '—',
              color: CastingTokens.pillarWarm,
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
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      ),
    );
  }
}
