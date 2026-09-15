library;

import '../rules/ast/binding_selector.dart';
import '../rules/ast/rule_action.dart';
import '../rules/ast/rule_binding.dart';
import '../rules/ast/rule_expr.dart';
import '../rules/ast/rule_operand.dart';
import '../rules/core/rule_definition.dart';
import '../rules/core/rule_id.dart';
import '../rules/core/rule_origin.dart';
import '../rules/core/rule_stage.dart';
import '../rules/core/rule_version.dart';
import '../rules/facts/rule_value.dart';
import 'dsl_diagnostics.dart';

class ParsedGuayan {
  const ParsedGuayan(this.bindings, this.condition, this.actions);
  final List<RuleBinding> bindings;
  final RuleExpr? condition;
  final List<RuleAction> actions;
}

class _Line {
  _Line(this.lineNumber, this.indent, this.text);
  final int lineNumber;
  final int indent;
  final String text;
}

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
      final condBlock = <_Line>[];
      condBlock.add(lines[i]);
      i++;
      while (i < lines.length && !lines[i].text.startsWith('则')) {
        condBlock.add(lines[i]);
        i++;
      }
      condition = _parseConditionBlock(condBlock);
    }

    if (i < lines.length && lines[i].text.startsWith('则')) {
      i++; // Skip '则' line itself if it's alone, or parse after if inline
      while (i < lines.length) {
        actions.add(_parseAction(lines[i]));
        i++;
      }
    }

    return ParsedGuayan(bindings, condition, actions);
  }

  static List<_Line> _splitLines(String source) {
    final rawLines = source.split('\n');
    final result = <_Line>[];
    for (int i = 0; i < rawLines.length; i++) {
      final text = rawLines[i];
      if (text.trim().isEmpty) continue;
      
      int indent = 0;
      while (indent < text.length && text[indent] == ' ') {
        indent++;
      }
      result.add(_Line(i + 1, indent, text.trim()));
    }
    return result;
  }

  static RuleBinding _parseBinding(_Line line) {
    // e.g. 取 A = @line/2
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
      selector = DirectSelector(selectorStr); // Simplified
    }
    return RuleBinding(name: name, selector: selector);
  }

  static RuleAction _parseAction(_Line line) {
    // 得 A state.parent_supported
    // 取象 A exam:document
    final text = line.text;
    if (text.startsWith('得 ')) {
      final parts = text.substring(2).trim().split(' ');
      if (parts.length != 2) throw _err(line, '无法识别得动作');
      return DeriveAction(targetBinding: parts[0], factKey: parts[1]);
    } else if (text.startsWith('取象 ')) {
      final parts = text.substring(3).trim().split(' ');
      if (parts.length != 2) throw _err(line, '无法识别取象动作');
      final tagParts = parts[1].split(':');
      if (tagParts.length != 2) throw _err(line, '取象目标格式应为 category:tag');
      return TagAction(
          categoryId: tagParts[0], tagId: tagParts[1], subjectBinding: parts[0]);
    } else if (text.startsWith('记 ')) {
      // Stub
      return const RecordAction(recordType: 'stub', content: {});
    } else if (text.startsWith('成局 ')) {
      // Stub
      return const StructureAction(structureId: 'stub', memberBindings: []);
    } else {
      throw _err(line, '无法识别动作: $text');
    }
  }

  static RuleExpr _parseConditionBlock(List<_Line> block) {
    // First line starts with 若
    final firstLine = block[0];
    final exprText = firstLine.text.substring(2).trim(); // Skip "若 "
    final firstExpr = _parseExprLine(exprText, firstLine);

    if (block.length == 1) return firstExpr;

    final children = <RuleExpr>[firstExpr];
    int i = 1;
    while (i < block.length) {
      final line = block[i];
      if (line.text.startsWith('且 ') || line.text == '且') {
        final subText = line.text.length > 1 ? line.text.substring(1).trim() : '';
        if (subText.isEmpty) {
          // It's a block modifier (且 followed by indented lines)
          i++;
          final subBlock = <_Line>[];
          if (i < block.length) {
            final baseIndent = block[i].indent;
            while (i < block.length && block[i].indent >= baseIndent) {
              subBlock.add(block[i]);
              i++;
            }
          }
          children.add(_parseSubGroup(subBlock, true)); // AND group
          i--;
        } else {
          children.add(_parseExprLine(subText, line));
        }
      } else if (line.text.startsWith('或 ') || line.text == '或') {
          final subText = line.text.length > 1 ? line.text.substring(1).trim() : '';
          children.add(_parseExprLine(subText, line));
      } else {
          throw _err(line, '无法识别条件块结构: ${line.text}');
      }
      i++;
    }

    if (children.length > 1) {
      return AllExpr(children); // Root is usually ALL
    }
    return children.first;
  }

  static RuleExpr _parseSubGroup(List<_Line> lines, bool isAll) {
    final children = <RuleExpr>[];
    for (var line in lines) {
      var text = line.text;
      if (text.startsWith('且 ') || text == '且') text = text.length > 1 ? text.substring(1).trim() : '';
      else if (text.startsWith('或 ') || text == '或') {
        text = text.length > 1 ? text.substring(1).trim() : '';
        isAll = false; // Implicitly switch to AnyExpr if we see "或"
      }
      children.add(_parseExprLine(text, line));
    }
    return isAll ? AllExpr(children) : AnyExpr(children);
  }

  static RuleExpr _parseExprLine(String text, _Line line) {
    bool isNot = false;
    if (text.startsWith('非 ')) {
      isNot = true;
      text = text.substring(2).trim();
    }

    RuleExpr? baseExpr;
    
    // Pattern matchers
    if (text.contains('六亲为')) {
      final parts = text.split('六亲为');
      if (parts.length == 2) {
        baseExpr = PredicateExpr(
          operatorId: 'relative',
          operands: [
            BindingRefOperand(parts[0].trim()),
            LiteralOperand(RuleValue.string(parts[1].trim())),
          ],
        );
      }
    } else if (text.contains(' 生 ')) {
      final parts = text.split(' 生 ');
      if (parts.length == 2) {
        baseExpr = PredicateExpr(
          operatorId: 'generate',
          operands: [
            BindingRefOperand(parts[0].trim()),
            BindingRefOperand(parts[1].trim()),
          ],
        );
      }
    } else if (text.endsWith('月破')) {
      final binding = text.replaceAll('月破', '').trim();
      baseExpr = PredicateExpr(
        operatorId: 'yue_po',
        operands: [BindingRefOperand(binding)],
      );
    } else if (text.endsWith('日破')) {
      final binding = text.replaceAll('日破', '').trim();
      baseExpr = PredicateExpr(
        operatorId: 'ri_po',
        operands: [BindingRefOperand(binding)],
      );
    } else if (text.endsWith('旬空')) {
      final binding = text.replaceAll('旬空', '').trim();
      baseExpr = PredicateExpr(
        operatorId: 'xun_kong',
        operands: [BindingRefOperand(binding)],
      );
    }
    
    if (baseExpr == null) {
      throw _err(line, '无法识别条件: $text');
    }

    return isNot ? NotExpr(baseExpr) : baseExpr;
  }

  static DslException _err(_Line line, String msg) {
    return DslException(DslDiagnostic(line: line.lineNumber, column: 1, message: msg));
  }
}
