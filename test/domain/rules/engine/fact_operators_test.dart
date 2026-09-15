import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'operator_test_fixture.dart';

void main() {
  group('Fact Operators', () {
    late OperatorRegistry registry;
    setUp(() {
      registry = OperatorRegistry();
    });

    test('relative', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.relative, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('parent')),
      ]);
      expect(res.matched, true);
    });

    test('spirit', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.spirit, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('azureDragon')),
      ]);
      expect(res.matched, true);
    });

    test('nayin_is', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.nayinIs, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('nayin.tian_he_shui')),
      ]);
      expect(res.matched, true);
    });
  });
}
