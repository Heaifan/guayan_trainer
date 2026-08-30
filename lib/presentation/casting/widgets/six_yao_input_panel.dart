import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';
import 'six_yao_input_row.dart';

/// 六爻录入 · 第三行面板（任务书 §5.5 + §19）。
///
/// 六行（上爻 → 初爻）一次完整显示，面板不做内部纵向滚动；
/// 当前编辑爻行高亮，普通行之间以分割线分隔（编辑行两侧无分割线）。
class SixYaoInputPanel extends StatelessWidget {
  const SixYaoInputPanel({
    super.key,
    required this.lines,
    required this.editingPosition,
    required this.completedLineCount,
    required this.movingLineCount,
    required this.onLineTap,
  });

  /// 六爻：index = position - 1（1 初爻 .. 6 上爻），null = 待录。
  final List<LineState?> lines;
  final int? editingPosition;
  final int completedLineCount;
  final int movingLineCount;
  final ValueChanged<int> onLineTap;

  /// 自上而下：上爻(6) → 初爻(1)。
  static const List<int> _topToBottom = [6, 5, 4, 3, 2, 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: CastingTokens.surfaceActive,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CastingTokens.borderActive, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          for (var i = 0; i < _topToBottom.length; i++) ...[
            if (_showDivider(i))
              const Divider(
                height: 1,
                thickness: 1,
                color: CastingTokens.divider,
              ),
            SixYaoInputRow(
              key: Key('yao_row_${_topToBottom[i]}'),
              position: _topToBottom[i],
              line: lines[_topToBottom[i] - 1],
              editing: editingPosition == _topToBottom[i],
              onTap: () => onLineTap(_topToBottom[i]),
            ),
          ],
        ],
      ),
    );
  }

  /// 编辑行两侧不画分割线（对齐任务书总 SVG）。
  bool _showDivider(int i) {
    if (i == 0) return false;
    final upper = _topToBottom[i - 1];
    final lower = _topToBottom[i];
    return editingPosition != upper && editingPosition != lower;
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '六爻录入',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedLineCount / 6 已完成 · 动爻 $movingLineCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: CastingTokens.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const CastingChip(
          key: Key('six_yao_step_chip'),
          label: '当前步骤',
          background: CastingTokens.accentSurface,
          border: CastingTokens.accentBorder,
          width: 68,
          height: 24,
        ),
      ],
    );
  }
}
