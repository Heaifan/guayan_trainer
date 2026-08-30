import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 流程头部面板（任务书 §4 CastingFlowHeader SVG）。
///
/// 「CASTING FLOW」标签 + 大标题「排卦流程轨」+ 右侧当前步骤 x / 5。
class CastingFlowHeader extends StatelessWidget {
  const CastingFlowHeader({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  final int currentIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CastingTokens.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CASTING FLOW',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '排卦流程轨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '当前步骤',
                style: TextStyle(
                  fontSize: 9,
                  color: CastingTokens.textMuted,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentIndex / $totalSteps',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
