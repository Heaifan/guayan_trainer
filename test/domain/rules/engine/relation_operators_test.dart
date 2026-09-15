import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'operator_test_fixture.dart';

void main() {
  group('Relation Operators', () {
    late OperatorRegistry registry;
    setUp(() {
      registry = OperatorRegistry();
    });

    test('generate', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.generate, [
        ResolvedOperand.ref(refM),
        ResolvedOperand.ref(refA),
      ]);
      expect(res.matched, true);
    });

    test('ru_mu', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.ruMu, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.ref(refT),
      ]);
      expect(res.matched, true);
    });

    test('chong_mu', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.chongMu, [
        ResolvedOperand.ref(refD),
        ResolvedOperand.ref(refT),
      ]);
      expect(res.matched, true);
    });

    test('chu_mu', () {
      final res = evalOp(registry, createOperatorTestSnapshot(), ConditionId.chuMu, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.ref(refT),
        ResolvedOperand.ref(refD),
      ]);
      expect(res.matched, true);
    });
  });
}
