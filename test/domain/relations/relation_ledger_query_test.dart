import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/services/relation_annotation_store.dart';
import 'package:guayan_trainer/services/relation_ledger_query.dart';

void main() {
  final first = RelationRecord.relation(
    id: 'fact:a',
    sourceKind: RelationSourceKind.fact,
    relationType: RelationType.sheng,
    fromRef: YaoEndpoint(LineScope.original, 2),
    toRef: YaoEndpoint(LineScope.original, 1),
    title: '二爻生初爻',
    category: '生克',
    labels: ['木'],
    evidence: ['五行事实'],
  );
  final rule = RelationRecord.state(
    id: 'rule:document',
    sourceKind: RelationSourceKind.rule,
    stateType: RelationStateType.xunKong,
    participants: [YaoEndpoint(LineScope.original, 1)],
    title: '父母旬空',
    subtitle: '取象：文书受阻',
    category: '状态',
  );

  test('annotation survives record reprojection by stable id', () {
    final store = RelationAnnotationStore();
    store.upsert(caseId: 'case-1', recordId: first.id, note: '重点观察');

    expect(store.annotationFor(caseId: 'case-1', recordId: first.id)?.note, '重点观察');
    expect(store.annotationFor(caseId: 'case-1', recordId: 'fact:other'), isNull);
  });

  test('search includes rule output, labels, evidence, and note', () {
    final store = RelationAnnotationStore()
      ..upsert(caseId: 'case-1', recordId: rule.id, note: '文书可能有问题');
    final records = [rule, first];

    expect(RelationLedgerQuery.search(records, '文书', store: store, caseId: 'case-1'), [rule]);
    expect(RelationLedgerQuery.search(records, '五行'), [first]);
    expect(RelationLedgerQuery.search(records, '木'), [first]);
    expect(RelationLedgerQuery.search(records, '问题', store: store, caseId: 'case-1'), [rule]);
  });

  test('kind position category and keyword filters are ANDed', () {
    final result = RelationLedgerQuery.filter(
      [first, rule],
      kind: RelationKind.relation,
      position: 1,
      category: '生克',
      keyword: '二爻',
    );

    expect(result, [first]);
  });
}
