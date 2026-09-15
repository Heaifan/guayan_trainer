library;

import '../../rules/ast/rule_expr.dart';
import '../dsl_diagnostics.dart';
import '../dsl_models.dart';
import 'dsl_pattern_matcher.dart';

class DslExprParser {
  static RuleExpr parseConditionBlock(List<DslLine> block) {
    final firstLine = block[0];
    final exprText = firstLine.text.substring(2).trim();
    final firstExpr = parseExprLine(exprText, firstLine);
    if (block.length == 1) return firstExpr;

    final children = <RuleExpr>[firstExpr];
    bool isAll = true;
    int i = 1;
    while (i < block.length) {
      final line = block[i];
      if (line.text.startsWith('且 ') || line.text == '且') {
        final subText = line.text.length > 1
            ? line.text.substring(1).trim()
            : '';
        if (subText.isEmpty) {
          i++;
          final subBlock = <DslLine>[];
          if (i < block.length) {
            final baseIndent = block[i].indent;
            while (i < block.length && block[i].indent >= baseIndent) {
              subBlock.add(block[i]);
              i++;
            }
          }
          children.add(parseSubGroup(subBlock, true));
          i--;
        } else {
          children.add(parseExprLine(subText, line));
        }
      } else if (line.text.startsWith('或 ') || line.text == '或') {
        isAll = false;
        final subText = line.text.length > 1
            ? line.text.substring(1).trim()
            : '';
        if (subText.isEmpty) {
          i++;
          final subBlock = <DslLine>[];
          if (i < block.length) {
            final baseIndent = block[i].indent;
            while (i < block.length && block[i].indent >= baseIndent) {
              subBlock.add(block[i]);
              i++;
            }
          }
          children.add(parseSubGroup(subBlock, true));
          i--;
        } else {
          children.add(parseExprLine(subText, line));
        }
      } else {
        throw DslException(
          DslDiagnostic(
            line: line.lineNumber,
            column: 1,
            message: '无法识别条件块结构: ${line.text}',
          ),
        );
      }
      i++;
    }
    return children.length > 1
        ? (isAll ? AllExpr(children) : AnyExpr(children))
        : children.first;
  }

  static RuleExpr parseSubGroup(List<DslLine> lines, bool isAll) {
    final children = <RuleExpr>[];
    for (var line in lines) {
      var text = line.text;
      if (text.startsWith('且 ') || text == '且') {
        text = text.length > 1 ? text.substring(1).trim() : '';
      } else if (text.startsWith('或 ') || text == '或') {
        text = text.length > 1 ? text.substring(1).trim() : '';
        isAll = false;
      }
      children.add(parseExprLine(text, line));
    }
    return isAll ? AllExpr(children) : AnyExpr(children);
  }

  static RuleExpr parseExprLine(String text, DslLine line) {
    bool isNot = false;
    if (text.startsWith('非 ')) {
      isNot = true;
      text = text.substring(2).trim();
    }
    final baseExpr = DslPatternMatcher.matchPattern(text, line);
    if (baseExpr == null) {
      throw DslException(
        DslDiagnostic(
          line: line.lineNumber,
          column: 1,
          message: '无法识别条件: $text',
        ),
      );
    }
    return isNot ? NotExpr(baseExpr) : baseExpr;
  }
}
