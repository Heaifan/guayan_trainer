import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guayan_trainer/domain/dsl/dsl_formatter.dart';
import 'package:guayan_trainer/domain/dsl/dsl_parser.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_evaluator.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/templates/rule_slot_definition.dart';
import 'package:guayan_trainer/domain/rules/templates/template_catalog.dart';
import 'package:guayan_trainer/domain/rules/templates/template_compiler_registry.dart';
import 'package:guayan_trainer/domain/rules/templates/template_definition.dart';
import 'package:guayan_trainer/domain/rules/templates/template_invocation.dart';

TemplateInvocation property(String property, String catalog, String value) =>
    TemplateInvocation(
      template: TemplateCatalog.propertyEquals,
      values: {
        'object': const ObjectSlotValue('A'),
        'property': PropertySlotValue(property),
        'value': ValueSlotValue(catalogId: catalog, value: value),
      },
    );

TemplateInvocation relation(TemplateDefinition template, String id) =>
    TemplateInvocation(
      template: template,
      values: {
        'objectA': const ObjectSlotValue('A'),
        'relation': RelationSlotValue(id),
        'objectB': const ObjectSlotValue('B'),
      },
    );

RuleDefinition saved(RuleExpr condition, [String id = 'e2_5_rule']) =>
    RuleDefinition(
      ruleId: RuleId(id),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'common',
      categoryId: 'common',
      stage: RuleStage.tag,
      title: 'E2.5',
      description: '',
      provenance: 'test',
      bindings: const [
        RuleBinding(name: 'A', selector: DirectSelector('line/3')),
        RuleBinding(name: 'B', selector: DirectSelector('line/5')),
      ],
      condition: condition,
      actions: const [],
    );

void main() {
  test('property templates compile, persist and round-trip', () {
    for (final item in [
      property('branch', 'branches', '卯'),
      property('element', 'elements', '木'),
      property('spirit', 'six_spirits', 'spirit.qing_long'),
    ]) {
      final expr = TemplateCompilerRegistry.compile(item) as PredicateExpr;
      final restored = PortableRuleCodec.decode(
        PortableRuleCodec.encode(saved(expr)),
      );
      expect((restored.condition as PredicateExpr).operatorId, expr.operatorId);
      expect((restored.condition as PredicateExpr).operands, hasLength(2));
    }
  });

  test('wuxing and branch relation templates compile through registry', () {
    final controls = relation(TemplateCatalog.wuxingRelation, 'controls');
    final combines = relation(TemplateCatalog.branchRelation, 'combines');
    expect(
      (TemplateCompilerRegistry.compile(controls) as PredicateExpr).operatorId,
      'wuxing_overcomes',
    );
    expect(
      (TemplateCompilerRegistry.compile(combines) as PredicateExpr).operatorId,
      'branch_combines',
    );
  });

  test('state template compiles to existing xun_kong operator', () {
    final invocation = TemplateInvocation(
      template: TemplateCatalog.stateHas,
      values: {
        'object': const ObjectSlotValue('A'),
        'state': const StateSlotValue('xun_kong'),
      },
    );
    expect(
      (TemplateCompilerRegistry.compile(invocation) as PredicateExpr)
          .operatorId,
      'xun_kong',
    );
  });

  test('compiled AST formats and parses without semantic drift', () {
    final expr = TemplateCompilerRegistry.compile(
      property('branch', 'branches', '卯'),
    );
    final source = GuayanDslFormatter.format(
      bindings: saved(expr).bindings,
      condition: expr,
      actions: const [],
    );
    final parsed = GuayanDslParser.parse(source).condition as PredicateExpr;
    expect(parsed.operatorId, 'branch_is');
    expect((parsed.operands[0] as BindingRefOperand).bindingName, 'A');
    expect((parsed.operands[1] as LiteralOperand).value.value, '卯');
  });

  test('compiled AST evaluates through existing runtime facts', () {
    final snapshot = FactSnapshot.build([
      FactRecord(
        factId: 'branch-3',
        subject: const SemanticRef('line', '3'),
        predicateId: 'branch',
        value: RuleValue.string('卯'),
        origin: FactOrigin.baseRelation,
      ),
      FactRecord(
        factId: 'element-3',
        subject: const SemanticRef('line', '3'),
        predicateId: 'element',
        value: RuleValue.string('木'),
        origin: FactOrigin.baseRelation,
      ),
      FactRecord(
        factId: 'element-5',
        subject: const SemanticRef('line', '5'),
        predicateId: 'element',
        value: RuleValue.string('土'),
        origin: FactOrigin.baseRelation,
      ),
    ]);
    final context = BindingContext({
      'A': const SemanticRef('line', '3'),
      'B': const SemanticRef('line', '5'),
    });
    final evaluator = PredicateEvaluator(OperatorRegistry());
    final branch = TemplateCompilerRegistry.compile(
      property('branch', 'branches', '卯'),
    );
    final controls = TemplateCompilerRegistry.compile(
      relation(TemplateCatalog.wuxingRelation, 'controls'),
    );
    expect(evaluator.evaluate(branch, context, snapshot).matched, isTrue);
    expect(evaluator.evaluate(controls, context, snapshot).matched, isTrue);
  });

  test('custom store saves and reloads property and relation AST', () async {
    SharedPreferences.setMockInitialValues({});
    final branch = TemplateCompilerRegistry.compile(
      property('branch', 'branches', '卯'),
    );
    final combines = TemplateCompilerRegistry.compile(
      relation(TemplateCatalog.branchRelation, 'combines'),
    );
    final store = CustomRuleStore();
    await store.load();
    await store.addOrUpdate(saved(branch, 'e2_5_branch'));
    await store.addOrUpdate(saved(combines, 'e2_5_combines'));

    final reloaded = CustomRuleStore();
    await reloaded.load();
    expect(reloaded.getAll(), hasLength(2));
    expect(
      reloaded.getAll().map(
        (rule) => (rule.condition as PredicateExpr).operatorId,
      ),
      containsAll(<String>['branch_is', 'branch_combines']),
    );
  });
}
