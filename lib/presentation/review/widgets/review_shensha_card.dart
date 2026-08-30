import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 神煞卡 · FIXED 4×4 定稿版（审卦首屏 R4 SVG：402×128）。
///
/// 真正固定的 4 列 × 4 行 Grid：格宽 89、格高 18、列距 6、行距 4，
/// 四行全部包含在 Card 内，禁止自由 Wrap 乱换行、禁止第 4 行越界。
/// 数据不足 16 个时留空占位（保持 4×4 几何）；超过 16 个才增加第 5 行。
class ReviewShenShaCard extends StatelessWidget {
  const ReviewShenShaCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    final items = state.shenShaItems;
    final cellCount = items.length <= 16
        ? 16
        : ((items.length / 4).ceil() * 4);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(11),
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
          const SizedBox(height: 6),
          if (items.isEmpty)
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
                mainAxisExtent: 18,
              ),
              children: [
                for (var i = 0; i < cellCount; i++)
                  i < items.length
                      ? Container(
                          key: Key('shensha_${items[i].name}'),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: CastingTokens.chipSurface,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: CastingTokens.chipBorder),
                          ),
                          child: Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.4,
                              fontWeight: FontWeight.w600,
                              color: CastingTokens.shenShaItem,
                              height: 1.2,
                            ),
                          ),
                        )
                      : const SizedBox(), // 留空占位：保持 4×4 固定几何
              ],
            ),
        ],
      ),
    );
  }
}
