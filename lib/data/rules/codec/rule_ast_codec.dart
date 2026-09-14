library;

/// Rule AST 编解码器，处理 Condition 和 Action 节点。
import '../../../domain/rules/ast/binding_selector.dart';
import '../../../domain/rules/ast/rule_action.dart';
import '../../../domain/rules/ast/rule_binding.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';
import 'rule_value_codec.dart';

class RuleAstCodec {
  static Map<String, dynamic> encodeBinding(RuleBinding binding) {
    final selector = binding.selector;
    return {
      'name': binding.name,
      'selector': selector is DirectSelector
          ? {'type': 'direct', 'target': selector.target}
          : {'type': 'relative', 'base': (selector as RelativeSelector).baseBinding, 'path': selector.path},
    };
  }

  static RuleBinding decodeBinding(dynamic json) {
    final map = json as Map<String, dynamic>;
    final selectorMap = map['selector'] as Map<String, dynamic>;
    BindingSelector selector;
    if (selectorMap['type'] == 'direct') {
      selector = DirectSelector(selectorMap['target'] as String);
    } else {
      selector = RelativeSelector(baseBinding: selectorMap['base'] as String, path: selectorMap['path'] as String);
    }
    return RuleBinding(name: map['name'] as String, selector: selector);
  }

  static Map<String, dynamic> encodeExpr(RuleExpr expr) {
    if (expr is AllExpr) return {'type': 'ALL', 'nodes': expr.nodes.map(encodeExpr).toList()};
    if (expr is AnyExpr) return {'type': 'ANY', 'nodes': expr.nodes.map(encodeExpr).toList()};
    if (expr is NotExpr) return {'type': 'NOT', 'node': encodeExpr(expr.node)};
    if (expr is PredicateExpr) {
      return {
        'type': 'PREDICATE',
        'operatorId': expr.operatorId,
        'operands': expr.operands.map(encodeOperand).toList(),
      };
    }
    throw ArgumentError('Unknown RuleExpr');
  }

  static RuleExpr decodeExpr(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'ALL') return AllExpr((json['nodes'] as List).map((e) => decodeExpr(e)).toList());
    if (type == 'ANY') return AnyExpr((json['nodes'] as List).map((e) => decodeExpr(e)).toList());
    if (type == 'NOT') return NotExpr(decodeExpr(json['node']));
    if (type == 'PREDICATE') {
      return PredicateExpr(
        operatorId: json['operatorId'] as String,
        operands: (json['operands'] as List).map((e) => decodeOperand(e)).toList(),
      );
    }
    throw ArgumentError('Unknown RuleExpr type');
  }

  static Map<String, dynamic> encodeOperand(RuleOperand op) {
    if (op is BindingRefOperand) return {'type': 'bindingRef', 'name': op.bindingName};
    if (op is LiteralOperand) return {'type': 'literal', 'value': RuleValueCodec.encode(op.value)};
    throw ArgumentError('Unknown RuleOperand');
  }

  static RuleOperand decodeOperand(dynamic json) {
    final map = json as Map<String, dynamic>;
    if (map['type'] == 'bindingRef') return BindingRefOperand(map['name'] as String);
    if (map['type'] == 'literal') return LiteralOperand(RuleValueCodec.decode(map['value']));
    throw ArgumentError('Unknown RuleOperand type');
  }

  static Map<String, dynamic> encodeAction(RuleAction action) {
    if (action is DeriveAction) return {'type': 'derive', 'target': action.targetBinding, 'factKey': action.factKey};
    if (action is TagAction) return {'type': 'tag', 'categoryId': action.categoryId, 'tagId': action.tagId, if (action.subjectBinding != null) 'subject': action.subjectBinding};
    if (action is StructureAction) return {'type': 'structure', 'structureId': action.structureId, 'members': action.memberBindings};
    if (action is RecordAction) return {'type': 'record', 'recordType': action.recordType, 'content': action.content};
    throw ArgumentError('Unknown RuleAction');
  }

  static RuleAction decodeAction(dynamic json) {
    final map = json as Map<String, dynamic>;
    final type = map['type'];
    if (type == 'derive') return DeriveAction(targetBinding: map['target'] as String, factKey: map['factKey'] as String);
    if (type == 'tag') return TagAction(categoryId: map['categoryId'] as String, tagId: map['tagId'] as String, subjectBinding: map['subject'] as String?);
    if (type == 'structure') return StructureAction(structureId: map['structureId'] as String, memberBindings: (map['members'] as List).cast<String>());
    if (type == 'record') return RecordAction(recordType: map['recordType'] as String, content: map['content'] as Map<String, dynamic>);
    throw ArgumentError('Unknown RuleAction type');
  }
}
