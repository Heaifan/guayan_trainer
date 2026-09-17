library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import 'dsl_vocabulary.dart';

class ConditionFormatter {
  const ConditionFormatter();

  void format(RuleExpr expr, int indentLevel, StringBuffer buffer) {
    if (expr is AllExpr) {
      for (int i = 0; i < expr.nodes.length; i++) {
        final prefix = i == 0 ? '' : '且 ';
        _formatExprLogic(expr.nodes[i], indentLevel, buffer, prefix);
      }
    } else if (expr is AnyExpr) {
      for (int i = 0; i < expr.nodes.length; i++) {
        final prefix = i == 0 ? '' : '或 ';
        _formatExprLogic(expr.nodes[i], indentLevel, buffer, prefix);
      }
    } else {
      _formatExprLogic(expr, indentLevel, buffer, '');
    }
  }

  void _formatExprLogic(
    RuleExpr expr,
    int indentLevel,
    StringBuffer buffer,
    String prefix,
  ) {
    final indent = '    ' * indentLevel;

    if (expr is NotExpr) {
      buffer.write('$indent$prefix非 ');
      if (expr.node is PredicateExpr) {
        buffer.writeln(_formatPredicate(expr.node as PredicateExpr));
      } else {
        buffer.writeln('');
        format(expr.node, indentLevel + 1, buffer);
      }
    } else if (expr is PredicateExpr) {
      buffer.writeln('$indent$prefix${_formatPredicate(expr)}');
    } else {
      buffer.writeln('$indent$prefix');
      format(expr, indentLevel + 1, buffer);
    }
  }

  String _formatPredicate(PredicateExpr p) {
    final op = DslVocabulary.mapToChinese(p.operatorId);
    if (p.operands.length == 1) {
      final sub = (p.operands[0] as BindingRefOperand).bindingName;
      return '$sub $op';
    } else if (p.operands.length == 2) {
      final sub = (p.operands[0] as BindingRefOperand).bindingName;
      final right = p.operands[1];
      String rval;
      if (right is LiteralOperand) {
        rval = DslVocabulary.mapToChinese(
          right.value.value?.toString() ?? 'null',
        );
      } else if (right is BindingRefOperand) {
        rval = right.bindingName;
      } else {
        rval = '';
      }
      return '$sub $op $rval';
    }
    return '';
  }
}
