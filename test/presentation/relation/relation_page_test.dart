import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/relations/relations_page.dart';

void main() {
  testWidgets('ledger searches rule output and cycles relation type filter', (tester) async {
    final record = RelationRecord.state(
      id: 'rule:document',
      sourceKind: RelationSourceKind.rule,
      stateType: RelationStateType.xunKong,
      participants: [YaoEndpoint(LineScope.original, 1)],
      title: '父母旬空',
      subtitle: '取象：文书受阻',
      category: '状态',
    );
    await tester.pumpWidget(MaterialApp(home: RelationsPage(records: [record])));

    await tester.enterText(find.byType(TextField), '文书');
    expect(find.text('父母旬空'), findsOneWidget);
    await tester.tap(find.text('全部'));
    await tester.pump();
    expect(find.text('关系'), findsNWidgets(2));
    await tester.tap(find.text('关系').last);
    await tester.pump();
    expect(find.text('状态'), findsNWidgets(2));
  });
}
