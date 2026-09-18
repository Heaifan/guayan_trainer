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
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

FactSnapshot _snapshot({String spirit = 'spirit.xuan_wu'}) => FactSnapshot.build([
  FactRecord(
    factId: 'spirit-5', subject: const SemanticRef('line', '5'),
    predicateId: 'spirit', value: RuleValue.string(spirit),
    origin: FactOrigin.baseRelation,
  ),
]);

RuleDefinition _rule(RuleExpr condition, {String selector = 'dynamic.line.by_spirit'}) => RuleDefinition(
  ruleId: RuleId('empty-$selector'), version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM, namespace: 'common', categoryId: 'common',
  stage: RuleStage.tag, title: '动态为空', description: '', provenance: 'test',
  bindings: [
    const RuleBinding(name: 'A', selector: DirectSelector('line/5')),
    RuleBinding(name: 'C', selector: DynamicBindingSelector(
      selectorId: selector, parameters: {'spirit': 'spirit.bai_hu'},
    )),
  ],
  condition: condition,
  actions: const [TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'A')],
);

PredicateExpr _spirit(String binding, String value) => PredicateExpr(
  operatorId: 'spirit',
  operands: [BindingRefOperand(binding), LiteralOperand(RuleValue.string(value))],
);

void main() {
  test('有路冲家: quantified branch match survives an empty white-tiger branch', () {
    final snapshot = FactSnapshot.build([
      FactRecord(
        factId: 'branch-2', subject: const SemanticRef('line', '2'),
        predicateId: 'branch', value: RuleValue.string('寅'),
        origin: FactOrigin.baseRelation,
      ),
      FactRecord(
        factId: 'branch-3', subject: const SemanticRef('line', '3'),
        predicateId: 'branch', value: RuleValue.string('申'),
        origin: FactOrigin.baseRelation,
      ),
      FactRecord(
        factId: 'branch-5', subject: const SemanticRef('line', '5'),
        predicateId: 'branch', value: RuleValue.string('子'),
        origin: FactOrigin.baseRelation,
      ),
    ]);
    final rule = RuleDefinition(
      ruleId: RuleId('road-clashes-home'), version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM, namespace: 'common', categoryId: 'common',
      stage: RuleStage.tag, title: '有路冲家', description: '', provenance: 'test',
      bindings: const [
        RuleBinding(name: 'B', selector: DirectSelector('line/3')),
        RuleBinding(name: 'C', selector: DynamicBindingSelector(
          selectorId: 'dynamic.line.by_spirit',
          parameters: {'spirit': 'spirit.bai_hu'},
        )),
      ],
      condition: AnyExpr([
        QuantifiedExpr(
          bindingName: 'candidate',
          selector: DynamicBindingSelector(selectorId: 'dynamic.line.all'),
          kind: QuantifierKind.any,
          node: PredicateExpr(operatorId: 'branch_clashes', operands: [
            const BindingRefOperand('candidate'), const BindingRefOperand('B'),
          ]),
        ),
        PredicateExpr(operatorId: 'branch_clashes', operands: [
          const BindingRefOperand('C'), const BindingRefOperand('B'),
        ]),
      ]),
      actions: const [TagAction(categoryId: 'image', tagId: 'road_clashes_home', subjectBinding: 'B')],
    );

    final run = RuleEngine().execute([rule], snapshot);
    expect(run.tags, hasLength(1));
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.matched), isTrue);
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.error), isFalse);
  });

  test('ANY treats an empty dynamic binding as false while another branch matches', () {
    final run = RuleEngine().execute([
      _rule(AnyExpr([_spirit('A', 'spirit.xuan_wu'), _spirit('C', 'spirit.bai_hu')])),
    ], _snapshot());

    expect(run.tags, hasLength(1));
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.matched), isTrue);
    expect(run.traces.expand((trace) => trace.children)
        .any((trace) => trace.status == RuleTraceStatus.notMatched && trace.reason == 'NO_MATCH'), isTrue);
  });

  test('ANY with an empty dynamic binding and false branches is NOT_MATCHED', () {
    final run = RuleEngine().execute([
      _rule(AnyExpr([_spirit('A', 'spirit.bai_hu'), _spirit('C', 'spirit.bai_hu')])),
    ], _snapshot());

    expect(run.tags, isEmpty);
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.notMatched), isTrue);
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.error), isFalse);
  });

  test('ALL with an empty dynamic binding is NOT_MATCHED', () {
    final run = RuleEngine().execute([
      _rule(AllExpr([_spirit('A', 'spirit.xuan_wu'), _spirit('C', 'spirit.bai_hu')])),
    ], _snapshot());

    expect(run.tags, isEmpty);
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.notMatched), isTrue);
    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.error), isFalse);
  });

  test('unknown dynamic selector remains ERROR', () {
    final run = RuleEngine().execute([
      _rule(_spirit('C', 'spirit.bai_hu'), selector: 'dynamic.line.unknown'),
    ], _snapshot());

    expect(run.traces.any((trace) => trace.status == RuleTraceStatus.error), isTrue);
  });
}
