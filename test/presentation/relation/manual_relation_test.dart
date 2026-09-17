import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/services/manual_relation_store.dart';
import 'package:guayan_trainer/presentation/relations/relations_page.dart';
import 'package:flutter/material.dart';

void main() {
  test('manual relation creates a USER record with structured endpoints', () {
    final store = ManualRelationStore();
    final record = store.create(
      caseId: 'case-1',
      id: 'user:1',
      from: YaoEndpoint(LineScope.original, 1),
      to: YaoEndpoint(LineScope.original, 5),
      title: '竞争',
      note: '竞争对手',
    );

    expect(record.sourceKind, RelationSourceKind.user);
    expect(record.id, 'user:1');
    expect(record.fromRef, isA<YaoEndpoint>());
    expect(store.recordsFor('case-1'), [record]);
  });

  testWidgets('relation page exposes manual relation entry point', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RelationsPage(records: [])));
    expect(find.byKey(const Key('manual_relation_button')), findsOneWidget);
  });
}
