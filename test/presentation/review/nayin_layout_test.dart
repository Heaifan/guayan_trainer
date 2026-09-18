import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/review_demo_data.dart';
import 'package:guayan_trainer/presentation/review/review_page.dart';

void main() {
  Future<void> pumpReview(WidgetTester tester, {double? width}) async {
    if (width != null) {
      await tester.binding.setSurfaceSize(Size(width, 900));
    }
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

  testWidgets('main, changed, and hidden NaYin flow below their text', (
    tester,
  ) async {
    await pumpReview(tester);

    for (final pair in [
      ('main_text_6', 'main_nayin_6'),
      ('changed_text_6', 'changed_nayin_6'),
      ('hidden_text_slot_1_0', 'hidden_nayin_1_0'),
    ]) {
      expect(
        tester
            .getRect(find.byKey(Key(pair.$1)))
            .overlaps(tester.getRect(find.byKey(Key(pair.$2)))),
        isFalse,
        reason: '${pair.$1} 与 ${pair.$2} 重叠',
      );
    }
  });

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('$width dp keeps the review board overflow-free', (
      tester,
    ) async {
      await pumpReview(tester, width: width);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('main and changed text remain aligned in one yao row', (
    tester,
  ) async {
    await pumpReview(tester);
    final main = tester.getRect(find.byKey(const Key('main_text_6')));
    final changed = tester.getRect(find.byKey(const Key('changed_text_6')));
    expect(main.top, changed.top);
    expect(main.bottom, changed.bottom);
  });
}
