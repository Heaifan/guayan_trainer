import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/widgets/hexagram_line_cell.dart';
import 'package:guayan_trainer/presentation/shared/yao_glyph.dart';

void main() {
  testWidgets('relation anchor binds to the actual 24x6 yao glyph', (tester) async {
    final anchorKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HexagramLineCell(
              text: '父母辛亥水',
              yaoKind: YaoKind.yang,
              yaoAnchorKey: anchorKey,
              yaoSlotKey: const ValueKey('yao-slot'),
            ),
          ),
        ),
      ),
    );

    final box = anchorKey.currentContext!.findRenderObject() as RenderBox;
    expect(box.size, const Size(YaoGlyph.slotWidth, YaoGlyph.slotHeight));
  });
}
