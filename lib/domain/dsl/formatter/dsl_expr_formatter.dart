import '../../rules/ast/rule_expr.dart';
import '../../rules/ast/rule_operand.dart';
import '../dsl_nayin_map.dart';
import '../../casting/six_relative.dart';
import '../../casting/six_spirit.dart';

class DslExprFormatter {
  static String formatExpr(RuleExpr expr) {
    if (expr is NotExpr) return '非 ${formatExpr(expr.node)}';
    if (expr is PredicateExpr) {
      final opId = expr.operatorId;
      final ops = expr.operands;
      if (opId == 'relative') {
        final val = _l(ops[1]);
        final label = SixRelative.values.where((e) => e.name == val).firstOrNull?.label ?? val;
        return '${_b(ops[0])} 六亲为$label';
      }
      if (opId == 'spirit') {
        final val = _l(ops[1]);
        final label = SixSpirit.values.where((e) => e.name == val).firstOrNull?.label ?? val;
        return '${_b(ops[0])} 六神为$label';
      }
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
