import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';
import 'review_hexagram_line_row.dart';

/// 最终卦盘组件（UI-CORRECTION-R2 §6/§12，SVG 402×404）。
///
/// 内嵌【主卦】/【变卦】标题（不再单独渲染 HexagramResultHeader）；
/// 六行排盘（上爻在上、初爻在下）；表尾说明。
/// 爻槽 / 世应槽 / 动爻槽全部固定，文本不得侵占（见单行组件）。
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
          _HeaderZone(state: state),
          for (final line in state.displayLines)
            ReviewHexagramLineRow(line: line),
          const _FooterNote(),
        ],
      ),
    );
  }
}

/// 表头区：浅底（#F8FBF9）+【主卦】/【变卦】标题 + 卦名（金色）。
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
          Expanded(child: _HexTitle(label: '【主卦】', name: state.originalHexagramLabel ?? '—')),
          Expanded(child: _HexTitle(label: '【变卦】', name: state.changedHexagramLabel ?? '—')),
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
            fontSize: 11,
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
            fontSize: 10.4,
            fontWeight: FontWeight.w700,
            color: CastingTokens.guaNameGold,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// 表尾说明（SVG #12 底部两行）。
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '阳爻 / 阴爻 / 空亡爻统一 24 × 6 DIP，只改变内部填充。',
            style: TextStyle(
              fontSize: 8,
              color: CastingTokens.textSecondary,
              height: 1.4,
            ),
          ),
          Text(
            '爻槽、世应槽、动爻槽全部固定，文本不得侵占。',
            style: TextStyle(
              fontSize: 8,
              color: CastingTokens.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
