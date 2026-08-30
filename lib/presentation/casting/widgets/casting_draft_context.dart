import 'package:flutter/material.dart';

import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 草稿上下文卡（任务书 §5.2 DraftContext SVG）。
///
/// 展示草稿标题与自动保存状态，非交互（草稿自动保存，任务书 §15）。
class CastingDraftContext extends StatelessWidget {
  const CastingDraftContext({
    super.key,
    required this.title,
    required this.rulePackName,
    required this.rulePackVersionLabel,
  });

  final String title;
  final String rulePackName;
  final String rulePackVersionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '未命名草稿' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '草稿自动保存 · $rulePackName $rulePackVersionLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CastingTokens.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CastingChip(
            key: Key('draft_state_chip'),
            label: '草稿中',
            background: CastingTokens.accentSurface,
            border: CastingTokens.accentBorder,
            width: 66,
            height: 24,
          ),
        ],
      ),
    );
  }
}
