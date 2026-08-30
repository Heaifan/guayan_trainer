import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 排盘结果头卡（任务书 §5 HexagramResultHeader SVG）。
///
/// 标题 + 「完整排盘」胶囊 + 主卦 / 变卦名称（宫位 · 卦名，金色）。
/// 主变卦分区明确，为下方六爻排盘表提供语义入口。
class ReviewHexagramResultHeader extends StatelessWidget {
  const ReviewHexagramResultHeader({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    final original = state.originalHexagramLabel ?? '—';
    final changed = state.changedHexagramLabel ?? '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '排盘结果',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Container(
                key: const Key('review_full_chart_chip'),
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CastingTokens.accentSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CastingTokens.accentBorder),
                ),
                child: const Text(
                  '完整排盘',
                  style: TextStyle(
                    fontSize: 10,
                    color: CastingTokens.textSecondary,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HexagramTitle(label: '主卦', value: original),
              ),
              Expanded(
                child: _HexagramTitle(label: '变卦', value: changed),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: CastingTokens.divider),
        ],
      ),
    );
  }
}

class _HexagramTitle extends StatelessWidget {
  const _HexagramTitle({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CastingTokens.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CastingTokens.traditionalGold,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
