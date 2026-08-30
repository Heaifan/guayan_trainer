import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 基本信息卡（审卦一屏版总 SVG：问事 / 公历 / 农历 / meta 单行）。
///
/// 紧凑单卡：问事 + 起卦方式 chip + 公历/农历两栏 + meta
/// （规则包版本 · 手动起卦 · 排盘已生成）。不再拆大卡片。
class ReviewBasicInfoCard extends StatelessWidget {
  const ReviewBasicInfoCard({super.key, required this.state});

  final ReviewPageState state;

  String get _rulePackLabel {
    final id = state.rulePackId;
    if (id == null) return '—';
    final name = id == 'sys.default' ? '默认规则包' : id;
    return '$name v${state.ruleVersion ?? 1}';
  }

  @override
  Widget build(BuildContext context) {
    final solar =
        state.solarDateTime == null ? '—' : formatSolar(state.solarDateTime!);
    final lunar = state.lunarDateTime ?? '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: CastingTokens.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _Label('问事'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.question.isEmpty ? '—' : state.question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: CastingTokens.textBody,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                key: const Key('basic_method_chip'),
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CastingTokens.surfaceActive,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: CastingTokens.borderActive),
                ),
                child: Text(
                  state.castingMethod ?? '—',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 9,
                    color: CastingTokens.textSecondary,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const _Label('公历'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        solar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: CastingTokens.textBody,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const _Label('农历'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lunar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: CastingTokens.textBody,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetaText(_rulePackLabel),
              const SizedBox(width: 24),
              _MetaText(state.castingMethod == null ? '—' : '手动起卦'),
              const SizedBox(width: 24),
              const _MetaText('排盘已生成'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: CastingTokens.textPrimary,
        height: 1.2,
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 9,
        color: CastingTokens.textSecondary,
        height: 1.2,
      ),
    );
  }
}
