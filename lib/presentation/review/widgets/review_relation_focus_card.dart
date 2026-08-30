import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../../rules/rule_library_page.dart';
import '../review_page_state.dart';

/// 关系焦点卡（任务书 §7 RelationFocusCard SVG）。
///
/// 是「当前排盘 → 人工继续审卦」的入口，不是普通推荐卡。
/// 摘要文案来自现有 [RelationInstance]（经适配器生成），
/// 禁止用字符串重新解析关系；世应/生克/回头生克规则属 R3/R4，
/// 本轮仅展示入口，规则依据跳转现有规则库页。
class ReviewRelationFocusCard extends StatelessWidget {
  const ReviewRelationFocusCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('relation_focus_card'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: CastingTokens.surfaceActive,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CastingTokens.borderActive, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '关系焦点',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CastingTokens.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.focusSummary ?? '—',
            style: const TextStyle(
              fontSize: 12,
              color: CastingTokens.textBody,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              const _FocusChip(label: '世应关系'),
              const _FocusChip(label: '生克关系'),
              const _FocusChip(label: '回头生回头克'),
              _FocusChip(
                label: '查看规则依据 ›',
                background: CastingTokens.relationBlueSurface,
                border: CastingTokens.relationBlueBorder,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RuleLibraryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.label,
    this.background = CastingTokens.relationRedSurface,
    this.border = CastingTokens.relationRedBorder,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: CastingTokens.textSecondary,
          height: 1.1,
        ),
      ),
    );
    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: chip,
      ),
    );
  }
}
