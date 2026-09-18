import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/review_demo_data.dart';
import 'package:guayan_trainer/presentation/review/review_page.dart';

void main() {
  Future<void> pumpReview(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewPage(
          initialCase: ReviewDemoData.hexagramCase(),
          initialProfile: ReviewDemoData.profile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('main and changed cells use mirrored yao/text spacing', (
    tester,
  ) async {
    await pumpReview(tester);

    final mainText = tester.getRect(find.byKey(const Key('main_text_slot_6')));
    final mainYao = tester.getRect(find.byKey(const Key('main_yao_slot_6')));
    final changedYao = tester.getRect(
      find.byKey(const Key('changed_yao_slot_6')),
    );
    final changedText = tester.getRect(
      find.byKey(const Key('changed_text_slot_6')),
    );
    expect(
      mainYao.left - mainText.right,
      closeTo(changedText.left - changedYao.right, 0.5),
    );
  });

  testWidgets('changed shi-ying remains inside the mirrored board columns', (
    tester,
  ) async {
    await pumpReview(tester);

    final cell = tester.getRect(find.byKey(const Key('changed_line_cell_4')));
    final shiYing = tester.getRect(find.byKey(const Key('changed_shi_ying_4')));
    expect(shiYing.left, greaterThanOrEqualTo(cell.left));
    expect(shiYing.right, lessThanOrEqualTo(cell.right));
  });

  testWidgets('main and changed rows keep the same position mapping', (
    tester,
  ) async {
    await pumpReview(tester);
    final tops = [
      for (final position in [6, 5, 4, 3, 2, 1])
        tester.getTopLeft(find.byKey(Key('review_line_$position'))).dy,
    ];
    for (var i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]));
    }
    for (final position in [1, 2, 3, 4, 5, 6]) {
      final main = tester.getRect(find.byKey(Key('main_text_$position')));
      final changed = tester.getRect(
        find.byKey(Key('changed_text_$position')),
      );
      expect(main.top, closeTo(changed.top, 0.5));
    }
  });
}
