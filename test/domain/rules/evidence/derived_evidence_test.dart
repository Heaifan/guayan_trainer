import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_action_codec.dart';
import 'package:guayan_trainer/domain/rules/evidence/derived_evidence.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  test('DerivedEvidence round-trips relation provenance and supports', () {
    final original = DerivedEvidence(
      id: const EvidenceId('evidence-1'),
      caseId: 'case-1',
      ruleId: const RuleId('r5-road'),
      ruleVersion: RuleVersion('1.0.0'),
      ruleOrigin: RuleOrigin.CUSTOM,
      actionType: 'tag',
      category: 'image',
      value: '有路冲家',
      targetKind: ActionTargetKind.relation,
      targetRefs: const [
        SemanticRef('line', '2'),
        SemanticRef('line', '3'),
      ],
      relationId: 'branch_clashes',
      supports: const [EvidenceId('branch-2'), EvidenceId('branch-3')],
      ruleRunId: 'run-1',
      traceRef: 'trace:r5-road',
    );

    expect(DerivedEvidence.fromJson(original.toJson()), original);
  });

  test('legacy subject action defaults to OBJECT target', () {
    final action = TagAction(
      categoryId: 'image',
      tagId: 'road',
      subjectBinding: 'A',
    );
    expect(action.target, isNull);
  });

  test('relation target has explicit source, target, and operator', () {
    const target = ActionTarget.relation(
      sourceBinding: 'X',
      targetBinding: 'B',
      relationId: 'branch_clashes',
    );
    expect(target.toJson(), {
      'kind': 'relation',
      'source': 'X',
      'target': 'B',
      'relationId': 'branch_clashes',
    });
  });

  test('action codec preserves legacy subject and optional relation target', () {
    const action = TagAction(
      categoryId: 'image',
      tagId: '有路冲家',
      target: ActionTarget.relation(
        sourceBinding: 'X',
        targetBinding: 'B',
        relationId: 'branch_clashes',
      ),
    );
    final restored = RuleActionCodec.fromJson(RuleActionCodec.toJson(action)) as TagAction;
    expect(restored.target?.sourceBinding, 'X');
    expect(restored.target?.targetBinding, 'B');
    expect(restored.target?.relationId, 'branch_clashes');
    expect(
      RuleActionCodec.fromJson(const {
        'type': 'tag',
        'cat': 'image',
        'tagId': 'road',
        'subject': 'A',
      }),
      isA<TagAction>(),
    );
  });
}
