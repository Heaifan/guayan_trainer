library;

import '../core/rule_definition.dart';
import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';

class TopicRuleBoundaryValidator {
  static void validate(RuleDefinition rule, String expectedTopicId) {
    if (rule.namespace != 'topic.$expectedTopicId') {
      throw StateError(
        'Boundary violation: Rule namespace must be "topic.$expectedTopicId"',
      );
    }
    if (rule.categoryId != expectedTopicId) {
      throw StateError(
        'Boundary violation: Rule categoryId must be "$expectedTopicId"',
      );
    }
    _checkExpr(rule.condition, expectedTopicId);
  }

  static void _checkExpr(RuleExpr expr, String allowedCategory) {
    if (expr is AllExpr) {
      for (var e in expr.nodes) {
        _checkExpr(e, allowedCategory);
      }
    } else if (expr is AnyExpr) {
      for (var e in expr.nodes) {
        _checkExpr(e, allowedCategory);
      }
    } else if (expr is NotExpr) {
      _checkExpr(expr.node, allowedCategory);
    } else if (expr is PredicateExpr) {
      if (expr.operatorId == 'has_tag') {
        final categoryOp = expr.operands[1];
        if (categoryOp is LiteralOperand) {
          final cat = categoryOp.value.value as String;
          if (cat != 'common' && cat != allowedCategory) {
            throw StateError(
              'Boundary violation: Topic "$allowedCategory" cannot depend on tag from "$cat"',
            );
          }
        }
      }
    }
  }
}
