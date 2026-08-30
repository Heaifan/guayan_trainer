import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 神煞卡（UI-CORRECTION-R2 §5 SVG：402×178）。
///
/// 固定 4 列 × N 行（数据驱动，>16 项继续增加新行、仍保持 4 列，
/// 禁止硬编码 16 个 Widget、禁止截断数据）。
/// 标题仅「神煞」（R2 无副标题）；chip 高 24、rx12、浅豆绿底。
class ReviewShenShaCard extends StatelessWidget {
  const ReviewShenShaCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '神煞',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CastingTokens.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (state.shenShaItems.isEmpty)
            const Text(
              '暂无神煞数据（排盘引擎接入后展示）',
              style: TextStyle(
                fontSize: 11,
                color: CastingTokens.textMuted,
                height: 1.4,
              ),
            )
          else
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 4,
                mainAxisExtent: 20,
              ),
              children: [
                for (final item in state.shenShaItems)
                  Container(
                    key: Key('shensha_${item.name}'),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: CastingTokens.chipSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CastingTokens.chipBorder),
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: CastingTokens.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
