import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 基本信息卡（任务书 §2 BasicInfoCard SVG）。
///
/// 方式 / 事项 / 时间（阳历 + 阴历）三行；右上角「已生成」胶囊。
/// Domain 未提供的字段渲染为「—」，不伪造。
class ReviewBasicInfoCard extends StatelessWidget {
  const ReviewBasicInfoCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    final solar = state.solarDateTime == null
        ? '阳历：—'
        : '阳历：${formatSolar(state.solarDateTime!)}';
    final lunar = state.lunarDateTime == null
        ? '阴历：—'
        : '阴历：${state.lunarDateTime}';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: '方式',
            value: state.castingMethod ?? '—',
            trailing: Container(
              key: const Key('review_generated_chip'),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CastingTokens.accentSurface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: CastingTokens.accentBorder),
              ),
              child: const Text(
                '已生成',
                style: TextStyle(
                  fontSize: 10,
                  color: CastingTokens.textSecondary,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: '事项',
            value: state.question.isEmpty ? '—' : state.question,
            valueStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CastingTokens.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('时间'),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solar,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CastingTokens.textBody,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lunar,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CastingTokens.textBody,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.trailing,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 12,
                  color: CastingTokens.textBody,
                  height: 1.3,
                ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: CastingTokens.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }
}
