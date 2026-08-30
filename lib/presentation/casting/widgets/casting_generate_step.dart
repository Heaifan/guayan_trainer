import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_step_status.dart';

/// 生成排盘步骤（任务书 §11–§13）。
///
/// - locked：前四步未完成（尚未就绪）
/// - ready：前四步完成，可生成
/// - completed：已生成（保留流程上下文，本卦/变卦摘要 + 操作）
/// - warning：生成后关键数据被修改（需重新生成）
class CastingGenerateStep extends StatelessWidget {
  const CastingGenerateStep({
    super.key,
    required this.state,
    this.onGenerate,
    this.onRegenerate,
  });

  final CastingStepState state;
  final VoidCallback? onGenerate;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case CastingStepState.completed:
        return _Completed(onRegenerate: onRegenerate);
      case CastingStepState.warning:
        return _Warning(onRegenerate: onRegenerate);
      case CastingStepState.current:
      case CastingStepState.pending:
        return _Ready(onGenerate: onGenerate);
      case CastingStepState.locked:
        return const _Locked();
    }
  }
}

class _Locked extends StatelessWidget {
  const _Locked();

  @override
  Widget build(BuildContext context) {
    return _Frame(
      height: 84,
      background: CastingTokens.generateLocked,
      border: const Color(0xFFD7E5DF),
      title: '生成排盘',
      description: '四步完成后生成本卦与变卦',
      trailing: const CastingStepStatus.locked('尚未就绪'),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({this.onGenerate});

  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      height: 84,
      background: CastingTokens.generateReady,
      border: CastingTokens.borderActive,
      title: '生成排盘',
      description: '起卦信息完整，可以生成排盘',
      trailing: _GenerateButton(onGenerate: onGenerate),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({this.onRegenerate});

  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      height: 84,
      background: CastingTokens.warningBackground,
      border: CastingTokens.warningBorder,
      title: '排盘已生成',
      description: '关键信息已修改 · 需重新生成',
      trailing: _ActionButton(
        label: '重新生成',
        background: CastingTokens.badgeWarning,
        foreground: CastingTokens.warningText,
        onTap: onRegenerate,
      ),
    );
  }
}

class _Completed extends StatelessWidget {
  const _Completed({this.onRegenerate});

  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      height: 104,
      background: CastingTokens.generateReady,
      border: CastingTokens.borderActive,
      title: '排盘已生成',
      description: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SummaryLine(label: '本卦：乾为天'),
          const SizedBox(height: 4),
          const _SummaryLine(label: '变卦：天风姤'),
          const SizedBox(height: 8),
          Row(
            children: [
              _ActionButton(
                label: '查看排盘',
                background: CastingTokens.generateStrong,
                foreground: CastingTokens.accent,
                onTap: null,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: '重新生成',
                background: CastingTokens.header,
                foreground: CastingTokens.textSecondary,
                onTap: onRegenerate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: CastingTokens.textSecondary,
        height: 1.2,
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({this.onGenerate});

  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          key: const Key('casting_generate_button'),
          label: '生成排盘',
          background: CastingTokens.generateStrong,
          foreground: CastingTokens.accent,
          strong: true,
          onTap: onGenerate,
        ),
        const SizedBox(width: 6),
        const CastingChevron(color: CastingTokens.accent),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.strong = false,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool strong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              color: foreground,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.height,
    required this.background,
    required this.border,
    required this.title,
    this.description,
    this.trailing,
    this.child,
  });

  final double height;
  final Color background;
  final Color border;
  final String title;
  final String? description;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: CastingTokens.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ?trailing,
            ],
          ),
          if (child != null) ...[const SizedBox(height: 2), ?child],
        ],
      ),
    );
  }
}
