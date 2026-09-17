import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/review_page_state.dart';
import 'package:guayan_trainer/presentation/review/widgets/review_shensha_card.dart';

void main() {
  testWidgets('19 items render together in a fixed-height 4x5 grid', (
    tester,
  ) async {
    final state = ReviewPageState(
      question: '测试',
      shenShaItems: [
        for (var i = 0; i < 19; i++)
          ReviewShenShaItem(name: '神煞$i', value: '子'),
      ],
      lines: const [],
      focusedRelations: const [],
      allRelations: const [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: ReviewShenShaCard(state: state),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shensha_page_1')), findsNothing);
    expect(find.byKey(const Key('shensha_神煞18')), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('shensha_card'))).height, 150);
    expect(find.byKey(const Key('shensha_神煞7')), findsOneWidget);
    expect(find.byKey(const Key('shensha_神煞8')), findsOneWidget);
  });
}
