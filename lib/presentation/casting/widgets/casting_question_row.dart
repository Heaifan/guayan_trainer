import 'package:flutter/material.dart';

import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 问事信息 · 第二行（任务书 §5.4 + §12）。
///
/// 首页只显示标题 + 一行摘要，完整文本（对象 / 背景）在编辑弹层中维护。
class CastingQuestionRow extends StatelessWidget {
  const CastingQuestionRow({
    super.key,
    required this.title,
    required this.body,
    required this.hasDetail,
    this.onTap,
  });

  final String title;
  final String body;
  final bool hasDetail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final complete = title.trim().isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('question_row'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 74,
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
                      '问事信息',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CastingTokens.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complete ? body : '尚未填写主题与问事正文',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: complete
                            ? CastingTokens.textBody
                            : CastingTokens.textSecondary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      complete
                          ? (hasDetail ? '已补充对象、背景与补充说明' : '未补充对象与背景')
                          : '主题 / 对象 / 背景',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: CastingTokens.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (complete)
                const CastingChip(
                  key: Key('question_status_chip'),
                  label: '已完成',
                  background: CastingTokens.completeSurface,
                  border: CastingTokens.completeBorder,
                  width: 62,
                )
              else
                const CastingChip(
                  key: Key('question_status_chip'),
                  label: '待完善',
                  background: CastingTokens.lockedSurface,
                  border: CastingTokens.lockedBorder,
                  width: 62,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
