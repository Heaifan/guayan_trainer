import '../ast/rule_action.dart';
import '../ast/rule_binding.dart';
import '../ast/binding_selector.dart';
import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/rule_value.dart';
import '../core/rule_definition.dart';
import 'rule_value_catalog.dart';
import 'rule_tag_catalog.dart';
import '../objects/dynamic_object_catalog.dart';

enum VisualTokenKind {
  keyword,
  object,
  property,
  operator,
  value,
  resultType,
  resultValue,
}

class VisualToken {
  const VisualToken(this.text, this.kind, {this.actionIndex});
  final String text;
  final VisualTokenKind kind;
  final int? actionIndex;
}

class VisualRuleLine {
  const VisualRuleLine(this.indent, this.tokens);
  final int indent;
  final List<VisualToken> tokens;
}

/// AST 的只读投影。编辑器只保存 AST，Token 只是渲染结果。
class RuleVisualRenderer {
  const RuleVisualRenderer();

  List<VisualRuleLine> render(RuleDefinition rule) {
    final lines = <VisualRuleLine>[
      const VisualRuleLine(0, [VisualToken('若', VisualTokenKind.keyword)]),
    ];
    _renderExpr(rule.condition, rule.bindings, lines, 1, null);
    lines.add(
      const VisualRuleLine(0, [VisualToken('则', VisualTokenKind.keyword)]),
    );
    for (var i = 0; i < rule.actions.length; i++) {
      lines.add(VisualRuleLine(1, _actionTokens(rule.actions[i], i)));
    }
    return lines;
  }

  void _renderExpr(
    RuleExpr expr,
    List<RuleBinding> bindings,
    List<VisualRuleLine> lines,
    int indent,
    String? joiner,
  ) {
    if (expr is AllExpr || expr is AnyExpr) {
      final nodes = expr is AllExpr ? expr.nodes : (expr as AnyExpr).nodes;
      for (var i = 0; i < nodes.length; i++) {
        _renderExpr(
          nodes[i],
          bindings,
          lines,
          indent,
          i == 0
              ? null
              : expr is AllExpr
              ? '且'
              : '或',
        );
      }
      return;
    }
    if (expr is NotExpr) {
      final rendered = _predicate(expr.node, bindings);
      lines.add(
        VisualRuleLine(indent, [
          if (joiner != null) VisualToken(joiner, VisualTokenKind.keyword),
          const VisualToken('非', VisualTokenKind.keyword),
          ...rendered,
        ]),
      );
      return;
    }
    if (expr is QuantifiedExpr) {
      lines.add(
        VisualRuleLine(indent, [
          if (joiner != null) VisualToken(joiner, VisualTokenKind.keyword),
          VisualToken(_quantifierText(expr), VisualTokenKind.object),
        ]),
      );
      _renderExpr(
        expr.node,
        [...bindings, RuleBinding(name: expr.bindingName, selector: expr.selector)],
        lines,
        indent + 1,
        null,
      );
      return;
    }
    if (expr is PredicateExpr) {
      final tokens = <VisualToken>[];
      if (joiner != null) {
        tokens.add(VisualToken(joiner, VisualTokenKind.keyword));
      }
      tokens.addAll(_predicate(expr, bindings));
      lines.add(VisualRuleLine(indent, tokens));
    }
  }

  List<VisualToken> _predicate(RuleExpr expr, List<RuleBinding> bindings) {
    if (expr is! PredicateExpr) {
      return const [VisualToken('[选择条件]', VisualTokenKind.operator)];
    }
    final op = _operatorName(expr.operatorId);
    final result = <VisualToken>[];
    if (expr.operatorId == 'structure_formed') {
      return [
        VisualToken('结构', VisualTokenKind.object),
        VisualToken('成结构', VisualTokenKind.property),
        VisualToken(
          expr.operands.isEmpty
              ? '[选择值]'
              : _operandText(expr.operands.first, bindings),
          VisualTokenKind.value,
        ),
      ];
    }
    if (expr.operands.isNotEmpty) {
      result.add(
        VisualToken(
          _operandText(expr.operands.first, bindings),
          VisualTokenKind.object,
        ),
      );
    } else {
      result.add(const VisualToken('[选择对象]', VisualTokenKind.object));
    }
    result.add(
      VisualToken(_propertyName(expr.operatorId), VisualTokenKind.property),
    );
    result.add(VisualToken(op, VisualTokenKind.operator));
    if (expr.operands.length > 1) {
      result.add(
        VisualToken(
          _operandText(expr.operands[1], bindings),
          VisualTokenKind.value,
        ),
      );
    } else if (!_unary(expr.operatorId)) {
      result.add(const VisualToken('[选择值]', VisualTokenKind.value));
    }
    return result;
  }

  String _operandText(RuleOperand operand, List<RuleBinding> bindings) {
    if (operand is LiteralOperand) return _valueText(operand.value);
    final name = (operand as BindingRefOperand).bindingName;
    RuleBinding? binding;
    for (final item in bindings) {
      if (item.name == name) binding = item;
    }
    if (binding?.selector case final DirectSelector selector) {
      final target = selector.target;
      final match = RegExp(r'line/([1-6])').firstMatch(target);
      if (match != null) {
        return const [
          '初爻',
          '二爻',
          '三爻',
          '四爻',
          '五爻',
          '上爻',
        ][int.parse(match.group(1)!) - 1];
      }
    }
    if (binding?.selector case final DynamicBindingSelector selector) {
      return DynamicObjectCatalog.displayNameFor(selector);
    }
    return '[选择对象]';
  }

  String _valueText(RuleValue value) {
    final raw = value.value?.toString() ?? '';
    return raw.isEmpty ? '[选择值]' : RuleValueCatalog.display(raw);
  }

  String _propertyName(String id) => switch (id) {
    'relative' => '六亲',
    'spirit' => '六神',
    'nayin_is' => '纳音',
    'stem_is' => '天干',
    'branch_is' => '地支',
    'element_is' => '五行',
    'wuxing_overcomes' ||
    'branch_clashes' ||
    'branch_combines' ||
    'branch_punishes' ||
    'branch_harms' ||
    'branch_breaks' => '关系',
    _ => '状态',
  };

  String _operatorName(String id) => switch (id) {
    'relative' || 'spirit' || 'nayin_is' => '为',
    'empty' || 'xun_kong' => '旬空',
    'yue_po' => '月破',
    'ri_po' => '日破',
    'in_tomb' => '在库',
    'generate' => '生',
    'wuxing_overcomes' => '克',
    'branch_clashes' => '冲',
    'branch_combines' => '合',
    'branch_punishes' => '刑',
    'branch_harms' => '害',
    'branch_breaks' => '破',
    'ru_mu' => '入库于',
    'chong_mu' => '冲库',
    'chu_mu' => '出库',
    _ => '有',
  };

  String _quantifierText(QuantifiedExpr expr) {
    final object = DynamicObjectCatalog.displayNameFor(expr.selector);
    return switch (expr.kind) {
      QuantifierKind.any => object,
      QuantifierKind.all => '全部$object',
      QuantifierKind.none => '不存在$object',
    QuantifierKind.atLeast => '至少 ${expr.count} 个',
    QuantifierKind.exactly => '恰好 ${expr.count} 个',
    };
  }

  bool _unary(String id) =>
      const {'empty', 'xun_kong', 'yue_po', 'ri_po', 'in_tomb'}.contains(id);

  List<VisualToken> _actionTokens(RuleAction action, int index) {
    if (action is TagAction) {
      final type = action.categoryId == 'image' ? '取象' : '标签';
      return [
        VisualToken(type, VisualTokenKind.resultType, actionIndex: index),
        VisualToken(
          _tagText(action.tagId),
          VisualTokenKind.resultValue,
          actionIndex: index,
        ),
      ];
    }
    if (action is DeriveAction) {
      return [
        VisualToken('状态', VisualTokenKind.resultType, actionIndex: index),
        VisualToken(
          _textOrPlaceholder(action.factKey),
          VisualTokenKind.resultValue,
          actionIndex: index,
        ),
      ];
    }
    if (action is StructureAction) {
      return [
        VisualToken('记录结果', VisualTokenKind.resultType, actionIndex: index),
        VisualToken(
          _textOrPlaceholder(action.structureId),
          VisualTokenKind.resultValue,
          actionIndex: index,
        ),
      ];
    }
    final record = action as RecordAction;
    return [
      VisualToken('记录结果', VisualTokenKind.resultType, actionIndex: index),
      VisualToken(
        _textOrPlaceholder(record.content['text']?.value?.toString() ?? ''),
        VisualTokenKind.resultValue,
        actionIndex: index,
      ),
    ];
  }

  String _tagText(String id) => id == 'custom'
      ? '[自定义填写]'
      : RuleTagCatalog.display(id);

  String _textOrPlaceholder(String text) =>
      text.isEmpty || text == 'custom.state' ? '[自定义填写]' : text;
}
