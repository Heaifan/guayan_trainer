import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'operator_test_fixture.dart';

void main() {
  group('State Operators', () {
    late OperatorRegistry registry;
    setUp(() {
      registry = OperatorRegistry();
    });

    test('xun_kong', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.xunKong, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('yue_po', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.yuePo, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('ri_po', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.riPo, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('in_tomb', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.inTomb, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('empty', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.empty, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });
  });
}
