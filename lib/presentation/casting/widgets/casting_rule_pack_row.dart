import 'package:flutter/material.dart';

import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 规则包 · 第四行（任务书 §5.6 + §13）。
///
/// 点击「修改 ›」进入规则包入口。本轮无自定义规则 CRUD，
/// 仅展示默认规则包并保留 RuleId / RuleVersion（历史卦例可追溯）。
class CastingRulePackRow extends StatelessWidget {
  const CastingRulePackRow({
    super.key,
    required this.rulePackLabel,
    this.onTap,
  });

  final String rulePackLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('rule_pack_row'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: CastingTokens.surface,
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
                    const Text(
                      '规则包',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      rulePackLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CastingTokens.textBody,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '修改',
                style: TextStyle(
                  fontSize: 10,
                  color: CastingTokens.textSecondary,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              const CastingChevron(size: Size(7, 11)),
            ],
          ),
        ),
      ),
    );
  }
}
