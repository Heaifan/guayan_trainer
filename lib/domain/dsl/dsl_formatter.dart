import '../rules/ast/binding_selector.dart';
import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';
import '../rules/ast/rule_operand.dart';
import 'dsl_nayin_map.dart';

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
        } else if (a is StructureAction) {
          buffer.writeln('    成局 ${a.structureId} ${a.memberBindings.join(",")}');
        } else if (a is RecordAction) {
          final kvs = a.content.entries.map((e) => '${e.key}=${e.value.value}').join(' ');
          buffer.writeln('    记 ${a.recordType}${kvs.isNotEmpty ? " $kvs" : ""}');
        }
      }
    }

    return buffer.toString().trimRight();
  }

  static String _formatExpr(RuleExpr expr) {
    if (expr is NotExpr) return '非 ${_formatExpr(expr.node)}';
    if (expr is PredicateExpr) {
      final opId = expr.operatorId;
      final ops = expr.operands;
      if (opId == 'relative') return '${_b(ops[0])} 六亲为${_l(ops[1])}';
      if (opId == 'spirit') return '${_b(ops[0])} 六神为${_l(ops[1])}';
      if (opId == 'generate') return '${_b(ops[0])} 生 ${_b(ops[1])}';
      if (opId == 'nayin_is') return '${_b(ops[0])} 纳音为${dslIdToNaYin[_l(ops[1])] ?? _l(ops[1])}';
      if (opId == 'has_tag') return '${_b(ops[0])} 有标签 ${_l(ops[1])}:${_l(ops[2])}';
      if (opId == 'chu_mu') return '${_b(ops[0])} 出墓于 ${_b(ops[1])} 冲 ${_b(ops[2])}';
      if (opId == 'ru_mu') return '${_b(ops[0])} 入墓于 ${_b(ops[1])}';
      if (opId == 'chong_mu') return '${_b(ops[0])} 冲墓于 ${_b(ops[1])}';
      if (opId == 'yue_po') return '${_b(ops[0])} 月破';
      if (opId == 'ri_po') return '${_b(ops[0])} 日破';
      if (opId == 'xun_kong') return '${_b(ops[0])} 旬空';
      if (opId == 'empty') return '${_b(ops[0])} 为空';
      if (opId == 'in_tomb') return '${_b(ops[0])} 在墓中';
    }
    return '';
  }

  static String _b(RuleOperand op) => (op as BindingRefOperand).bindingName;
  static String _l(RuleOperand op) => (op as LiteralOperand).value.value.toString();
}
