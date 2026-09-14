library;

import '../../../domain/rules/core/rule_version.dart';
import 'binding_schema_validator.dart';
import 'expression_schema_validator.dart';
import 'action_schema_validator.dart';

class RuleSchemaValidator {
  static void validate(Map<String, dynamic> json) {
    _validateNoExecutable(json);

    if (json['schemaVersion'] != 1) {
      throw FormatException('Unsupported schemaVersion, must be 1.');
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
    if (bindings == null) throw FormatException('bindings不能为空');
    final declaredBindings = BindingSchemaValidator.validateAndCollect(bindings);

    final condition = json['condition'];
    if (condition == null) throw FormatException('condition不能为空');
    ExpressionSchemaValidator.validate(condition, declaredBindings);

    final actions = json['actions'] as List?;
    if (actions == null || actions.isEmpty) throw FormatException('actions不能为空');
    ActionSchemaValidator.validate(actions, declaredBindings);
  }

  static void _validateNoExecutable(dynamic node) {
    if (node is Map) {
      if (node.containsKey('script') || node.containsKey('dart') ||
          node.containsKey('javascript') || node.containsKey('executable') ||
          node.containsKey('evaluator') || node.containsKey('eval')) {
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
