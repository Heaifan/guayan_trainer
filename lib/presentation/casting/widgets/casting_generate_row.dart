import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 生成排盘 · 第五行（任务书 §5.7 + §14）。
///
/// - locked：六爻未完整 →「尚未就绪」（锁定态 chip）；
/// - ready：六爻完整 →「生成排盘」浅豆青 Action；
/// - 生成后修改 →「重新生成」；
/// - generated：排盘已生成，数据保留，右侧「查看审卦 ›」（本轮仅视觉，导航属后续）。
class CastingGenerateRow extends StatelessWidget {
  const CastingGenerateRow({
    super.key,
    required this.generationState,
    required this.regenerateNeeded,
    this.onGenerate,
  });

  final GenerationState generationState;
  final bool regenerateNeeded;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, trailing) = _content();
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: CastingTokens.surfaceSoft,
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
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
          trailing,
        ],
      ),
    );
  }

  (String, String, Widget) _content() {
    if (regenerateNeeded) {
      return (
        '生成排盘',
        '关键信息已修改 · 需重新生成',
        CastingChip(
          key: const Key('generate_button'),
          label: '重新生成',
          background: CastingTokens.accentSurface,
          border: CastingTokens.accentBorder,
          foreground: CastingTokens.accent,
          width: 74,
          height: 24,
          onTap: onGenerate,
        ),
      );
    }
    switch (generationState) {
      case GenerationState.generated:
        return (
          '排盘已生成',
          '生成成功 · 数据已保留',
          const Text(
            '查看审卦 ›',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CastingTokens.accent,
              height: 1.2,
            ),
          ),
        );
      case GenerationState.ready:
        return (
          '生成排盘',
          '六爻已完整，可以生成排盘',
          CastingChip(
            key: const Key('generate_button'),
            label: '生成排盘',
            background: CastingTokens.accentSurface,
            border: CastingTokens.accentBorder,
            foreground: CastingTokens.accent,
            width: 74,
            height: 24,
            onTap: onGenerate,
          ),
        );
      case GenerationState.locked:
        return (
          '生成排盘',
          '六爻完整后解锁',
          const CastingChip(
            key: Key('generate_button'),
            label: '尚未就绪',
            background: CastingTokens.lockedSurface,
            border: CastingTokens.lockedBorder,
            width: 74,
            height: 24,
          ),
        );
    }
  }
}
