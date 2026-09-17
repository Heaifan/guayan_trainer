import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/structure_fact.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_evaluator.dart';

void main() {
  test('formed structure fact is consumable by runtime', () {
    final snapshot = FactSnapshot.build([], [], [
      StructureFact(
        id: 'structure.san_he.wood',
        kind: StructureKind.sanHe,
        state: StructureState.formed,
        element: '木',
        memberObjectIds: ['line/2', 'line/4', 'line/6'],
      ),
    ]);
    final expr = PredicateExpr(
      operatorId: 'structure_formed',
      operands: [LiteralOperand(RuleValue.string('sanHe.木'))],
    );

    final result = PredicateEvaluator(
      OperatorRegistry(),
    ).evaluate(expr, BindingContext(), snapshot);

    expect(result.matched, isTrue);
    expect(result.supports.single.id, 'structure.san_he.wood');
  });
}
