library;

import '../rules/ast/binding_selector.dart';
import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';
import 'dsl_diagnostics.dart';
import 'dsl_models.dart';
import 'parser/dsl_action_parser.dart';
import 'parser/dsl_expr_parser.dart';

class GuayanDslParser {
  static ParsedGuayan parse(String source) {
    final lines = _splitLines(source);
    final bindings = <RuleBinding>[];
    final actions = <RuleAction>[];
    
    int i = 0;
    while (i < lines.length && lines[i].text.startsWith('取 ')) {
      bindings.add(_parseBinding(lines[i]));
      i++;
    }

    RuleExpr? condition;
    if (i < lines.length && lines[i].text.startsWith('若 ')) {
      final condBlock = <DslLine>[];
      condBlock.add(lines[i]);
      i++;
      while (i < lines.length && !lines[i].text.startsWith('则')) {
        condBlock.add(lines[i]);
        i++;
      }
      condition = DslExprParser.parseConditionBlock(condBlock);
    }

    if (i < lines.length && lines[i].text.startsWith('则')) {
      i++;
      while (i < lines.length) {
        actions.add(DslActionParser.parseAction(lines[i]));
        i++;
      }
    }

    return ParsedGuayan(bindings, condition, actions);
  }

  static List<DslLine> _splitLines(String source) {
    final rawLines = source.split('\n');
    final result = <DslLine>[];
    for (int i = 0; i < rawLines.length; i++) {
      final text = rawLines[i];
      if (text.trim().isEmpty) continue;
      int indent = 0;
      while (indent < text.length && text[indent] == ' ') {
        indent++;
      }
      result.add(DslLine(i + 1, indent, text.trim()));
    }
    return result;
  }

  static RuleBinding _parseBinding(DslLine line) {
    final regex = RegExp(r'^取\s+(\w+)\s*=\s*(.+)$');
    final match = regex.firstMatch(line.text);
    if (match == null) {
      throw DslException(DslDiagnostic(line: line.lineNumber, column: 1, message: '无法识别绑定: ${line.text}'));
    }
    final name = match.group(1)!;
    final selectorStr = match.group(2)!;
    
    BindingSelector selector;
    if (selectorStr.startsWith('@')) {
      selector = DirectSelector(selectorStr.substring(1));
    } else {
      selector = DirectSelector(selectorStr);
    }
    return RuleBinding(name: name, selector: selector);
  }
}
