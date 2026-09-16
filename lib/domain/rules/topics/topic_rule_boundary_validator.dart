library;

import '../core/rule_definition.dart';
import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';

class TopicRuleBoundaryValidator {
  static void validate(RuleDefinition rule) {
    if (rule.categoryId == 'common') return;
    _checkExpr(rule.condition, rule.categoryId);
  }

  static void _checkExpr(RuleExpr expr, String allowedCategory) {
    if (expr is AllExpr) {
      for (var e in expr.nodes) _checkExpr(e, allowedCategory);
    } else if (expr is AnyExpr) {
      for (var e in expr.nodes) _checkExpr(e, allowedCategory);
    } else if (expr is NotExpr) {
      _checkExpr(expr.node, allowedCategory);
    } else if (expr is PredicateExpr) {
      if (expr.operatorId == 'has_tag') {
        final categoryOp = expr.operands[1];
        if (categoryOp is LiteralOperand) {
          final cat = categoryOp.value.value as String;
          if (cat != 'common' && cat != allowedCategory) {
            throw StateError('Boundary violation: Topic "$allowedCategory" cannot depend on tag from "$cat"');
          }
        }
      }
    }
  }
}
