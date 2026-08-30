import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';
import 'review_hexagram_line_row.dart';

/// 六爻排盘主体表（任务书 §6 HexagramResultTable SVG）。
///
/// 列心智：六神 | 主卦（含伏神） | 变卦；六行完整传统语义，
/// 上爻在最上、初爻在最下。表体不套内部纵向 Scroll（页面整体滚动）。
class ReviewHexagramResultTable extends StatelessWidget {
  const ReviewHexagramResultTable({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CastingTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 表头
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: CastingTokens.divider)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 46, child: _HeaderText('六神')),
                SizedBox(width: 8),
                Expanded(flex: 3, child: _HeaderText('主卦（含伏神）')),
                SizedBox(width: 8),
                Expanded(flex: 3, child: _HeaderText('变卦')),
              ],
            ),
          ),
          // 六行（上爻 → 初爻）
          for (final line in state.displayLines)
            ReviewHexagramLineRow(line: line),
          // 表尾说明
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Text(
              '传统排盘完整展示；关系连线与规则依据在焦点区继续展开。',
              style: const TextStyle(
                fontSize: 10,
                color: CastingTokens.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: CastingTokens.textMuted,
          height: 1.2,
        ),
      ),
    );
  }
}
