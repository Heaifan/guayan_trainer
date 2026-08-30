import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 规则包占位弹层（任务书 §13）。
///
/// 本轮无自定义规则 CRUD：仅展示默认规则包并说明版本记录语义，
/// 不临时造假 CRUD；自定义规则包入口属后续阶段。
class RulePackSheet extends StatelessWidget {
  const RulePackSheet({super.key, required this.rulePackLabel});

  final String rulePackLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(
          color: CastingTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '规则包',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CastingTokens.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              rulePackLabel,
              style: const TextStyle(
                fontSize: 12,
                color: CastingTokens.textBody,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '自定义规则包将在后续版本开放。\n生成排盘时自动记录当前规则版本，历史卦例可追溯（RuleId + RuleVersion）。',
              style: TextStyle(
                fontSize: 10,
                color: CastingTokens.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('rule_pack_close'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '知道了',
                  style: TextStyle(
                    fontSize: 12,
                    color: CastingTokens.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
