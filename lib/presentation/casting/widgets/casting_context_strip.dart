import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 流程上下文条（任务书 §14 CastingContextStrip SVG）。
///
/// 替代原页面中央孤立的「状态探针：0」：三栏布局
/// 流程上下文（规则包 · 默认）｜探针（点击递增，保留 §35 状态保持语义）｜已完成 x / 5。
class CastingContextStrip extends StatelessWidget {
  const CastingContextStrip({
    super.key,
    required this.probeCount,
    required this.completedCount,
    required this.totalSteps,
    this.onProbeTap,
  });

  final int probeCount;
  final int completedCount;
  final int totalSteps;

  /// 点击探针栏（状态保持探针递增）。
  final VoidCallback? onProbeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 108,
            child: _StripCell(label: '流程上下文', value: '规则包 · 默认'),
          ),
          const _Divider(),
          Expanded(
            flex: 94,
            child: InkWell(
              onTap: onProbeTap,
              child: _StripCell(
                label: '探针',
                value: '$probeCount',
                valueKey: const Key('casting_probe_value'),
              ),
            ),
          ),
          const _Divider(),
          Expanded(
            flex: 147,
            child: _StripCell(
              label: '已完成',
              value: '$completedCount / $totalSteps',
            ),
          ),
        ],
      ),
    );
  }
}

class _StripCell extends StatelessWidget {
  const _StripCell({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: CastingTokens.textMuted,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          key: valueKey,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CastingTokens.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: CastingTokens.border);
  }
}
