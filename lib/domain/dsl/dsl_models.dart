library;

import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';

class ParsedGuayan {
  const ParsedGuayan(this.bindings, this.condition, this.actions);
  final List<RuleBinding> bindings;
  final RuleExpr? condition;
  final List<RuleAction> actions;
}

class DslLine {
  DslLine(this.lineNumber, this.indent, this.text);
  final int lineNumber;
  final int indent;
  final String text;
}
