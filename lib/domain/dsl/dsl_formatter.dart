import '../rules/ast/binding_selector.dart';
import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';
import 'formatter/dsl_expr_formatter.dart';

class GuayanDslFormatter {
  static String format({
    required List<RuleBinding> bindings,
    RuleExpr? condition,
    required List<RuleAction> actions,
  }) {
    final buffer = StringBuffer();

    for (var b in bindings) {
      if (b.selector is DirectSelector) {
        buffer.writeln('取 ${b.name} = @${(b.selector as DirectSelector).target}');
      } else if (b.selector is RelativeSelector) {
        final rel = b.selector as RelativeSelector;
        buffer.writeln('取 ${b.name} = ${rel.baseBinding}.${rel.path}');
      }
    }

    if (bindings.isNotEmpty) buffer.writeln();

    if (condition != null) {
      if (condition is AllExpr && condition.nodes.isNotEmpty) {
        buffer.writeln('若 ${DslExprFormatter.formatExpr(condition.nodes.first)}');
        for (int i = 1; i < condition.nodes.length; i++) {
          final child = condition.nodes[i];
          if (child is AnyExpr) {
            buffer.writeln('    且');
            for (int j = 0; j < child.nodes.length; j++) {
              final prefix = j == 0 ? '        ' : '        或 ';
              buffer.writeln('$prefix${DslExprFormatter.formatExpr(child.nodes[j])}');
            }
          } else {
            buffer.writeln('    且 ${DslExprFormatter.formatExpr(child)}');
          }
        }
      } else if (condition is AnyExpr && condition.nodes.isNotEmpty) {
        _formatAnyExpr(buffer, condition);
      } else {
        buffer.writeln('若 ${DslExprFormatter.formatExpr(condition)}');
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

  static void _formatAnyExpr(StringBuffer buffer, AnyExpr condition) {
    bool isFirst = true;
    for (int i = 0; i < condition.nodes.length; i++) {
      final child = condition.nodes[i];
      if (child is AllExpr) {
        for (int j = 0; j < child.nodes.length; j++) {
          if (isFirst) {
            buffer.writeln('若 ${DslExprFormatter.formatExpr(child.nodes[j])}');
            isFirst = false;
          } else if (j == 0) {
            buffer.writeln('    或 ${DslExprFormatter.formatExpr(child.nodes[j])}');
          } else {
            buffer.writeln('    且 ${DslExprFormatter.formatExpr(child.nodes[j])}');
          }
        }
      } else {
        if (isFirst) {
          buffer.writeln('若 ${DslExprFormatter.formatExpr(child)}');
          isFirst = false;
        } else {
          buffer.writeln('    或 ${DslExprFormatter.formatExpr(child)}');
        }
      }
    }
  }
}
