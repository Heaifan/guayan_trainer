library;

import '../ast/rule_binding.dart';
import '../ast/rule_expr.dart';
import '../ast/rule_action.dart';

class GuayanRuleBody {
  const GuayanRuleBody({
    required this.bindings,
    required this.condition,
    required this.actions,
  });

  final List<RuleBinding> bindings;
  final RuleExpr condition;
  final List<RuleAction> actions;
}
