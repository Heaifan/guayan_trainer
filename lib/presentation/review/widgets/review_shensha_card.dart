import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 神煞卡（任务书 §3 ShenShaCard SVG）。
///
/// 独立卡片 + 自适应标签网格（Wrap spacing 6 / runSpacing 8）；
/// 标签内容由数据生成（名称：值），禁止硬编码固定 16 个位置。
/// 小屏自然换行，禁止文字溢出。
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
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '神煞',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.3,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '按标签分组显示',
                style: TextStyle(
                  fontSize: 10,
                  color: CastingTokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
            Wrap(
              spacing: 6,
              runSpacing: 8,
              children: [
                for (final item in state.shenShaItems)
                  Container(
                    key: Key('shensha_${item.name}'),
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CastingTokens.chipSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CastingTokens.chipBorder),
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10,
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
