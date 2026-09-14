library;

import '../../../domain/rules/core/rule_version.dart';
import '../../../domain/rules/vocabulary/condition_registry.dart';
import '../../../domain/rules/vocabulary/condition_id.dart';
import '../../../domain/rules/vocabulary/nayin_id.dart';
import '../../../domain/rules/vocabulary/tag_category_ids.dart';

/// JSON Schema 验证器。
/// 确保外部注入的 JSON 符合 Canonical Rule Schema。
class RuleSchemaValidator {
  static void validate(Map<String, dynamic> json) {
    _validateNoExecutable(json);

    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw FormatException('Unsupported schemaVersion, must be 1. Got: ');
    }

    final ruleId = json['ruleId'];
    if (ruleId == null || ruleId is! String || ruleId.trim().isEmpty) {
      throw FormatException('ruleId不能为空');
    }

    final version = json['version'];
    if (version == null || version is! String) {
      throw FormatException('无效的RuleVersion');
    }
    try {
      RuleVersion(version);
    } catch (e) {
      throw FormatException('无效的RuleVersion: ');
    }

    final bindings = json['bindings'] as List?;
    final declaredBindings = <String>{};
    if (bindings != null) {
      // Pass 1: Collect and deduplicate
      for (final b in bindings) {
        final name = b['name'];
        if (name == null) throw FormatException('Binding必须有name');
        if (!declaredBindings.add(name)) {
          throw FormatException('Duplicate Binding name: ');
        }
      }
      // Pass 2: Validate selectors
      for (final b in bindings) {
        final selector = b['selector'];
        if (selector == null || selector is! Map) throw FormatException('Binding missing selector');
        final type = selector['type'];
        if (type == 'direct') {
          if (selector['target'] == null) throw FormatException('DirectSelector missing target');
        } else if (type == 'relative') {
          final baseBinding = selector['base'];
          if (baseBinding == null || selector['path'] == null) throw FormatException('RelativeSelector missing base or path');
          if (!declaredBindings.contains(baseBinding)) {
             throw FormatException('RelativeSelector unknown base binding: ');
          }
        } else {
          throw FormatException('Unknown BindingSelector type: ');
        }
      }
    } else {
      throw FormatException('bindings不能为空');
    }

    final condition = json['condition'];
    if (condition != null) {
      _validateExpr(condition, declaredBindings);
    } else {
      throw FormatException('condition不能为空');
    }

    final actions = json['actions'] as List?;
    if (actions == null || actions.isEmpty) {
      throw FormatException('actions不能为空');
    }
    for (final act in actions) {
      final type = act['type'];
      if (type == 'derive') {
        final target = act['target'];
        if (!declaredBindings.contains(target)) throw FormatException('derive targetBinding not found: ');
      } else if (type == 'tag') {
        final categoryId = act['categoryId'];
        final tagId = act['tagId'];
        if (categoryId == null || (categoryId as String).trim().isEmpty) throw FormatException('Tag without categoryId');
        if (tagId == null || (tagId as String).trim().isEmpty) throw FormatException('Tag without tagId');
        final subject = act['subject'];
        if (subject != null && !declaredBindings.contains(subject)) throw FormatException('tag subjectBinding not found: ');
      } else if (type == 'structure') {
        final structureId = act['structureId'];
        if (structureId == null || (structureId as String).trim().isEmpty) throw FormatException('Structure without structureId');
        final members = act['members'] as List?;
        if (members == null) throw FormatException('Structure missing members');
        for (final m in members) {
          if (!declaredBindings.contains(m)) throw FormatException('structure memberBinding not found: ');
        }
      } else if (type == 'record') {
        final recordType = act['recordType'];
        if (recordType == null || (recordType as String).trim().isEmpty) throw FormatException('Record without recordType');
        final content = act['content'];
        if (content == null || content is! Map) throw FormatException('Record missing content');
        for (final v in content.values) {
          if (v != null && v is! String && v is! int && v is! double && v is! bool) {
            throw FormatException('Record content values must be scalar (null, String, int, double, bool), found: ');
          }
        }
      } else {
        throw FormatException('unknown action type: ');
      }
    }
  }

  static dynamic _getLiteralValue(Map op) {
    if (op['type'] == 'literal') {
       return op['value'];
    }
    return null;
  }

  static void _validateExpr(dynamic expr, Set<String> bindingNames) {
    if (expr is! Map) throw FormatException('AST 节点必须是对象');
    final type = expr['type'];
    if (type == 'ALL' || type == 'ANY') {
      final nodes = expr['nodes'] as List?;
      if (nodes == null || nodes.isEmpty) throw FormatException(' empty');
      for (final n in nodes) {
        _validateExpr(n, bindingNames);
      }
    } else if (type == 'NOT') {
      if (!expr.containsKey('node')) throw FormatException('NOT missing node');
      final node = expr['node'];
      if (node == null) throw FormatException('NOT invalid child count');
      _validateExpr(node, bindingNames);
    } else if (type == 'PREDICATE') {
      final operatorId = expr['operatorId'];
      if (operatorId == null) throw FormatException('operatorId missing');
      final def = CanonicalConditionRegistry.getDefinition(operatorId as String);
      if (def == null) throw FormatException('unknown canonical operator: ');

      final operands = expr['operands'] as List?;
      if (operands == null) throw FormatException('operands missing');
      if (operands.length != def.operandCount) throw FormatException('operand count mismatch: expected , got ');

      if (operands != null) {
        for (final op in operands) {
          if (op is! Map) throw FormatException('Operand must be object');
          final opType = op['type'];
          if (opType == 'bindingRef') {
            final name = op['name'];
            if (name == null || name is! String) throw FormatException('binding operand malformed: missing name');
            if (!bindingNames.contains(name)) throw FormatException('unbound BindingRef: ');
          } else if (opType == 'literal') {
             // valid
          } else {
             throw FormatException('unknown operand type: ');
          }
        }
      }

      // Semantic checks for specific operators
      if (operatorId == ConditionId.nayinIs) {
        final literal = _getLiteralValue(operands[1] as Map);
        if (literal == null || literal is! String || !NaYinId.isValid(literal)) {
          throw FormatException('invalid NaYinId: ');
        }
      } else if (operatorId == ConditionId.hasTag) {
        final categoryLiteral = _getLiteralValue(operands[1] as Map);
        if (categoryLiteral != CanonicalTagCategoryId.shensha) {
          throw FormatException('invalid Tag category: ');
        }
        final tagIdLiteral = _getLiteralValue(operands[2] as Map);
        if (tagIdLiteral == null || tagIdLiteral is! String) {
          throw FormatException('invalid ShenSha stable-id format: ');
        }
        final shenshaRegex = RegExp(r'^shensha\.(sys|custom)\.[a-zA-Z0-9_]+$');
        if (!shenshaRegex.hasMatch(tagIdLiteral)) {
          throw FormatException('invalid ShenSha stable-id format: ');
        }
      }
    } else {
      throw FormatException('unknown AST node type: ');
    }
  }

  static void _validateNoExecutable(dynamic node) {
    if (node is Map) {
      if (node.containsKey('script') || node.containsKey('dart') || node.containsKey('javascript') ||
          node.containsKey('executable') || node.containsKey('evaluator') || node.containsKey('eval')) {
        throw FormatException('规则不允许包含可执行代码字段');
      }
      for (final value in node.values) {
        _validateNoExecutable(value);
      }
    } else if (node is List) {
      for (final value in node) {
        _validateNoExecutable(value);
      }
    }
  }
}
