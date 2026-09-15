library;

import '../ast/binding_selector.dart';
import '../ast/rule_action.dart';
import '../ast/rule_binding.dart';
import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import '../core/rule_stage.dart';
import '../core/rule_version.dart';

class CommonRuleFactory {
  static List<RuleDefinition> buildLineRules(int lineIndex) {
    return [
      _unary(lineIndex, 'xun_kong', 'state.xun_kong'),
      _unary(lineIndex, 'yue_po', 'state.yue_po'),
      _unary(lineIndex, 'ri_po', 'state.ri_po'),
      _unary(lineIndex, 'in_tomb', 'state.in_tomb'),
      _binary(lineIndex, 'calendar/month', 'M', 'month_generate'),
      _binary(lineIndex, 'calendar/day', 'D', 'day_generate'),
    ];
  }

  static RuleDefinition _unary(int i, String op, String tag) {
    return _def(
      id: 'common.line.$i.$op',
      cat: 'state',
      bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/$i'))],
      cond: PredicateExpr(operatorId: op, operands: [BindingRefOperand('A')]),
      action: TagAction(categoryId: 'common', tagId: tag, subjectBinding: 'A'),
    );
  }

  static RuleDefinition _binary(int i, String ext, String extName, String idSuffix) {
    return _def(
      id: 'common.line.$i.$idSuffix',
      cat: 'relation',
      bindings: [
        RuleBinding(name: 'A', selector: DirectSelector('line/$i')),
        RuleBinding(name: extName, selector: DirectSelector(ext)),
      ],
      cond: PredicateExpr(
        operatorId: 'generate',
        operands: [BindingRefOperand(extName), BindingRefOperand('A')],
      ),
      action: TagAction(categoryId: 'common', tagId: 'relation.$idSuffix', subjectBinding: 'A'),
    );
  }

  static RuleDefinition _def({
    required String id,
    required String cat,
    required List<RuleBinding> bindings,
    required RuleExpr cond,
    required RuleAction action,
  }) {
    return RuleDefinition(
      ruleId: RuleId(id),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.SYSTEM,
      namespace: 'common',
      categoryId: cat,
      stage: RuleStage.tag,
      title: 'Common $id',
      description: 'Built-in common rule for $id',
      provenance: 'builtin.common.v1',
      bindings: bindings,
      condition: cond,
      actions: [action],
      enabled: true,
    );
  }
}
