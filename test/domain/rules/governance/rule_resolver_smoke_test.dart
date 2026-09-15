import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';

RuleDefinition _makeRule(
  String id,
  String version,
  RuleOrigin origin, {
  String? overrideTarget,
}) {
  return RuleDefinition(
    ruleId: RuleId(id),
    version: RuleVersion(version),
    origin: origin,
    namespace: 'test',
    categoryId: 'test_cat',
    stage: RuleStage.baseRelation,
    title: 'test title',
    description: 'test desc',
    provenance: 'test prov',
    bindings: [],
    condition: AllExpr([]),
    actions: [],
    overrideTarget: overrideTarget != null ? RuleId(overrideTarget) : null,
  );
}

void main() {
  group('R5-D FAST-TRACK RuleResolver Smoke Tests', () {
    test('Smoke 1: SYSTEM v1 and SYSTEM v2 -> v2 active', () {
      final r1 = _makeRule('sys.A', '1.0.0', RuleOrigin.SYSTEM);
      final r2 = _makeRule('sys.A', '2.0.0', RuleOrigin.SYSTEM);

      final result = RuleResolver.resolve([r1, r2]);

      expect(result.activeRules.length, 1);
      expect(result.activeRules.first.version.version, '2.0.0');
      expect(result.suppressedRules.length, 1);
      expect(result.suppressedRules.first.version.version, '1.0.0');
    });

    test(
      'Smoke 2: SYSTEM A and CUSTOM B overrides A -> B active, A suppressed',
      () {
        final sysA = _makeRule('sys.A', '1.0.0', RuleOrigin.SYSTEM);
        final cusB = _makeRule(
          'cus.B',
          '1.0.0',
          RuleOrigin.CUSTOM,
          overrideTarget: 'sys.A',
        );

        final result = RuleResolver.resolve([sysA, cusB]);

        expect(result.activeRules.length, 1);
        expect(result.activeRules.first.ruleId.id, 'cus.B');
        expect(result.suppressedRules.length, 1);
        expect(result.suppressedRules.first.ruleId.id, 'sys.A');
      },
    );

    test('Smoke 3: Deterministic Resolution (order independent)', () {
      final sysA = _makeRule('sys.A', '1.0.0', RuleOrigin.SYSTEM);
      final sysA2 = _makeRule('sys.A', '2.0.0', RuleOrigin.SYSTEM);
      final cusB = _makeRule(
        'cus.B',
        '1.0.0',
        RuleOrigin.CUSTOM,
        overrideTarget: 'sys.A',
      );
      final sysC = _makeRule('sys.C', '1.0.0', RuleOrigin.SYSTEM);

      final list1 = [sysA, sysA2, cusB, sysC];
      final list2 = [sysC, cusB, sysA2, sysA];

      final res1 = RuleResolver.resolve(list1);
      final res2 = RuleResolver.resolve(list2);

      expect(res1.activeRules.length, res2.activeRules.length);
      for (int i = 0; i < res1.activeRules.length; i++) {
        expect(res1.activeRules[i].ruleId.id, res2.activeRules[i].ruleId.id);
      }
      expect(res1.activeRules.map((e) => e.ruleId.id).toList(), [
        'cus.B',
        'sys.C',
      ]);
    });
  });
}
