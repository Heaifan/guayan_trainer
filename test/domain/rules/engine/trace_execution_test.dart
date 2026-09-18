import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_evaluator.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';

void main() {
  final snapshot = FactSnapshot.build([
    FactRecord(
      factId: 'spirit-5',
      subject: const SemanticRef('line', '5'),
      predicateId: 'spirit',
      value: RuleValue.string('spirit.xuan_wu'),
      origin: FactOrigin.baseRelation,
    ),
  ]);

  test('binding trace records direct resolution', () {
    final result = const BindingResolver().resolveWithTrace([
      RuleBinding(name: 'A', selector: DirectSelector('line/5')),
    ], snapshot);

    expect(result.context.get('A'), const SemanticRef('line', '5'));
    expect(result.traces.single.status, RuleTraceStatus.matched);
    expect(result.traces.single.resolvedObjects.single,
        const SemanticRef('line', '5'));
  });

  test('predicate trace includes expected and actual values', () {
    final result = PredicateEvaluator(OperatorRegistry()).evaluate(
      PredicateExpr(
        operatorId: 'spirit',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('spirit.bai_hu')),
        ],
      ),
      BindingContext({'A': const SemanticRef('line', '5')}),
      snapshot,
    );

    expect(result.matched, isFalse);
    expect(result.trace!.status, RuleTraceStatus.notMatched);
    expect(result.trace!.expected, 'spirit.bai_hu');
    expect(result.trace!.actual, 'spirit.xuan_wu');
  });

  test('engine exposes matched, not matched, skipped, and error statuses', () {
    RuleDefinition rule(String id, bool enabled, String target) => RuleDefinition(
      ruleId: RuleId(id), version: RuleVersion('1.0.0'), origin: RuleOrigin.CUSTOM,
      namespace: 'common', categoryId: 'common', stage: RuleStage.tag,
      title: id, description: '', provenance: 'test', enabled: enabled,
      bindings: [RuleBinding(name: 'A', selector: DirectSelector(target))],
      condition: PredicateExpr(operatorId: 'spirit', operands: [
        const BindingRefOperand('A'), LiteralOperand(RuleValue.string('spirit.xuan_wu')),
      ]), actions: const [],
    );
    final run = RuleEngine().execute([
      rule('matched', true, 'line/5'),
      rule('skipped', false, 'line/5'),
      rule('error', true, 'broken'),
    ], snapshot);

    expect(run.traces.map((trace) => trace.status), containsAll([
      RuleTraceStatus.matched,
      RuleTraceStatus.skipped,
      RuleTraceStatus.error,
    ]));
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.notMatched), isFalse);
  });
}
