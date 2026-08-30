import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';
import 'review_hexagram_line_row.dart';

/// 完整卦盘组件（审卦一屏版总 SVG）。
///
/// 内嵌【主卦】/【变卦】标题 + 六行排盘（上爻在上、初爻在下）+
/// 表尾提示。六亲地支与纳音拆两行，无省略号。
/// 点击某一行回调 [onLineTap]（高亮 + 打开关系焦点弹层）。
class ReviewHexagramResultTable extends StatelessWidget {
  const ReviewHexagramResultTable({
    super.key,
    required this.state,
    this.selectedPosition,
    this.onLineTap,
  });

  final ReviewPageState state;

  /// 当前高亮爻位（点爻后）。
  final int? selectedPosition;

  /// 点爻回调。
  final ValueChanged<int>? onLineTap;

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
          _HeaderZone(state: state),
          for (final line in state.displayLines)
            ReviewHexagramLineRow(
              line: line,
              selected: selectedPosition == line.position,
              onTap: onLineTap == null ? null : () => onLineTap!(line.position),
            ),
          const _FooterNote(),
        ],
      ),
    );
  }
}

/// 表头区：浅底 +【主卦】/【变卦】标题 + 卦名（金色）。
class _HeaderZone extends StatelessWidget {
  const _HeaderZone({required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: CastingTokens.surfaceSoft,
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HexTitle(
              label: '【主卦】',
              name: state.originalHexagramLabel ?? '—',
            ),
          ),
          Expanded(
            child: _HexTitle(
              label: '【变卦】',
              name: state.changedHexagramLabel ?? '—',
            ),
          ),
        ],
      ),
    );
  }
}

class _HexTitle extends StatelessWidget {
  const _HexTitle({required this.label, required this.name});

  final String label;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: CastingTokens.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CastingTokens.guaNameGold,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// 表尾提示：点爻查看关系与规则依据。
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CastingTokens.divider)),
      ),
      child: const Text(
        '完整排盘 · 点击任一爻查看关系与规则依据',
        style: TextStyle(
          fontSize: 8,
          color: CastingTokens.textMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
