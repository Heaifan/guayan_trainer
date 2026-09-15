import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/structural_operators.dart';

RuleDefinition buildRule(
  String id,
  RuleStage stage,
  List<RuleBinding> bindings,
  RuleExpr condition,
  List<RuleAction> actions,
) {
  return RuleDefinition(
    ruleId: RuleId(id),
    version: RuleVersion('1.0.0'),
    origin: RuleOrigin.SYSTEM,
    namespace: 'test',
    categoryId: 'test',
    title: 'test',
    description: 'test',
    provenance: 'test',
    stage: stage,
    bindings: bindings,
    condition: condition,
    actions: actions,
  );
}

void main() {
  group('RuleEngine', () {
    late FactSnapshot initialSnapshot;

    setUp(() {
      initialSnapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: SemanticRef('line', '2'),
          predicateId: 'relative',
          value: RuleValue.string('parent'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f3',
          subject: SemanticRef('line', '2'),
          predicateId: 'nayin',
          value: RuleValue.string('nayin.tian_he_shui'),
          origin: FactOrigin.baseRelation,
        ),
      ], [
        RuntimeRelation(
          relationId: 'generate',
          subjects: ['month/M', 'line/2'],
          evidenceId: 'e2'
        )
      ]);
    });

    test('T7 - Golden Chain', () {
      final rule1 = buildRule(
        'r1',
        RuleStage.derivedState,
        [
          const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
          const RuleBinding(name: 'M', selector: DirectSelector('month/M')),
        ],
        AllExpr([
          PredicateExpr(
            operatorId: ConditionId.relative,
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('parent')),
            ],
          ),
          PredicateExpr(
            operatorId: ConditionId.generate,
            operands: [BindingRefOperand('M'), BindingRefOperand('A')],
          ),
        ]),
        [const DeriveAction(targetBinding: 'A', factKey: 'parent_supported')],
      );

      final rule2 = buildRule(
        'r2',
        RuleStage.tag,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        AllExpr([
          PredicateExpr(
            operatorId: ConditionId.nayinIs,
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('nayin.tian_he_shui')),
            ],
          ),
          PredicateExpr(
            operatorId: 'derive_is',
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('parent_supported')),
            ],
          ),
        ]),
        [
          const TagAction(
            subjectBinding: 'A',
            categoryId: 'xiang',
            tagId: 'exam',
          ),
        ],
      );

      final engine = RuleEngine();
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      final run = engine.execute([rule1, rule2], initialSnapshot);

      expect(run.derivedFacts.length, 1, reason: 'Rule1 output exists');
      expect(run.tags.length, 1, reason: 'Rule2 Tag exists');
      
      final derivedFact = run.derivedFacts.first;
      expect(initialSnapshot.getFact(derivedFact.factId), isNull, reason: 'Rule1 output did not exist in original input');
      
      final tag = run.tags.first;
      expect(initialSnapshot.getFact(tag.factId), isNull, reason: 'Rule2 Tag did not exist in original input');

      final hit1 = run.ruleHits.firstWhere((h) => h.ruleId.id == 'r1', orElse: () => throw Exception('RuleHit-1 missing'));
      final hit2 = run.ruleHits.firstWhere((h) => h.ruleId.id == 'r2', orElse: () => throw Exception('RuleHit-2 missing'));
      expect(hit1, isNotNull, reason: 'RuleHit-1 exists');
      expect(hit2, isNotNull, reason: 'RuleHit-2 exists');

      // Rule2 support contains Rule1 derived evidence
      final hit2Node = run.evidenceNodes.firstWhere((n) => n.id == hit2.hitId);
      final supportsHit2 = run.evidenceEdges.where((e) => e.targetId == hit2Node.id && e.relationType == 'supports').map((e) => e.sourceId).toList();
      final derivedFactNode = run.evidenceNodes.firstWhere((n) => n.type == 'fact' && n.label.contains('parent_supported')); 
      
      expect(supportsHit2.contains(derivedFactNode.id), isTrue, reason: 'Rule2 support contains Rule1 derived evidence');
    });

    test('T8 - Order Invariance & Idempotence', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final rB = buildRule(
        'rB',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'derive_is',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('stateA')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateB')],
      );

      final engine = RuleEngine();
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      // Run 1: rA then rB
      final run1 = engine.execute([rA, rB], initialSnapshot);
      // Run 2: rB then rA
      final run2 = engine.execute([rB, rA], initialSnapshot);
      // Run 3: rA then rB again (Idempotence)
      final run3 = engine.execute([rA, rB], initialSnapshot);

      void compareRuns(AnalysisRun a, AnalysisRun b) {
        expect(a.derivedFacts.map((f) => '${f.predicateId}:${f.value}').toSet(), 
               b.derivedFacts.map((f) => '${f.predicateId}:${f.value}').toSet());
        expect(a.ruleHits.map((h) => h.ruleId).toSet(), 
               b.ruleHits.map((h) => h.ruleId).toSet());
        expect(a.evidenceNodes.map((n) => n.type).toSet(), 
               b.evidenceNodes.map((n) => n.type).toSet());
      }

      // T7 Order Invariance
      compareRuns(run1, run2);
      
      // T8 Idempotence
      compareRuns(run1, run3);
    });

    test('T9 - Immutable Input', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      
      final preSnapshot = initialSnapshot.facts.map((f) => '${f.factId}|${f.subject.kind}/${f.subject.key}|${f.predicateId}|${f.value.toString()}|${f.origin}').toList();
      
      RuleEngine().execute([rA], initialSnapshot);
      
      final postSnapshot = initialSnapshot.facts.map((f) => '${f.factId}|${f.subject.kind}/${f.subject.key}|${f.predicateId}|${f.value.toString()}|${f.origin}').toList();
      
      expect(postSnapshot, equals(preSnapshot));
    });

    test('T10 - AnalysisRun Immutability', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final run = RuleEngine().execute([rA], initialSnapshot);
      
      expect(() => run.derivedFacts.add(initialSnapshot.facts.first), throwsUnsupportedError);
      expect(() => run.tags.clear(), throwsUnsupportedError);
      expect(() => run.ruleHits.removeLast(), throwsUnsupportedError);
    });

    test('T11 - Convergent Cycle', () {
      final rX = buildRule(
        'rX',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        AnyExpr([
          PredicateExpr(
            operatorId: ConditionId.relative,
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('parent')),
            ],
          ),
          PredicateExpr(
            operatorId: 'derive_is',
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('stateY')),
            ],
          ),
        ]),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateX')],
      );
      final rY = buildRule(
        'rY',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'derive_is',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('stateX')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateY')],
      );

      final engine = RuleEngine();
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      final run = engine.execute([rX, rY], initialSnapshot);
      expect(run.derivedFacts.length, 2);
    });

    test('T1 - Restore Fail Closed (Throws on Unknown Operator)', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'unknown_operator',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      
      expect(() => RuleEngine().execute([rA], initialSnapshot), throwsA(isA<Exception>()));
    });

    test('T12 - Non-Convergence Guard', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final rB = buildRule(
        'rB',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'derive_is',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('stateA')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateB')],
      );

      final engine = RuleEngine(maxIterationsPerStage: 1);
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      expect(
        () => engine.execute([rA, rB], initialSnapshot),
        throwsA(isA<RuleEngineNonConvergence>()),
      );
    });
  });
}
