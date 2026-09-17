import '../ast/rule_expr.dart';
import '../core/rule_definition.dart';
import '../core/rule_origin.dart';
import '../governance/rule_resolver.dart';
import '../packs/rule_pack.dart';
import '../vocabulary/condition_registry.dart';
import 'portable_rule_package.dart';
import 'rule_package_error.dart';

class RulePackageValidator {
  static RulePackageValidationResult validate(
    PortableRulePackage package, {
    required Iterable<RuleDefinition> existingRules,
    required Iterable<RulePack> installedPacks,
    required Iterable<dynamic> systemRuleIds,
    Iterable<String> installedMappingIds = const [],
    Iterable<String> installedCustomShenShaIds = const [],
  }) {
    final errors = <RulePackageIssue>[];
    final systemIds = systemRuleIds.map((id) => id.toString()).toSet();
    if (package.origin == RuleOrigin.SYSTEM) {
      errors.add(const RulePackageIssue('system_override', 'SYSTEM Rule 不允许覆盖'));
    }
    if (installedPacks.any((pack) =>
        pack.packId.id == package.packId && pack.version == package.version)) {
      errors.add(const RulePackageIssue('duplicate_version', '规则包已安装相同版本'));
    }
    final existingById = {for (final rule in existingRules) rule.ruleId.id: rule};
    for (final rule in package.rules) {
      if (rule.origin != RuleOrigin.CUSTOM || systemIds.contains(rule.ruleId.id)) {
        errors.add(RulePackageIssue('system_override', '规则 ${rule.ruleId.id} 不允许覆盖 SYSTEM'));
      }
      if (existingById[rule.ruleId.id]?.version == rule.version) {
        errors.add(RulePackageIssue('duplicate_rule', '规则 ${rule.ruleId.id} 已存在相同版本'));
      }
      _validateExpr(rule.condition, errors);
    }
    final mappingIds = {
      ...installedMappingIds,
      ...package.mappings.map((item) => item['key']).whereType<String>(),
    };
    for (final id in package.dependencies['mappings'] ?? const <String>[]) {
      if (!mappingIds.contains(id)) {
        errors.add(RulePackageIssue('missing_mapping', '缺少 Mapping: $id'));
      }
    }
    final shenshaIds = {
      ...installedCustomShenShaIds,
      ...package.customShensha.map((item) => item['id']).whereType<String>(),
    };
    for (final id in package.dependencies['customShensha'] ?? const <String>[]) {
      if (!shenshaIds.contains(id)) {
        errors.add(RulePackageIssue('missing_custom_shensha', '缺少自定义神煞: $id'));
      }
    }
    if (errors.isEmpty) {
      try {
        RuleResolver.resolve(package.rules);
      } catch (error) {
        errors.add(RulePackageIssue('rule_conflict', error.toString()));
      }
    }
    return RulePackageValidationResult(errors);
  }

  static void _validateExpr(RuleExpr expr, List<RulePackageIssue> errors) {
    if (expr is PredicateExpr) {
      final definition = CanonicalConditionRegistry.getDefinition(expr.operatorId);
      if (definition == null) {
        errors.add(RulePackageIssue('unknown_operator', '存在未知 Operator: ${expr.operatorId}'));
      } else if (definition.operandCount != expr.operands.length) {
        errors.add(RulePackageIssue('operator_arity', 'Operator ${expr.operatorId} 参数数量错误'));
      }
    } else if (expr is AllExpr) {
      for (final node in expr.nodes) {
        _validateExpr(node, errors);
      }
    } else if (expr is AnyExpr) {
      for (final node in expr.nodes) {
        _validateExpr(node, errors);
      }
    } else if (expr is NotExpr) {
      _validateExpr(expr.node, errors);
    } else if (expr is QuantifiedExpr) {
      _validateExpr(expr.node, errors);
    }
  }
}
