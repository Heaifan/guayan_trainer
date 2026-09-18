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
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_test_runner.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

RuleDefinition _rule() => RuleDefinition(
  ruleId: RuleId('rule_test_hotfix'), version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM, namespace: 'common', categoryId: 'common',
  stage: RuleStage.tag, title: '白虎道路', description: '', provenance: 'test',
  bindings: const [RuleBinding(name: 'A', selector: DirectSelector('line/5'))],
  condition: PredicateExpr(operatorId: 'spirit', operands: [
    const BindingRefOperand('A'), LiteralOperand(RuleValue.string('spirit.bai_hu')),
  ]),
  actions: const [TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'A')],
);

FactSnapshot _snapshot(String spirit) => FactSnapshot.build([
  FactRecord(
    factId: 'spirit-5', subject: const SemanticRef('line', '5'),
    predicateId: 'spirit', value: RuleValue.string(spirit),
    origin: FactOrigin.baseRelation,
  ),
]);

void main() {
  test('test runner executes RuleDefinition directly and returns trace', () {
    final result = const RuleTestRunner().run(_rule(), _snapshot('spirit.bai_hu'));
    expect(result.traces.any((trace) => trace.status == RuleTraceStatus.matched), isTrue);
    expect(result.tags.single.value.value, 'road');
  });

  test('test runner preserves NOT_MATCHED without writing a RuleRun', () {
    final result = const RuleTestRunner().run(_rule(), _snapshot('spirit.xuan_wu'));
    expect(result.tags, isEmpty);
    expect(result.traces.any((trace) => trace.status == RuleTraceStatus.notMatched), isTrue);
  });

  test('portable round-trip uses the explicit envelope', () {
    final encoded = PortableRuleCodec.encode(_rule());
    expect(encoded['schemaVersion'], '1.0.0');
    expect(encoded['rule'], isA<Map>());
    expect(() => PortableRuleCodec.decode(RuleDefinitionCodec.toJson(_rule())), throwsFormatException);
    expect(RuleDefinitionCodec.toJson(PortableRuleCodec.decode(encoded)),
        RuleDefinitionCodec.toJson(_rule()));
  });
}
