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
          for (var i = 0; i < state.displayLines.length; i++) ...[
            ReviewHexagramLineRow(
              line: state.displayLines[i],
              selected: selectedPosition == state.displayLines[i].position,
              onTap: onLineTap == null
                  ? null
                  : () => onLineTap!(state.displayLines[i].position),
            ),
            // 行间独立 1px 分割线（行内容高恒为 48，不做纵向缩放）。
            if (i < state.displayLines.length - 1)
              const SizedBox(
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: CastingTokens.divider),
                ),
              ),
          ],
          const _FooterNote(),
        ],
      ),
    );
  }
}

/// 表头区：浅底 +【主卦】/【变卦】标题 + 卦名（金色），高度 54（紧凑）。
class _HeaderZone extends StatelessWidget {
  const _HeaderZone({required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
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
        const SizedBox(height: 1),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.8,
            fontWeight: FontWeight.w700,
            color: CastingTokens.guaNameGold,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// 表尾提示：点爻查看关系、规则依据与关系备注。
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CastingTokens.divider)),
      ),
      child: const Text(
        '点击任一爻查看关系、规则依据与关系备注',
        style: TextStyle(
          fontSize: 8,
          color: CastingTokens.textMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
