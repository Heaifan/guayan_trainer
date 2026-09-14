import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_evaluator.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_result.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';

class MockOp extends OperatorImpl {
  final bool match;
  final List<EvidenceId> supports;

  const MockOp(String id, this.match, this.supports) : _id = id;
  final String _id;

  @override
  String get operatorId => _id;

  @override
  PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext context) {
    if (match) return PredicateResult.match(supports);
    return PredicateResult.fail;
  }
}

void main() {
  group('PredicateEvaluator', () {
    late PredicateEvaluator evaluator;
    late BindingContext context;
    late FactSnapshot snapshot;

    setUp(() {
      final registry = OperatorRegistry();
      registry.register(const MockOp('opA', true, [EvidenceId('eA')]));
      registry.register(const MockOp('opB', true, [EvidenceId('eB')]));
      registry.register(const MockOp('opFail', false, []));
      
      evaluator = PredicateEvaluator(registry);
      context = BindingContext();
      snapshot = FactSnapshot.build([]);
    });

    test('ALL collects supports when all match', () {
      final expr = AllExpr([
        const PredicateExpr(operatorId: 'opA', operands: []),
        const PredicateExpr(operatorId: 'opB', operands: []),
      ]);
      final result = evaluator.evaluate(expr, context, snapshot);
      expect(result.matched, true);
      expect(result.supports, containsAll([const EvidenceId('eA'), const EvidenceId('eB')]));
    });

    test('ANY collects ALL matched branches supports', () {
      final expr = AnyExpr([
        const PredicateExpr(operatorId: 'opA', operands: []),
        const PredicateExpr(operatorId: 'opFail', operands: []),
        const PredicateExpr(operatorId: 'opB', operands: []),
      ]);
      final result = evaluator.evaluate(expr, context, snapshot);
      expect(result.matched, true);
      expect(result.supports, containsAll([const EvidenceId('eA'), const EvidenceId('eB')]));
    });

    test('NOT returns true with empty supports when child fails', () {
      final expr = NotExpr(const PredicateExpr(operatorId: 'opFail', operands: []));
      final result = evaluator.evaluate(expr, context, snapshot);
      expect(result.matched, true);
      expect(result.supports, isEmpty);
    });

    test('NOT returns false when child succeeds', () {
      final expr = NotExpr(const PredicateExpr(operatorId: 'opA', operands: []));
      final result = evaluator.evaluate(expr, context, snapshot);
      expect(result.matched, false);
    });
  });
}
