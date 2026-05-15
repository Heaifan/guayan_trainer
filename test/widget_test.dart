import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/app.dart';

void main() {
  testWidgets('App loads home page', (WidgetTester tester) async {
    await tester.pumpWidget(const GuayanTrainerApp());
    expect(find.text('卦眼训练器'), findsOneWidget);
  });
}
