import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'operator_test_fixture.dart';

void main() {
  group('Tag Operator', () {
    late OperatorRegistry registry;
    setUp(() {
      registry = OperatorRegistry();
    });

    test('has_tag', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.hasTag, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('shensha')),
        ResolvedOperand.literal(RuleValue.string('shensha.custom.foo')),
      ]);
      expect(res.matched, true);
    });
  });
}
