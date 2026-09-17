import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/templates/rule_slot_definition.dart';
import 'package:guayan_trainer/domain/rules/templates/template_catalog.dart';
import 'package:guayan_trainer/domain/rules/templates/template_compiler_registry.dart';
import 'package:guayan_trainer/domain/rules/templates/template_invocation.dart';
import 'package:guayan_trainer/domain/rules/templates/template_validation.dart';

void main() {
  test('four templates expose typed slots and projections', () {
    expect(TemplateCatalog.propertyEquals.slots.map((s) => s.type), [
      RuleSlotType.object,
      RuleSlotType.property,
      RuleSlotType.value,
    ]);
    expect(TemplateCatalog.wuxingRelation.slots[1].projection, 'element');
    expect(TemplateCatalog.branchRelation.slots[1].projection, 'branch');
  });

  test('property template rejects mismatched value catalog', () {
    final invocation = TemplateInvocation(
      template: TemplateCatalog.propertyEquals,
      values: {
        'object': const ObjectSlotValue('A'),
        'property': const PropertySlotValue('branch'),
        'value': const ValueSlotValue(catalogId: 'six_spirits', value: '玄武'),
      },
    );
    expect(TemplateValidation.validate(invocation), isNotEmpty);
  });

  test('property template compiles to existing branch predicate', () {
    final invocation = TemplateInvocation(
      template: TemplateCatalog.propertyEquals,
      values: {
        'object': const ObjectSlotValue('A'),
        'property': const PropertySlotValue('branch'),
        'value': const ValueSlotValue(catalogId: 'branches', value: '卯'),
      },
    );
    final expr = TemplateCompilerRegistry.compile(invocation) as PredicateExpr;
    expect(expr.operatorId, 'branch_is');
    expect(expr.operands.length, 2);
  });

  test('relation templates compile with fixed projections', () {
    final wuxing = TemplateInvocation(
      template: TemplateCatalog.wuxingRelation,
      values: {
        'objectA': const ObjectSlotValue('A'),
        'relation': const RelationSlotValue('controls'),
        'objectB': const ObjectSlotValue('B'),
      },
    );
    final branch = TemplateInvocation(
      template: TemplateCatalog.branchRelation,
      values: {
        'objectA': const ObjectSlotValue('A'),
        'relation': const RelationSlotValue('combines'),
        'objectB': const ObjectSlotValue('B'),
      },
    );
    expect(
      (TemplateCompilerRegistry.compile(wuxing) as PredicateExpr).operatorId,
      'wuxing_overcomes',
    );
    expect(
      (TemplateCompilerRegistry.compile(branch) as PredicateExpr).operatorId,
      'branch_combines',
    );
  });
}
