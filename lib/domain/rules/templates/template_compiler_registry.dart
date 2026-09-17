library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/rule_value.dart';
import 'rule_slot_definition.dart';
import 'template_compiler.dart';
import 'template_invocation.dart';
import 'template_validation.dart';

class TemplateCompilerRegistry {
  TemplateCompilerRegistry._();

  static final Map<String, TemplateCompiler> _items = {
    'template.property.equals': const _PropertyCompiler(),
    'template.state.has': const _StateCompiler(),
    'template.relation.wuxing': const _RelationCompiler('element'),
    'template.relation.branch': const _RelationCompiler('branch'),
  };

  static RuleExpr compile(TemplateInvocation invocation) {
    final errors = TemplateValidation.validate(invocation);
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('；'));
    }
    final compiler = _items[invocation.template.id];
    if (compiler == null) {
      throw ArgumentError('未知模板: ${invocation.template.id}');
    }
    return compiler.compile(invocation);
  }
}

class _PropertyCompiler extends TemplateCompiler {
  const _PropertyCompiler();
  @override
  RuleExpr compile(TemplateInvocation i) {
    final property = (i['property'] as PropertySlotValue).propertyId;
    final operators = {
      'stem': 'stem_is',
      'branch': 'branch_is',
      'element': 'element_is',
      'spirit': 'spirit',
      'relative': 'relative',
      'nayin': 'nayin_is',
    };
    return PredicateExpr(
      operatorId: operators[property]!,
      operands: [_object(i, 'object'), _value(i, 'value')],
    );
  }
}

class _StateCompiler extends TemplateCompiler {
  const _StateCompiler();
  @override
  RuleExpr compile(TemplateInvocation i) {
    final state = (i['state'] as StateSlotValue).stateId;
    return PredicateExpr(operatorId: state, operands: [_object(i, 'object')]);
  }
}

class _RelationCompiler extends TemplateCompiler {
  const _RelationCompiler(this.projection);
  final String projection;
  @override
  RuleExpr compile(TemplateInvocation i) {
    final relation = (i['relation'] as RelationSlotValue).relationId;
    final operators = projection == 'element'
        ? {'generate': 'generate', 'controls': 'wuxing_overcomes'}
        : {
            'clashes': 'branch_clashes',
            'combines': 'branch_combines',
            'punishes': 'branch_punishes',
            'harms': 'branch_harms',
            'breaks': 'branch_breaks',
          };
    return PredicateExpr(
      operatorId: operators[relation]!,
      operands: [_object(i, 'objectA'), _object(i, 'objectB')],
    );
  }
}

BindingRefOperand _object(TemplateInvocation i, String id) =>
    BindingRefOperand((i[id] as ObjectSlotValue).bindingName);

LiteralOperand _value(TemplateInvocation i, String id) => LiteralOperand(
  RuleValue.string((i[id] as ValueSlotValue).value.toString()),
);
