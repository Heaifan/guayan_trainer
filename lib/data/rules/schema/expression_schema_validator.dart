library;

import 'condition_semantic_validator.dart';

class ExpressionSchemaValidator {
  static void validate(dynamic expr, Set<String> bindingNames) {
    if (expr is! Map) throw FormatException('AST 节点必须是对象');
    final type = expr['type'];
    if (type == 'ALL' || type == 'ANY') {
      final nodes = expr['nodes'] as List?;
      if (nodes == null || nodes.isEmpty) throw FormatException('\ empty');
      for (final n in nodes) validate(n, bindingNames);
    } else if (type == 'NOT') {
      if (!expr.containsKey('node')) throw FormatException('NOT missing node');
      final node = expr['node'];
      if (node == null) throw FormatException('NOT invalid child count');
      validate(node, bindingNames);
    } else if (type == 'PREDICATE') {
      ConditionSemanticValidator.validatePredicate(expr, bindingNames);
    } else {
      throw FormatException('unknown AST node type: ');
    }
  }
}
