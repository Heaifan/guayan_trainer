import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_result.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';

void main() {
  group('Canonical Operators', () {
    late OperatorRegistry registry;
    late FactSnapshot snapshot;
    final refA = const SemanticRef('line', 'A');
    final refM = const SemanticRef('month', 'M');
    final refD = const SemanticRef('day', 'D');
    final refT = const SemanticRef('tomb', 'T');

    setUp(() {
      registry = OperatorRegistry();
      snapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: refA,
          predicateId: 'relative',
          value: RuleValue.string('parent'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f2',
          subject: refA,
          predicateId: 'spirit',
          value: RuleValue.string('azureDragon'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f3',
          subject: refA,
          predicateId: 'nayin',
          value: RuleValue.string('nayin.tian_he_shui'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f4',
          subject: refA,
          predicateId: 'state',
          value: RuleValue.string('xun_kong'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f5',
          subject: refA,
          predicateId: 'state',
          value: RuleValue.string('yue_po'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f6',
          subject: refA,
          predicateId: 'state',
          value: RuleValue.string('ri_po'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f7',
          subject: refA,
          predicateId: 'state',
          value: RuleValue.string('in_tomb'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f12',
          subject: refA,
          predicateId: 'has_tag_shensha',
          value: RuleValue.string('shensha.custom.foo'),
          origin: FactOrigin.derived,
        ),
        FactRecord(
          factId: 'f13',
          subject: refA,
          predicateId: 'state',
          value: RuleValue.string('kong_wang'),
          origin: FactOrigin.baseRelation,
        ),
      ], [
        RuntimeRelation(
          relationId: 'generate',
          subjects: ['month/M', 'line/A'],
          evidenceId: 'f8',
        ),
        RuntimeRelation(
          relationId: 'ru_mu',
          subjects: ['line/A', 'tomb/T'],
          evidenceId: 'f9',
        ),
        RuntimeRelation(
          relationId: 'chong_mu',
          subjects: ['day/D', 'tomb/T'],
          evidenceId: 'f10',
        ),
        RuntimeRelation(
          relationId: 'chu_mu',
          subjects: ['line/A', 'tomb/T', 'day/D'],
          evidenceId: 'f11',
        ),
      ]);
    });

    PredicateResult eval(String opId, List<ResolvedOperand> operands) {
      final op = registry.getOperator(opId);
      return op!.evaluate(
        operands,
        OperatorContext(snapshot: snapshot, bindingContext: BindingContext()),
      );
    }

    test('relative', () {
      final res = eval(ConditionId.relative, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('parent')),
      ]);
      expect(res.matched, true);
    });

    test('spirit', () {
      final res = eval(ConditionId.spirit, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('azureDragon')),
      ]);
      expect(res.matched, true);
    });

    test('nayin_is', () {
      final res = eval(ConditionId.nayinIs, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('nayin.tian_he_shui')),
      ]);
      expect(res.matched, true);
    });

    test('xun_kong', () {
      final res = eval(ConditionId.xunKong, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('yue_po', () {
      final res = eval(ConditionId.yuePo, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('ri_po', () {
      final res = eval(ConditionId.riPo, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('in_tomb', () {
      final res = eval(ConditionId.inTomb, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('empty', () {
      final res = eval(ConditionId.empty, [ResolvedOperand.ref(refA)]);
      expect(res.matched, true);
    });

    test('generate', () {
      final res = eval(ConditionId.generate, [
        ResolvedOperand.ref(refM),
        ResolvedOperand.ref(refA),
      ]);
      expect(res.matched, true);
    });

    test('ru_mu', () {
      final res = eval(ConditionId.ruMu, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.ref(refT),
      ]);
      expect(res.matched, true);
    });

    test('chong_mu', () {
      final res = eval(ConditionId.chongMu, [
        ResolvedOperand.ref(refD),
        ResolvedOperand.ref(refT),
      ]);
      expect(res.matched, true);
    });

    test('chu_mu', () {
      final res = eval(ConditionId.chuMu, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.ref(refT),
        ResolvedOperand.ref(refD),
      ]);
      expect(res.matched, true);
    });

    test('has_tag', () {
      final res = eval(ConditionId.hasTag, [
        ResolvedOperand.ref(refA),
        ResolvedOperand.literal(RuleValue.string('shensha')),
        ResolvedOperand.literal(RuleValue.string('shensha.custom.foo')),
      ]);
      expect(res.matched, true);
    });
  });
}
