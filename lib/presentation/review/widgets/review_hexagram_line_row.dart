import 'package:flutter/material.dart';

import '../../../domain/casting/fushen.dart';
import '../../../domain/casting/double_fucang.dart';
import '../../../domain/line_state.dart';
import '../../../presentation/shared/moving_marker.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../review_page_state.dart';
import 'line_identity_text.dart';
import 'board_column_layout.dart';
import 'hexagram_line_cell.dart';

/// 六爻排盘单行（审卦首屏 SVG 定稿 · 3c00187 版）。
///
/// 数学上强制三条水平基线（不允许"看起来差不多"）：
/// - 正文基线 RowTop+16：主卦/变卦六亲正文；
/// - 神系基线 RowTop+21：六神 / 伏神 / 世应 / 变卦世应；
/// - 纳音基线 RowTop+31：主卦/变卦纳音。
///
/// 行高固定 44；设计坐标空间宽 402，列左缘冻结：六神18 伏神1·44 伏神2·70
/// 主卦文136 主卦爻212 世应244 动爻260 箭头277 变卦文278 变卦爻368 变卦世应396。
/// 主/变卦文本列宽固定为 64，超长文本在列缘裁剪（无省略号），
/// 任何情况下不侵占爻槽；整行 FittedBox(contain) 自适应缩放。
class ReviewHexagramLineRow extends StatelessWidget {
  const ReviewHexagramLineRow({
    super.key,
    required this.line,
    this.selected = false,
    this.onTap,
    this.mainAnchorKey,
    this.changedAnchorKey,
    this.rowKey,
  });

  final ReviewLineView line;
  final bool selected;
  final VoidCallback? onTap;
  final GlobalKey? mainAnchorKey;
  final GlobalKey? changedAnchorKey;
  final GlobalKey? rowKey;

  static const double _designW = BoardColumnLayout.width;
  static const double _rowH = 44;

  static const double _spiritBaseline = 21;
  static const double _yaoCenterY = 22;

  YaoKind get _mainYaoKind {
    if (line.isVoid) return YaoKind.voidYao;
    return line.isYang ? YaoKind.yang : YaoKind.yin;
  }

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: _designW,
      height: _rowH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 六神 / 伏神
          _leftText(
            BoardColumnLayout.sixSpiritLeft,
            line.sixSpirit ?? '—',
            _spiritStyle,
            _spiritBaseline,
            width: BoardColumnLayout.sixSpiritWidth,
            slotKey: Key('six_spirit_slot_${line.position}'),
          ),
          if (line.hiddenSpirit1 != null || line.hiddenSpirit2 != null) ...[
            if (line.hiddenSpirit1 != null)
              _leftText(
                BoardColumnLayout.primaryHiddenLeft,
                line.hiddenSpirit1!,
                _hiddenStyle,
                _spiritBaseline,
                width: BoardColumnLayout.primaryHiddenWidth,
              ),
            if (line.hiddenSpirit2 != null)
              _leftText(
                BoardColumnLayout.oppositeHiddenLeft,
                line.hiddenSpirit2!,
                _hiddenStyle,
                _spiritBaseline,
                width: BoardColumnLayout.oppositeHiddenWidth,
              ),
          ],
          for (var i = 0; i < line.hiddenSpiritFacts.length && i < 2; i++)
            _hiddenIdentity(
              BoardColumnLayout.primaryHiddenLeft + i * 44,
              line.hiddenSpiritFacts[i],
              index: i,
              key: Key('hidden_slot_${line.position}_$i'),
            ),
          if (line.primaryHidden != null)
            _hiddenPalaceIdentity(
              BoardColumnLayout.primaryHiddenLeft,
              line.primaryHidden!,
              key: Key('main_hidden_slot_${line.position}'),
            ),
          if (line.oppositeHidden != null)
            _hiddenPalaceIdentity(
              BoardColumnLayout.oppositeHiddenLeft,
              line.oppositeHidden!,
              key: Key('opposite_hidden_slot_${line.position}'),
            ),

          // 主卦与变卦复用同一固定 Cell，避免弹性空白改变爻象位置。
          Positioned(
            left: BoardColumnLayout.mainTextLeft,
            top: 0,
            child: SizedBox(
              key: mainAnchorKey,
              child: HexagramLineCell(
                key: Key('main_line_cell_${line.position}'),
                text: line.mainPrimary,
                identity: line.identity,
                naYin: line.displayExtra,
                naYinKey: Key('main_nayin_${line.position}'),
                onNaYinTap: onTap,
                textContentKey: Key('main_text_${line.position}'),
                shiYing: line.shiYing,
                shiYingKey: Key('shi_ying_${line.position}'),
                yaoKey: Key('yao_glyph_${line.position}'),
                textKey: Key('main_text_slot_${line.position}'),
                shiYingSlotKey: Key('main_shi_ying_slot_${line.position}'),
                yaoSlotKey: Key('main_yao_slot_${line.position}'),
                yaoKind: _mainYaoKind,
              ),
            ),
          ),
          // 动爻标记
          if (line.movementType.isMoving)
            Positioned(
              left: 260 - MovingMarker.markerSize / 2,
              top: _yaoCenterY - MovingMarker.markerSize / 2,
              width: MovingMarker.markerSize,
              height: MovingMarker.markerSize,
              child: MovingMarker(
                key: Key('moving_marker_${line.position}'),
                isYin: line.movementType == MovementType.laoYang,
              ),
            ),

          Positioned(
            // 镜像 Cell 的起点是整组最左缘；文本位于 Cell 内侧右端。
            left: BoardColumnLayout.changedYaoLeft,
            top: 0,
            child: SizedBox(
              key: changedAnchorKey,
              child: HexagramLineCell(
                key: Key('changed_line_cell_${line.position}'),
                text: line.changed?.primaryLabel ?? '',
                identity: line.changed?.identity,
                naYin: line.changed?.displayExtra,
                naYinKey: Key('changed_nayin_${line.position}'),
                onNaYinTap: onTap,
                textContentKey: Key('changed_text_${line.position}'),
                shiYing: line.changedShiYing,
                shiYingKey: Key('changed_shi_ying_${line.position}'),
                yaoKey: Key('changed_yao_glyph_${line.position}'),
                textKey: Key('changed_text_slot_${line.position}'),
                shiYingSlotKey: Key('changed_shi_ying_slot_${line.position}'),
                yaoSlotKey: Key('changed_yao_slot_${line.position}'),
                reverse: true,
                yaoKind: line.changed?.movementType == null
                    ? null
                    : line.changed!.isVoid
                    ? YaoKind.voidYao
                    : (line.changed!.isYang ? YaoKind.yang : YaoKind.yin),
              ),
            ),
          ),
        ],
      ),
    );

    final row = Container(
      key: Key('review_line_${line.position}'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE6F0EB) : Colors.transparent,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: content,
      ),
    );

    final anchoredRow = rowKey == null
        ? row
        : KeyedSubtree(key: rowKey, child: row);
    if (onTap == null) return anchoredRow;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: anchoredRow),
    );
  }

  Widget _leftText(
    double left,
    String text,
    TextStyle style,
    double baseline, {
    double? width,
    Key? textKey,
    Key? slotKey,
  }) {
    return Positioned(
      key: slotKey,
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: Align(
        // 有列宽封顶时左对齐（列左缘即文本起点），否则按内容自适应。
        alignment: width == null ? Alignment.topCenter : Alignment.topLeft,
        child: Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(text, key: textKey, maxLines: 1, style: style),
        ),
      ),
    );
  }

  Widget _hiddenIdentity(
    double left,
    FushenResult result, {
    required int index,
    Key? key,
  }) {
    return Positioned(
      key: key,
      left: left,
      width: 42,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Baseline(
            key: Key('hidden_text_slot_${line.position}_$index'),
            baseline: _spiritBaseline,
            baselineType: TextBaseline.alphabetic,
            child: LineIdentityText.buildText(
              ReviewLineIdentity(
                relative: result.relative.label,
                ganZhi: result.ganZhi,
                element: result.element.label,
              ),
              compact: true,
              style: _hiddenStyle,
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            key: Key('hidden_nayin_${line.position}_$index'),
            label: '纳音：${result.naYin}',
            hint: '伏神 ${line.position}爻，可点击查看备注',
            button: true,
            onTap: onTap,
            child: Baseline(
              baseline: 10,
              baselineType: TextBaseline.alphabetic,
              child: Text(result.naYin, style: _naYinStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hiddenPalaceIdentity(double left, HiddenPalaceLine line, {Key? key}) {
    return Positioned(
      key: key,
      left: left,
      width: 42,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Baseline(
            key: Key('hidden_text_slot_${this.line.position}_palace'),
            baseline: _spiritBaseline,
            baselineType: TextBaseline.alphabetic,
            child: LineIdentityText.buildText(
              ReviewLineIdentity(
                relative: line.relative.label,
                ganZhi: line.ganZhi,
                element: line.element.label,
              ),
              compact: true,
              style: _hiddenStyle,
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            key: Key('hidden_nayin_${this.line.position}_palace'),
            label: '纳音：${line.naYin}',
            hint: '伏藏 ${this.line.position}爻，可点击查看备注',
            button: true,
            onTap: onTap,
            child: Baseline(
              baseline: 10,
              baselineType: TextBaseline.alphabetic,
              child: Text(line.naYin, style: _naYinStyle),
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _spiritStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF9A7B45),
    height: 1.2,
  );

  static const TextStyle _hiddenStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: Color(0xFF71838B),
    height: 1.2,
  );

  static const TextStyle _naYinStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF71838B),
    height: 1.2,
  );
}
