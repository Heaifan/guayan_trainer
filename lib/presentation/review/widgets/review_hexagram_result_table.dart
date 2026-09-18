import 'package:flutter/material.dart';

import '../review_page_state.dart';
import 'review_hexagram_line_row.dart';
import 'board_column_layout.dart';

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
    this.anchorKeys = const {},
    this.rowKeys = const {},
  });

  final ReviewPageState state;
  final int? selectedPosition;
  final ValueChanged<int>? onLineTap;
  final Map<String, GlobalKey> anchorKeys;
  final Map<int, GlobalKey> rowKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderZone(state: state),
          const _ColumnHeaderZone(),
          for (var i = 0; i < state.displayLines.length; i++) ...[
            ReviewHexagramLineRow(
              line: state.displayLines[i],
              selected: selectedPosition == state.displayLines[i].position,
              onTap: onLineTap == null
                  ? null
                  : () => onLineTap!(state.displayLines[i].position),
              mainAnchorKey:
                  anchorKeys['yao:original:${state.displayLines[i].position}'],
              changedAnchorKey:
                anchorKeys['yao:changed:${state.displayLines[i].position}'],
              rowKey: rowKeys[state.displayLines[i].position],
            ),
            if (i < state.displayLines.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: const Color(0xFFE5ECE8),
              ),
          ],
          const SizedBox(height: 4), // Bottom padding
        ],
      ),
    );
  }
}

class _HeaderZone extends StatelessWidget {
  const _HeaderZone({required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5ECE8))),
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243744),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9A7B45),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ColumnHeaderZone extends StatelessWidget {
  const _ColumnHeaderZone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 24,
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: BoardColumnLayout.width,
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const _HeaderSlot(
                key: ValueKey('header_six_spirit'),
                left: BoardColumnLayout.sixSpiritLeft,
                width: BoardColumnLayout.sixSpiritWidth,
                label: '六神',
              ),
              const _HeaderSlot(
                key: ValueKey('header_primary_hidden'),
                left: BoardColumnLayout.primaryHiddenLeft,
                width: BoardColumnLayout.primaryHiddenWidth,
                label: '主伏',
              ),
              const _HeaderSlot(
                key: ValueKey('header_opposite_hidden'),
                left: BoardColumnLayout.oppositeHiddenLeft,
                width: BoardColumnLayout.oppositeHiddenWidth,
                label: '旁伏',
              ),
              const _HeaderSlot(
                key: ValueKey('header_main_text'),
                left: BoardColumnLayout.mainTextLeft,
                width: BoardColumnLayout.mainTextWidth,
                label: '主卦',
              ),
              const _HeaderSlot(
                key: ValueKey('header_yao_band'),
                left: BoardColumnLayout.centralHeaderLeft,
                width: BoardColumnLayout.centralHeaderWidth,
                label: '爻',
              ),
              const _HeaderSlot(
                key: ValueKey('header_changed_text'),
                left: BoardColumnLayout.changedTextLeft,
                width: BoardColumnLayout.changedTextWidth,
                label: '变卦',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColText extends StatelessWidget {
  const _ColText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF7C8D94),
        height: 1.0,
      ),
    );
  }
}

class _HeaderSlot extends StatelessWidget {
  const _HeaderSlot({
    super.key,
    required this.left,
    required this.width,
    required this.label,
  });

  final double left;
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    width: width,
    top: 0,
    bottom: 0,
    child: Center(child: _ColText(label)),
  );
}
