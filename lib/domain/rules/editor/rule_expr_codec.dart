library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/rule_value.dart';

class RuleExprCodec {
  static Map<String, dynamic> toJson(RuleExpr expr) {
    if (expr is AllExpr) {
      return {'type': 'all', 'nodes': expr.nodes.map(toJson).toList()};
    }
    if (expr is AnyExpr) {
      return {'type': 'any', 'nodes': expr.nodes.map(toJson).toList()};
    }
    if (expr is NotExpr) return {'type': 'not', 'node': toJson(expr.node)};
    if (expr is PredicateExpr) {
      return {
        'type': 'predicate',
        'operatorId': expr.operatorId,
        'operands': expr.operands.map((o) {
          if (o is BindingRefOperand) {
            return {'kind': 'ref', 'bindingName': o.bindingName};
          }
          if (o is LiteralOperand) {
            return {'kind': 'lit', 'value': o.value.toJson()};
          }
          throw ArgumentError('Unknown operand');
        }).toList(),
      };
    }
    throw ArgumentError('Unknown RuleExpr');
  }

  static RuleExpr fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'all':
        return AllExpr(
          (json['nodes'] as List).map((j) => fromJson(j)).toList(),
        );
      case 'any':
        return AnyExpr(
          (json['nodes'] as List).map((j) => fromJson(j)).toList(),
        );
      case 'not':
        return NotExpr(fromJson(json['node']));
      case 'predicate':
        return PredicateExpr(
          operatorId: json['operatorId'],
          operands: (json['operands'] as List).map<RuleOperand>((o) {
            if (o['kind'] == 'ref') return BindingRefOperand(o['bindingName']);
            if (o['kind'] == 'lit') {
              return LiteralOperand(RuleValue.fromJson(o['value']));
            }
            throw ArgumentError('Unknown operand json');
          }).toList(),
        );
    }
    throw ArgumentError('Unknown expr type ${json['type']}');
  }
}
