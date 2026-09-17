import 'package:flutter/material.dart';

import '../../../presentation/shared/yao_glyph.dart';
import '../review_page_state.dart';
import 'line_identity_text.dart';

/// 主卦与变卦共用的固定几何单元：文本、世应槽、爻象槽。
class HexagramLineCell extends StatelessWidget {
  const HexagramLineCell({
    super.key,
    required this.text,
    required this.yaoKind,
    this.yaoKey,
    this.shiYingKey,
    this.identity,
    this.shiYing,
    this.textWidth = 64,
    this.reverse = false,
    this.textKey,
    this.shiYingSlotKey,
    this.yaoSlotKey,
    this.textStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF243744),
      height: 1.2,
    ),
  });

  final String text;
  final ReviewLineIdentity? identity;
  final YaoKind? yaoKind;
  final Key? yaoKey;
  final Key? shiYingKey;
  final String? shiYing;
  final double textWidth;
  final TextStyle textStyle;
  final bool reverse;
  final Key? textKey;
  final Key? shiYingSlotKey;
  final Key? yaoSlotKey;

  static const _shiYingWidth = 14.0;
  static const _yaoWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    final textSlot = SizedBox(
      key: textKey,
      width: textWidth,
      child: Baseline(
        baseline: 16,
        baselineType: TextBaseline.alphabetic,
        child: identity == null
            ? Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: textStyle,
              )
            : LineIdentityText.buildText(identity!, style: textStyle),
      ),
    );
    final shiYingSlot = SizedBox(
      key: shiYingSlotKey,
      width: _shiYingWidth,
      child: Baseline(
        baseline: 21,
        baselineType: TextBaseline.alphabetic,
        child: Text(
          shiYing ?? '',
          key: shiYingKey,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB66F6F),
          ),
        ),
      ),
    );
    final yaoSlot = SizedBox(
      key: yaoSlotKey,
      width: _yaoWidth,
      child: Center(
        child: yaoKind == null
            ? const SizedBox(
                width: YaoGlyph.slotWidth,
                height: YaoGlyph.slotHeight,
              )
            : YaoGlyph(key: yaoKey, kind: yaoKind!),
      ),
    );
    return SizedBox(
      width: textWidth + 8 + _shiYingWidth + 4 + _yaoWidth,
      height: 44,
      child: Row(
        children: reverse
            ? [
                yaoSlot,
                const SizedBox(width: 4),
                shiYingSlot,
                const SizedBox(width: 8),
                textSlot,
              ]
            : [
                textSlot,
                const SizedBox(width: 8),
                shiYingSlot,
                const SizedBox(width: 4),
                yaoSlot,
              ],
      ),
    );
  }
}
