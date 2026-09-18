import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  test('quantified line matches become independent action subjects', () {
    final snapshot = FactSnapshot.build([
      for (final line in ['2', '5'])
        FactRecord(
          factId: 'relative-$line',
          subject: SemanticRef('line', line),
          predicateId: 'relative',
          value: RuleValue.string('relative.descendant'),
          origin: FactOrigin.baseRelation,
        ),
    ]);
    final rule = RuleDefinition(
      ruleId: RuleId('scoped'), version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM, namespace: 'common', categoryId: 'common',
      stage: RuleStage.tag, title: '子孙道路', description: '', provenance: 'test',
      bindings: const [],
      condition: QuantifiedExpr(
        bindingName: 'line',
        selector: const DynamicBindingSelector(selectorId: 'dynamic.line.all'),
        kind: QuantifierKind.any,
        node: PredicateExpr(
          operatorId: 'relative',
          operands: [
            BindingRefOperand('line'),
            LiteralOperand(RuleValue.string('relative.descendant')),
          ],
        ),
      ),
      actions: const [TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'line')],
    );

    final run = RuleEngine().execute([rule], snapshot);
    expect(run.tags.map((fact) => fact.subject), containsAll([
      const SemanticRef('line', '2'), const SemanticRef('line', '5'),
    ]));
    final matched = run.traces.firstWhere((trace) => trace.label == '子孙道路');
    expect(matched.children.where((trace) => trace.kind.name == 'action'), hasLength(2));
  });
}
