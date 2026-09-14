library;

/// JSON Schema 验证器。
/// 确保外部注入的 JSON 符合 Canonical Rule Schema。
class RuleSchemaValidator {
  static void validate(Map<String, dynamic> json) {
    if (json.containsKey('script') || json.containsKey('dart') || json.containsKey('javascript') || json.containsKey('executable') || json.containsKey('evaluator') || json.containsKey('eval')) {
      throw FormatException('规则不允许包含可执行代码字段');
    }

    final ruleId = json['ruleId'];
    if (ruleId == null || ruleId is! String || ruleId.trim().isEmpty) {
      throw FormatException('ruleId不能为空');
    }

    final version = json['version'];
    if (version == null || version is! String || version.trim().isEmpty) {
      throw FormatException('无效的RuleVersion');
    }

    final bindings = json['bindings'] as List?;
    if (bindings != null) {
      final names = <String>{};
      for (final b in bindings) {
        final name = b['name'];
        if (name == null) throw FormatException('Binding必须有name');
        if (!names.add(name)) {
          throw FormatException('Duplicate Binding name: $name');
        }
      }
    } else {
      throw FormatException('bindings不能为空');
    }

    final actions = json['actions'] as List?;
    if (actions == null || actions.isEmpty) {
      throw FormatException('actions不能为空');
    }
    for (final act in actions) {
      final type = act['type'];
      if (type == 'tag') {
        final categoryId = act['categoryId'];
        final tagId = act['tagId'];
        if (categoryId == null || (categoryId as String).trim().isEmpty) throw FormatException('Tag without categoryId');
        if (tagId == null || (tagId as String).trim().isEmpty) throw FormatException('Tag without tagId');
      }
    }

    final condition = json['condition'];
    if (condition != null) {
      _validateExpr(condition, bindings.map((e) => e['name'] as String).toSet());
    } else {
      throw FormatException('condition不能为空');
    }
  }

  static void _validateExpr(dynamic expr, Set<String> bindingNames) {
    if (expr is! Map) throw FormatException('AST 节点必须是对象');
    final type = expr['type'];
    if (type == 'ALL' || type == 'ANY') {
      final nodes = expr['nodes'] as List?;
      if (nodes == null || nodes.isEmpty) throw FormatException('$type empty');
      for (final n in nodes) {
        _validateExpr(n, bindingNames);
      }
    } else if (type == 'NOT') {
      final node = expr['node'];
      if (node == null) throw FormatException('NOT invalid child count');
      _validateExpr(node, bindingNames);
    } else if (type == 'PREDICATE') {
      final operands = expr['operands'] as List?;
      if (operands != null) {
        for (final op in operands) {
          if (op['type'] == 'bindingRef') {
            final name = op['name'];
            if (!bindingNames.contains(name)) throw FormatException('unbound BindingRef: $name');
          }
        }
      }
    } else {
      throw FormatException('unknown AST node');
    }
  }
}
