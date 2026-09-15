import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/dsl/dsl_parser.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';
import '../engine/rule_engine_test_fixture.dart';

RuleDefinition _makeRule(
  String id,
  RuleOrigin origin,
  String sourceCode, {
  String? overrideTarget,
}) {
  final parsed = GuayanDslParser.parse(sourceCode);
  return RuleDefinition(
    ruleId: RuleId(id),
    version: RuleVersion('1.0.0'),
    origin: origin,
    namespace: 'test',
    categoryId: 'test_cat',
    stage: RuleStage.derivedState,
    title: 'test title',
    description: 'test desc',
    provenance: 'test prov',
    bindings: parsed.bindings,
    condition: parsed.condition!,
    actions: parsed.actions,
    overrideTarget: overrideTarget != null ? RuleId(overrideTarget) : null,
  );
}

void main() {
  group('R5-D FAST-TRACK: Resolver -> Engine Integration Smoke', () {
    test(
      'CUSTOM rule overrides SYSTEM rule and Engine executes only CUSTOM',
      () {
        final sysSource =
            '''
鍙?A = @line/2
鑻?A 鍏翰涓虹埗姣?鍒?    寰?A state.sys_derived
'''
                .trim();

        final cusSource =
            '''
鍙?A = @line/2
鑻?A 鍏翰涓虹埗姣?鍒?    寰?A state.cus_derived
'''
                .trim();

        final sysRule = _makeRule('sys.rule', RuleOrigin.SYSTEM, sysSource);
        final cusRule = _makeRule(
          'cus.rule',
          RuleOrigin.CUSTOM,
          cusSource,
          overrideTarget: 'sys.rule',
        );

        final resolved = RuleResolver.resolve([sysRule, cusRule]);

        expect(resolved.activeRules.length, 1);
        expect(resolved.activeRules.first.ruleId.id, 'cus.rule');

        final engine = RuleEngine();
        final snapshot = createInitialSnapshot();

        final result = engine.execute(resolved.activeRules, snapshot);

        // Verification: sys_derived should not exist, cus_derived should exist.
        bool hasCus = result.derivedFacts.any(
          (f) => f.value.value == 'state.cus_derived',
        );
        bool hasSys = result.derivedFacts.any(
          (f) => f.value.value == 'state.sys_derived',
        );

        expect(hasCus, true, reason: 'CUSTOM rule should be executed');
        expect(hasSys, false, reason: 'SYSTEM rule should be suppressed');
      },
    );
  });
}
