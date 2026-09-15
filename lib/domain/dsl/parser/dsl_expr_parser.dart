library;

import '../../rules/ast/rule_expr.dart';
import '../../rules/ast/rule_operand.dart';
import '../../rules/facts/rule_value.dart';
import '../dsl_diagnostics.dart';
import '../dsl_models.dart';
import '../dsl_nayin_map.dart';

class DslExprParser {
  static RuleExpr parseConditionBlock(List<DslLine> block) {
    final firstLine = block[0];
    final exprText = firstLine.text.substring(2).trim(); // Skip "若 "
    final firstExpr = parseExprLine(exprText, firstLine);
    if (block.length == 1) return firstExpr;

    final children = <RuleExpr>[firstExpr];
    int i = 1;
    while (i < block.length) {
      final line = block[i];
      if (line.text.startsWith('且 ') || line.text == '且') {
        final subText = line.text.length > 1 ? line.text.substring(1).trim() : '';
        if (subText.isEmpty) {
          i++;
          final subBlock = <DslLine>[];
          if (i < block.length) {
            final baseIndent = block[i].indent;
            while (i < block.length && block[i].indent >= baseIndent) {
              subBlock.add(block[i]); i++;
            }
          }
          children.add(parseSubGroup(subBlock, true)); i--;
        } else {
          children.add(parseExprLine(subText, line));
        }
      } else if (line.text.startsWith('或 ') || line.text == '或') {
        final subText = line.text.length > 1 ? line.text.substring(1).trim() : '';
        children.add(parseExprLine(subText, line));
      } else {
        throw DslException(DslDiagnostic(line: line.lineNumber, column: 1, message: '无法识别条件块结构: ${line.text}'));
      }
      i++;
    }
    return children.length > 1 ? AllExpr(children) : children.first;
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
    final baseExpr = _matchPattern(text, line);
    if (baseExpr == null) {
      throw DslException(DslDiagnostic(line: line.lineNumber, column: 1, message: '无法识别条件: $text'));
    }
    return isNot ? NotExpr(baseExpr) : baseExpr;
  }

  static RuleExpr? _matchPattern(String text, DslLine line) {
    if (text.contains(' 六亲为')) return _binLit(text, ' 六亲为', 'relative');
    if (text.contains(' 六神为')) return _binLit(text, ' 六神为', 'spirit');
    if (text.contains(' 生 ')) return _binRel(text, ' 生 ', 'generate');
    if (text.contains(' 有标签 ')) {
      final p = text.split(' 有标签 ');
      final tags = p[1].trim().split(':');
      return PredicateExpr(operatorId: 'has_tag', operands: [
        BindingRefOperand(p[0].trim()), LiteralOperand(RuleValue.string(tags[0])), LiteralOperand(RuleValue.string(tags[1]))
      ]);
    }
    if (text.contains(' 纳音为')) {
      final p = text.split(' 纳音为');
      final nayinStr = p[1].trim();
      final stableId = dslNaYinToId[nayinStr] ?? 'nayin.unknown';
      return PredicateExpr(operatorId: 'nayin_is', operands: [
        BindingRefOperand(p[0].trim()), LiteralOperand(RuleValue.string(stableId))
      ]);
    }
    if (text.contains(' 出墓于 ') && text.contains(' 冲 ')) {
      final p1 = text.split(' 出墓于 ');
      final p2 = p1[1].split(' 冲 ');
      return PredicateExpr(operatorId: 'chu_mu', operands: [
        BindingRefOperand(p1[0].trim()), BindingRefOperand(p2[0].trim()), BindingRefOperand(p2[1].trim())
      ]);
    }
    if (text.contains(' 入墓于 ')) return _binRel(text, ' 入墓于 ', 'ru_mu');
    if (text.contains(' 冲墓于 ')) return _binRel(text, ' 冲墓于 ', 'chong_mu');
    if (text.endsWith(' 月破')) return _unary(text, ' 月破', 'yue_po');
    if (text.endsWith(' 日破')) return _unary(text, ' 日破', 'ri_po');
    if (text.endsWith(' 旬空')) return _unary(text, ' 旬空', 'xun_kong');
    if (text.endsWith(' 为空')) return _unary(text, ' 为空', 'empty');
    if (text.endsWith(' 在墓中')) return _unary(text, ' 在墓中', 'in_tomb');
    return null;
  }

  static RuleExpr _binLit(String text, String sep, String op) {
    final p = text.split(sep);
    return PredicateExpr(operatorId: op, operands: [BindingRefOperand(p[0].trim()), LiteralOperand(RuleValue.string(p[1].trim()))]);
  }
  static RuleExpr _binRel(String text, String sep, String op) {
    final p = text.split(sep);
    return PredicateExpr(operatorId: op, operands: [BindingRefOperand(p[0].trim()), BindingRefOperand(p[1].trim())]);
  }
  static RuleExpr _unary(String text, String suffix, String op) {
    return PredicateExpr(operatorId: op, operands: [BindingRefOperand(text.replaceAll(suffix, '').trim())]);
  }
}
