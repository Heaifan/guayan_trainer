library;

import '../rules/ast/binding_selector.dart';
import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';
import '../rules/ast/rule_operand.dart';

class GuayanDslFormatter {
  static String format({
    required List<RuleBinding> bindings,
    RuleExpr? condition,
    required List<RuleAction> actions,
  }) {
    final buffer = StringBuffer();

    for (var b in bindings) {
      if (b.selector is DirectSelector) {
        final selector = (b.selector as DirectSelector).target;
        buffer.writeln('取 ${b.name} = @$selector');
      }
    }
    
    if (bindings.isNotEmpty) buffer.writeln();

    if (condition != null) {
      if (condition is AllExpr && condition.nodes.isNotEmpty) {
        buffer.writeln('若 ${_formatExpr(condition.nodes.first)}');
        for (int i = 1; i < condition.nodes.length; i++) {
          final child = condition.nodes[i];
          if (child is AnyExpr) {
            buffer.writeln('    且');
            for (int j = 0; j < child.nodes.length; j++) {
               final prefix = j == 0 ? '        ' : '        或 ';
               buffer.writeln('$prefix${_formatExpr(child.nodes[j])}');
            }
          } else {
             buffer.writeln('    且 ${_formatExpr(child)}');
          }
        }
      } else {
        buffer.writeln('若 ${_formatExpr(condition)}');
      }
    }

    if (actions.isNotEmpty) {
      buffer.writeln('则');
      for (var a in actions) {
        if (a is DeriveAction) {
          buffer.writeln('    得 ${a.targetBinding} ${a.factKey}');
        } else if (a is TagAction) {
          buffer.writeln('    取象 ${a.subjectBinding} ${a.categoryId}:${a.tagId}');
        }
      }
    }

    return buffer.toString().trimRight();
  }

  static String _formatExpr(RuleExpr expr) {
    if (expr is NotExpr) {
      return '非 ${_formatExpr(expr.node)}';
    } else if (expr is PredicateExpr) {
      if (expr.operatorId == 'relative') {
        final b = (expr.operands[0] as BindingRefOperand).bindingName;
        final val = (expr.operands[1] as LiteralOperand).value.value;
        return '$b 六亲为$val';
      } else if (expr.operatorId == 'generate') {
        final a = (expr.operands[0] as BindingRefOperand).bindingName;
        final b = (expr.operands[1] as BindingRefOperand).bindingName;
        return '$a 生 $b';
      } else if (expr.operatorId == 'yue_po') {
        final a = (expr.operands[0] as BindingRefOperand).bindingName;
        return '$a 月破';
      } else if (expr.operatorId == 'ri_po') {
        final a = (expr.operands[0] as BindingRefOperand).bindingName;
        return '$a 日破';
      } else if (expr.operatorId == 'xun_kong') {
        final a = (expr.operands[0] as BindingRefOperand).bindingName;
        return '$a 旬空';
      }
    }
    return '';
  }
}
