library;

import '../../rules/ast/rule_expr.dart';
import '../dsl_diagnostics.dart';
import '../dsl_models.dart';
import 'dsl_pattern_matcher.dart';

class _BlockItem {
  final bool isOr;
  final RuleExpr expr;
  _BlockItem(this.isOr, this.expr);
}

class DslExprParser {
  static DslException _err(DslLine l, String msg) =>
      DslException(DslDiagnostic(line: l.lineNumber, column: 1, message: msg));

  static RuleExpr parseConditionBlock(List<DslLine> block) {
    final firstLine = block[0];
    final items = <_BlockItem>[
      _BlockItem(
        false,
        parseExprLine(firstLine.text.substring(2).trim(), firstLine),
      ),
    ];
    int i = 1;
    while (i < block.length) {
      final line = block[i];
      final isOr = line.text.startsWith('或 ') || line.text == '或';
      final isAnd = line.text.startsWith('且 ') || line.text == '且';
      if (!isOr && !isAnd) throw _err(line, '无法识别条件块结构: ${line.text}');
      final subText = line.text.length > 1 ? line.text.substring(1).trim() : '';
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
        items.add(_BlockItem(isOr, parseSubGroup(subBlock)));
        i--;
      } else {
        items.add(_BlockItem(isOr, parseExprLine(subText, line)));
      }
      i++;
    }
    return _resolvePrecedence(items);
  }

  static RuleExpr parseSubGroup(List<DslLine> lines) {
    final items = <_BlockItem>[];
    for (int i = 0; i < lines.length; i++) {
      var text = lines[i].text;
      bool isOr = false;
      if (text.startsWith('或 ') || text == '或') {
        text = text.length > 1 ? text.substring(1).trim() : '';
        isOr = true;
      } else if (text.startsWith('且 ') || text == '且') {
        text = text.length > 1 ? text.substring(1).trim() : '';
      } else {
        isOr = i > 0 && items.last.isOr;
      }
      items.add(_BlockItem(isOr, parseExprLine(text, lines[i])));
    }
    return _resolvePrecedence(items);
  }

  static RuleExpr _resolvePrecedence(List<_BlockItem> items) {
    final orGroups = <List<RuleExpr>>[];
    var currentAnd = <RuleExpr>[];
    for (var item in items) {
      if (item.isOr && currentAnd.isNotEmpty) {
        orGroups.add(currentAnd);
        currentAnd = [];
      }
      currentAnd.add(item.expr);
    }
    if (currentAnd.isNotEmpty) orGroups.add(currentAnd);
    final resolved = orGroups
        .map((g) => g.length > 1 ? AllExpr(g) : g.first)
        .toList();
    return resolved.length > 1 ? AnyExpr(resolved) : resolved.first;
  }

  static RuleExpr parseExprLine(String text, DslLine line) {
    bool isNot = false;
    if (text.startsWith('非 ')) {
      isNot = true;
      text = text.substring(2).trim();
    }
    final baseExpr = DslPatternMatcher.matchPattern(text, line);
    if (baseExpr == null) throw _err(line, '无法识别条件: $text');
    return isNot ? NotExpr(baseExpr) : baseExpr;
  }
}
