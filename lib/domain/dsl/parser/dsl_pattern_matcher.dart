library;

import '../../rules/ast/rule_expr.dart';
import '../../rules/ast/rule_operand.dart';
import '../../rules/facts/rule_value.dart';
import '../dsl_diagnostics.dart';
import '../dsl_models.dart';
import '../dsl_nayin_map.dart';
import '../../casting/six_relative.dart';
import '../../casting/six_spirit.dart';

class DslPatternMatcher {
  static RuleExpr? matchPattern(String text, DslLine line) {
    if (text.contains(' 六亲为')) {
      final p = text.split(' 六亲为');
      final val = p[1].trim();
      final stableId =
          SixRelative.values.where((e) => e.label == val).firstOrNull?.name ??
          val;
      return PredicateExpr(
        operatorId: 'relative',
        operands: [
          BindingRefOperand(p[0].trim()),
          LiteralOperand(RuleValue.string(stableId)),
        ],
      );
    }
    if (text.contains(' 六神为')) {
      final p = text.split(' 六神为');
      final val = p[1].trim();
      final stableId =
          SixSpirit.values.where((e) => e.label == val).firstOrNull?.name ??
          val;
      return PredicateExpr(
        operatorId: 'spirit',
        operands: [
          BindingRefOperand(p[0].trim()),
          LiteralOperand(RuleValue.string(stableId)),
        ],
      );
    }
    if (text.contains(' 生 ')) return _binRel(text, ' 生 ', 'generate');
    for (final entry in const {
      '天干为': 'stem_is',
      '地支为': 'branch_is',
      '五行为': 'element_is',
    }.entries) {
      if (text.contains(' ${entry.key} ')) {
        return _attribute(text, ' ${entry.key} ', entry.value);
      }
    }
    for (final entry in const {
      ' 克 ': 'wuxing_overcomes',
      ' 冲 ': 'branch_clashes',
      ' 合 ': 'branch_combines',
      ' 刑 ': 'branch_punishes',
      ' 害 ': 'branch_harms',
      ' 破 ': 'branch_breaks',
    }.entries) {
      if (!text.contains('库') &&
          !text.contains('墓') &&
          text.contains(entry.key)) {
        return _binRel(text, entry.key, entry.value);
      }
    }
    if (text.contains(' 有标签 ')) {
      final p = text.split(' 有标签 ');
      final tags = p[1].trim().split(':');
      if (tags.length != 2) {
        throw DslException(
          DslDiagnostic(
            line: line.lineNumber,
            column: 1,
            message: '标签格式错误，应为 category:tag',
          ),
        );
      }
      return PredicateExpr(
        operatorId: 'has_tag',
        operands: [
          BindingRefOperand(p[0].trim()),
          LiteralOperand(RuleValue.string(tags[0])),
          LiteralOperand(RuleValue.string(tags[1])),
        ],
      );
    }
    if (text.contains(' 纳音为')) {
      final p = text.split(' 纳音为');
      final nayinStr = p[1].trim();
      final stableId = dslNaYinToId[nayinStr];
      if (stableId == null) {
        throw DslException(
          DslDiagnostic(
            line: line.lineNumber,
            column: 1,
            message: '无法识别纳音: $nayinStr',
          ),
        );
      }
      return PredicateExpr(
        operatorId: 'nayin_is',
        operands: [
          BindingRefOperand(p[0].trim()),
          LiteralOperand(RuleValue.string(stableId)),
        ],
      );
    }
    return _matchTombAndUnary(text, line);
  }

  static RuleExpr? _matchTombAndUnary(String text, DslLine line) {
    if ((text.contains(' 出库于 ') || text.contains(' 出墓于 ')) &&
        text.contains(' 冲 ')) {
      final sep = text.contains(' 出库于 ') ? ' 出库于 ' : ' 出墓于 ';
      final p1 = text.split(sep);
      final p2 = p1[1].split(' 冲 ');
      return PredicateExpr(
        operatorId: 'chu_mu',
        operands: [
          BindingRefOperand(p1[0].trim()),
          BindingRefOperand(p2[0].trim()),
          BindingRefOperand(p2[1].trim()),
        ],
      );
    }
    if (text.contains(' 入库于 ')) return _binRel(text, ' 入库于 ', 'ru_mu');
    if (text.contains(' 入墓于 ')) return _binRel(text, ' 入墓于 ', 'ru_mu');
    if (text.contains(' 冲库于 ')) return _binRel(text, ' 冲库于 ', 'chong_mu');
    if (text.contains(' 冲墓于 ')) return _binRel(text, ' 冲墓于 ', 'chong_mu');
    if (text.endsWith(' 月破')) return _unary(text, ' 月破', 'yue_po');
    if (text.endsWith(' 日破')) return _unary(text, ' 日破', 'ri_po');
    if (text.endsWith(' 旬空')) return _unary(text, ' 旬空', 'xun_kong');
    if (text.endsWith(' 为空')) return _unary(text, ' 为空', 'empty');
    if (text.endsWith(' 在库')) return _unary(text, ' 在库', 'in_tomb');
    if (text.endsWith(' 在墓中')) return _unary(text, ' 在墓中', 'in_tomb');
    return null;
  }

  static RuleExpr _binRel(String text, String sep, String op) {
    final p = text.split(sep);
    return PredicateExpr(
      operatorId: op,
      operands: [
        BindingRefOperand(p[0].trim()),
        BindingRefOperand(p[1].trim()),
      ],
    );
  }

  static RuleExpr _attribute(String text, String sep, String op) {
    final p = text.split(sep);
    return PredicateExpr(
      operatorId: op,
      operands: [
        BindingRefOperand(p[0].trim()),
        LiteralOperand(RuleValue.string(p[1].trim())),
      ],
    );
  }

  static RuleExpr _unary(String text, String suffix, String op) {
    return PredicateExpr(
      operatorId: op,
      operands: [BindingRefOperand(text.replaceAll(suffix, '').trim())],
    );
  }
}
