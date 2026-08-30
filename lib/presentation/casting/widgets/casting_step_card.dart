import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_step_status.dart';

/// 步骤卡片（任务书 §7–§10）。
///
/// - current：展开态，白底 + 激活边框 + CTA 徽标
/// - pending：低存在感灰底
/// - completed：完成态，显示结果摘要（不是简单写「已完成」）
/// - warning：低饱和警示
class CastingStepCard extends StatelessWidget {
  const CastingStepCard({
    super.key,
    required this.data,
    this.onTap,
    this.onCta,
  });

  final CastingStepData data;

  /// 点击卡片主体（进入步骤 / 修改）。
  final VoidCallback? onTap;

  /// 点击 CTA 徽标（「立即填写」等推进动作）。
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final state = data.state;
    final height = state == CastingStepState.current ? 92.0 : 72.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
          decoration: BoxDecoration(
            color: _background(state),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border(state)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: state == CastingStepState.current ? 13 : 12,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.summary ?? data.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: data.summary != null
                            ? CastingTokens.textSecondary
                            : CastingTokens.textMuted,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (state == CastingStepState.current && onCta != null)
                      _CtaBadge(label: data.badgeText ?? '立即填写', onTap: onCta!),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  if (data.badgeText != null &&
                      state != CastingStepState.current)
                    _statusBadge(state, data.badgeText!),
                  const Spacer(),
                  const CastingChevron(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _background(CastingStepState state) {
    switch (state) {
      case CastingStepState.current:
        return CastingTokens.panel;
      case CastingStepState.completed:
        return CastingTokens.completedCard;
      case CastingStepState.warning:
        return CastingTokens.warningBackground;
      case CastingStepState.pending:
      case CastingStepState.locked:
        return CastingTokens.panelSubtle;
    }
  }

  Color _border(CastingStepState state) {
    switch (state) {
      case CastingStepState.current:
        return CastingTokens.borderActive;
      case CastingStepState.completed:
        return CastingTokens.completedStroke;
      case CastingStepState.warning:
        return CastingTokens.warningBorder;
      case CastingStepState.pending:
      case CastingStepState.locked:
        return const Color(0xFFE1E8E5);
    }
  }

  Widget _statusBadge(CastingStepState state, String label) {
    switch (state) {
      case CastingStepState.completed:
        return CastingStepStatus.complete(label);
      case CastingStepState.warning:
        return CastingStepStatus.warning(label);
      default:
        return CastingStepStatus.pending(label);
    }
  }
}

class _CtaBadge extends StatelessWidget {
  const _CtaBadge({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

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
            color: CastingTokens.activeStrong,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CastingTokens.accent,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
