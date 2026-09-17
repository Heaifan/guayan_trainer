import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_result.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';

void main() {
  final a = const SemanticRef('line', 'A');
  final b = const SemanticRef('line', 'B');
  FactSnapshot snapshot() => FactSnapshot.build([
    FactRecord(
      factId: 'stem',
      subject: a,
      predicateId: 'stem',
      value: RuleValue.string('丙'),
      origin: FactOrigin.baseRelation,
    ),
    FactRecord(
      factId: 'branch-a',
      subject: a,
      predicateId: 'branch',
      value: RuleValue.string('寅'),
      origin: FactOrigin.baseRelation,
    ),
    FactRecord(
      factId: 'branch-b',
      subject: b,
      predicateId: 'branch',
      value: RuleValue.string('申'),
      origin: FactOrigin.baseRelation,
    ),
    FactRecord(
      factId: 'element-a',
      subject: a,
      predicateId: 'element',
      value: RuleValue.string('木'),
      origin: FactOrigin.baseRelation,
    ),
    FactRecord(
      factId: 'element-b',
      subject: b,
      predicateId: 'element',
      value: RuleValue.string('土'),
      origin: FactOrigin.baseRelation,
    ),
  ], const []);

  PredicateResult run(String id, List<ResolvedOperand> operands) {
    final op = OperatorRegistry().getOperator(id);
    expect(op, isNotNull);
    return op!.evaluate(
      operands,
      OperatorContext(snapshot: snapshot(), bindingContext: BindingContext()),
    );
  }

  test('attribute operators compare canonical facts', () {
    expect(
      run(ConditionId.stemIs, [
        ResolvedOperand.ref(a),
        ResolvedOperand.literal(RuleValue.string('丙')),
      ]).matched,
      isTrue,
    );
    expect(
      run(ConditionId.branchIs, [
        ResolvedOperand.ref(a),
        ResolvedOperand.literal(RuleValue.string('寅')),
      ]).matched,
      isTrue,
    );
    expect(
      run(ConditionId.elementIs, [
        ResolvedOperand.ref(a),
        ResolvedOperand.literal(RuleValue.string('木')),
      ]).matched,
      isTrue,
    );
  });

  test('foundational relations use domain semantics', () {
    final refs = [ResolvedOperand.ref(a), ResolvedOperand.ref(b)];
    expect(run(ConditionId.controls, refs).matched, isTrue);
    expect(run(ConditionId.branchClashes, refs).matched, isTrue);
  });
}
