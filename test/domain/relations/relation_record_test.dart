import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_capability.dart';
import 'package:guayan_trainer/domain/relations/relation_projection.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';

void main() {
  final source = YaoEndpoint(LineScope.original, 2);
  final target = YaoEndpoint(LineScope.original, 1);

  test('relation record keeps relation and state as separate domain kinds', () {
    final relation = RelationRecord.relation(
      id: 'fact:sheng:2:1',
      sourceKind: RelationSourceKind.fact,
      relationType: RelationType.sheng,
      fromRef: source,
      toRef: target,
      title: '二爻生初爻',
    );
    final state = RelationRecord.state(
      id: 'fact:state:xun_kong:1',
      sourceKind: RelationSourceKind.fact,
      stateType: RelationStateType.xunKong,
      participants: [target],
      title: '初爻旬空',
    );

    expect(relation.kind, RelationKind.relation);
    expect(state.kind, RelationKind.state);
    expect(relation.participants, contains(source));
    expect(relation.participants, contains(target));
    expect(state.fromRef, isNull);
    expect(state.toRef, isNull);
  });

  test('projection uses RelationKey canonical as a stable fact id', () {
    final instance = RelationInstance.from(
      type: RelationType.liuChong,
      ruleId: SystemRuleIds.liuChong,
      source: source,
      target: target,
    );

    final first = RelationProjection.projectRelationInstances([instance]);
    final second = RelationProjection.projectRelationInstances([
      RelationInstance.from(
        type: RelationType.liuChong,
        ruleId: SystemRuleIds.liuChong,
        source: source,
        target: target,
      ),
    ]);

    expect(first.single.id, second.single.id);
    expect(first.single.participants, contains(source));
    expect(first.single.participants, contains(target));
    expect(first.single.kind, RelationKind.relation);
  });

  test('capability reports relation and state types actually present', () {
    final records = RelationProjection.projectRelationInstances([
      RelationInstance.from(
        type: RelationType.sheng,
        ruleId: SystemRuleIds.sheng,
        source: source,
        target: target,
      ),
    ]);
    final capability = RelationCapabilitySnapshot.fromRecords(records);

    expect(capability.supportedRelations, contains(RelationType.sheng));
    expect(capability.supportedRelations, isNot(contains(RelationType.ke)));
    expect(capability.supportedStates, isEmpty);
  });
}
