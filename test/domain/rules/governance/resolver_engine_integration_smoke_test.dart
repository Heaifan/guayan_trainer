import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';
import '../engine/rule_engine_test_fixture.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

RuleDefinition _makeRule(
  String id,
  RuleOrigin origin,
  String resultKey, {
  String? overrideTarget,
}) {
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
    bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
    condition: PredicateExpr(
      operatorId: 'relative',
      operands: [
        BindingRefOperand('A'),
        LiteralOperand(RuleValue.string('fuMu')),
      ],
    ),
    actions: [DeriveAction(targetBinding: 'A', factKey: resultKey)],
    overrideTarget: overrideTarget != null ? RuleId(overrideTarget) : null,
  );
}

void main() {
  group('R5-D FAST-TRACK: Resolver -> Engine Integration Smoke', () {
    test(
      'CUSTOM rule overrides SYSTEM rule and Engine executes only CUSTOM',
      () {
        final sysRule = _makeRule(
          'sys.rule',
          RuleOrigin.SYSTEM,
          'state.sys_derived',
        );
        final cusRule = _makeRule(
          'cus.rule',
          RuleOrigin.CUSTOM,
          'state.cus_derived',
          overrideTarget: 'sys.rule',
        );

        final resolved = RuleResolver.resolve([sysRule, cusRule]);

        expect(resolved.activeRules.length, 1);
        expect(resolved.activeRules.first.ruleId.id, 'cus.rule');

        final engine = RuleEngine();
        final snapshot = createInitialSnapshot();

        final result = engine.execute(resolved.activeRules, snapshot);

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
