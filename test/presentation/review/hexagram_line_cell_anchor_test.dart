import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/widgets/hexagram_line_cell.dart';
import 'package:guayan_trainer/presentation/shared/yao_glyph.dart';

void main() {
  testWidgets('ordinary and return relations use separate text/yao anchors', (tester) async {
    final textAnchorKey = GlobalKey();
    final yaoAnchorKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HexagramLineCell(
              text: '父母辛亥水',
              yaoKind: YaoKind.yang,
              textAnchorKey: textAnchorKey,
              yaoAnchorKey: yaoAnchorKey,
              yaoSlotKey: const ValueKey('yao-slot'),
            ),
          ),
        ),
      ),
    );

    final textBox =
        textAnchorKey.currentContext!.findRenderObject() as RenderBox;
    final yaoBox =
        yaoAnchorKey.currentContext!.findRenderObject() as RenderBox;

    expect(yaoBox.size, const Size(YaoGlyph.slotWidth, YaoGlyph.slotHeight));
    expect(textBox.size.width, greaterThan(yaoBox.size.width));
    expect(textBox.size.height, greaterThan(yaoBox.size.height));

    final textRect = tester.getRect(find.byKey(textAnchorKey));
    final yaoRect = tester.getRect(find.byKey(yaoAnchorKey));
    expect(textRect.center.dx, lessThan(yaoRect.center.dx));
  });
}
