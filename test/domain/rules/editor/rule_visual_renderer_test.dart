import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_visual_renderer.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_editor_draft.dart';
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

void main() {
  test('renders quantified dynamic AST and stable tag labels without placeholders', () {
    final rule = RuleDefinition(
      ruleId: RuleId('r5-road-clashes-home'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'r5',
      categoryId: 'image',
      stage: RuleStage.tag,
      title: '有路冲家',
      description: '',
      provenance: 'test',
      bindings: const [
        RuleBinding(name: 'B', selector: DirectSelector('line/3')),
        RuleBinding(name: 'C', selector: DynamicBindingSelector(
          selectorId: 'dynamic.line.by_spirit',
          parameters: {'spirit': 'spirit.bai_hu'},
        )),
      ],
      condition: AnyExpr([
        QuantifiedExpr(
          bindingName: 'X',
          selector: const DynamicBindingSelector(selectorId: 'dynamic.line.all'),
          kind: QuantifierKind.any,
          node: AllExpr([
            PredicateExpr(operatorId: 'relative', operands: [
              const BindingRefOperand('X'),
              LiteralOperand(RuleValue.string('relative.child')),
            ]),
            PredicateExpr(operatorId: 'branch_clashes', operands: [
              const BindingRefOperand('X'),
              const BindingRefOperand('B'),
            ]),
          ]),
        ),
        PredicateExpr(operatorId: 'branch_clashes', operands: [
          const BindingRefOperand('C'),
          const BindingRefOperand('B'),
        ]),
      ]),
      actions: const [TagAction(
        categoryId: 'image',
        tagId: 'road_clash_home',
      )],
    );
    final texts = const RuleVisualRenderer()
        .render(rule)
        .expand((line) => line.tokens)
        .map((token) => token.text)
        .toList();

    expect(texts, containsAll(['任一爻', '六亲', '子孙', '白虎所临之爻', '有路冲家']));
    expect(texts, isNot(contains('[选择条件]')));
    expect(texts, isNot(contains('[选择对象]')));
    expect(texts, isNot(contains('road_clash_home')));

    final saved = RuleEditorDraft.fromDefinition(rule).toDefinition();
    expect(
      PortableRuleCodec.encode(saved),
      PortableRuleCodec.encode(rule),
    );
  });

  test('renders AST as numbered indented tokens without technical ids', () {
    final rule = RuleDefinition(
      ruleId: RuleId('custom.test'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'common',
      categoryId: 'common',
      stage: RuleStage.tag,
      title: 'test',
      description: '',
      provenance: 'test',
      bindings: const [
        RuleBinding(name: 'A', selector: DirectSelector('line/5')),
      ],
      condition: PredicateExpr(
        operatorId: 'spirit',
        operands: [
          const BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('spirit.bai_hu')),
        ],
      ),
      actions: const [
        TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'A'),
      ],
    );
    final lines = const RuleVisualRenderer().render(rule);
    expect(lines.first.tokens.single.text, '若');
    expect(lines[1].indent, 1);
    expect(
      lines[1].tokens.map((token) => token.text),
      containsAll(['五爻', '六神', '白虎']),
    );
    expect(lines.last.tokens.first.text, '取象');
    expect(lines.last.tokens[1].text, '道路');
    expect(
      lines.expand((line) => line.tokens).any((token) => token.text == 'A'),
      isFalse,
    );
  });

  test('renders logical AST nodes as actual connectors', () {
    final condition = AnyExpr(const [
      PredicateExpr(operatorId: 'xun_kong', operands: [BindingRefOperand('A')]),
      NotExpr(
        PredicateExpr(operatorId: 'yue_po', operands: [BindingRefOperand('A')]),
      ),
    ]);
    final rule = RuleDefinition(
      ruleId: RuleId('custom.logic'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'common',
      categoryId: 'common',
      stage: RuleStage.tag,
      title: 'test',
      description: '',
      provenance: 'test',
      bindings: const [
        RuleBinding(name: 'A', selector: DirectSelector('line/1')),
      ],
      condition: condition,
      actions: const [],
    );
    final texts = const RuleVisualRenderer()
        .render(rule)
        .expand((line) => line.tokens)
        .map((token) => token.text);
    expect(texts, contains('或'));
    expect(texts, contains('非'));
  });
}
