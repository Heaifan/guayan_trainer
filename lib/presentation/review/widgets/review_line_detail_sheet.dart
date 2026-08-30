import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../../rules/rule_library_page.dart';
import '../review_case_adapter.dart';
import '../review_page_state.dart';

/// 点爻关系焦点弹层（审卦一屏版交互：点击某爻 → 高亮 → Bottom Sheet）。
///
/// 内容：当前爻信息 + 关系列表（来自 Domain RelationInstance，禁止字符串
/// 重算）+ 规则依据入口 + 关系备注入口（GAP：备注随 RelationNote 后续接入）
/// + 「进入关系页」继续深入。
class ReviewLineDetailSheet extends StatelessWidget {
  const ReviewLineDetailSheet({
    super.key,
    required this.state,
    required this.position,
    this.onOpenRelations,
  });

  final ReviewPageState state;
  final int position;
  final VoidCallback? onOpenRelations;

  ReviewLineView get _line => state.lineAt(position);

  @override
  Widget build(BuildContext context) {
    final line = _line;
    final relations = state.relationsInvolving(position);
    return SafeArea(
      child: Container(
        key: const Key('line_detail_sheet'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: const BoxDecoration(
          color: CastingTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 当前爻
              Row(
                children: [
                  Text(
                    reviewLinePositionName(position),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    line.sixSpirit ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.spiritGold,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  if (line.shiYing != null || line.changedShiYing != null)
                    Text(
                      [line.shiYing, line.changedShiYing]
                          .whereType<String>()
                          .join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.shiYingRed,
                        height: 1.2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${line.sixRelative ?? line.branch ?? '—'}'
                '${line.displayExtra == null ? '' : '（${line.displayExtra}）'}'
                ' · 地支 ${line.branch ?? '—'}'
                ' · ${line.movementType.displayName}'
                '（${line.movementLabel}）',
                style: const TextStyle(
                  fontSize: 11,
                  color: CastingTokens.textBody,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              // 关系列表
              const Text(
                '关系列表',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              if (relations.isEmpty)
                const Text(
                  '该爻暂无已识别关系',
                  style: TextStyle(
                    fontSize: 11,
                    color: CastingTokens.textMuted,
                    height: 1.4,
                  ),
                )
              else
                for (final r in relations)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: CastingTokens.arrowTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ReviewCaseAdapter.relationLabel(r),
                            style: const TextStyle(
                              fontSize: 11,
                              color: CastingTokens.textBody,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 14),
              // 动作入口
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      key: const Key('sheet_rule_entry'),
                      label: '查看规则依据',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RuleLibraryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      key: const Key('sheet_note_entry'),
                      label: '关系备注',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('关系备注将随 RelationNote 后续接入'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 0, height: 8),
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  key: const Key('sheet_open_relations'),
                  label: '进入关系页继续分析 ›',
                  filled: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onOpenRelations?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled
                ? CastingTokens.accentSurface
                : CastingTokens.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: filled ? CastingTokens.accentBorder : CastingTokens.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CastingTokens.textBody,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
