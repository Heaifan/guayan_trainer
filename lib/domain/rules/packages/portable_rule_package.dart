import '../ast/rule_expr.dart';
import '../core/rule_definition.dart';
import '../core/rule_origin.dart';
import '../core/rule_version.dart';
import '../editor/custom_shen_sha_definition.dart';
import '../editor/rule_definition_codec.dart';
import 'rule_package_error.dart';

class PortableRulePackage {
  const PortableRulePackage({
    required this.packId,
    required this.name,
    required this.version,
    required this.rules,
    this.mappings = const [],
    this.customShensha = const [],
    this.dependencies = const {},
    this.origin = RuleOrigin.CUSTOM,
    this.schemaVersion = 1,
  });

  static const schema = 'guayan.rulepack';

  final String packId;
  final String name;
  final RuleVersion version;
  final List<RuleDefinition> rules;
  final List<Map<String, Object?>> mappings;
  final List<Map<String, Object?>> customShensha;
  final Map<String, List<String>> dependencies;
  final RuleOrigin origin;
  final int schemaVersion;

  Map<String, Object?> toJson() => {
    'schema': schema,
    'schemaVersion': schemaVersion,
    'pack': {
      'id': packId,
      'name': name,
      'version': version.version,
      'origin': origin.name,
    },
    'rules': rules.map(RuleDefinitionCodec.toJson).toList(),
    'mappings': mappings,
    'customShensha': customShensha,
    'dependencies': dependencies,
  };

  factory PortableRulePackage.fromJson(Map<String, Object?> json) {
    if (json['schema'] != schema) {
      throw const RulePackageFormatException('不是卦眼规则包');
    }
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw RulePackageVersionException('规则包版本过新: $schemaVersion');
    }
    final pack = _map(json['pack'], 'pack');
    final rawRules = json['rules'];
    if (rawRules is! List) {
      throw const RulePackageFormatException('规则包缺少 rules');
    }
    final rawMappings = json['mappings'];
    final rawShensha = json['customShensha'];
    final rawDependencies = json['dependencies'];
    return PortableRulePackage(
      packId: _string(pack['id'], 'pack.id'),
      name: _string(pack['name'], 'pack.name'),
      version: RuleVersion(_string(pack['version'], 'pack.version')),
      origin: _origin(pack['origin']),
      rules: rawRules
          .map((item) => RuleDefinitionCodec.fromJson(_map(item, 'rule')))
          .toList(),
      mappings: _maps(rawMappings),
      customShensha: _maps(rawShensha),
      dependencies: _dependencies(rawDependencies),
      schemaVersion: schemaVersion as int,
    );
  }

  static Map<String, Object?> _map(Object? value, String field) {
    if (value is Map) return Map<String, Object?>.from(value);
    throw RulePackageFormatException('规则包字段 $field 格式错误');
  }

  static String _string(Object? value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw RulePackageFormatException('规则包字段 $field 缺失');
  }

  static List<Map<String, Object?>> _maps(Object? value) {
    if (value == null) return const [];
    if (value is! List) throw const RulePackageFormatException('依赖列表格式错误');
    return value.map((item) => _map(item, 'entry')).toList();
  }

  static Map<String, List<String>> _dependencies(Object? value) {
    if (value == null) return const {};
    if (value is! Map) throw const RulePackageFormatException('dependencies 格式错误');
    return value.map(
      (key, raw) => MapEntry(key.toString(), List<String>.from(raw as List)),
    );
  }

  static RuleOrigin _origin(Object? value) => value == 'SYSTEM'
      ? RuleOrigin.SYSTEM
      : RuleOrigin.CUSTOM;

  List<String> get referencedShenShaIds => _referencedValues('shenShaIdLiteral');

  List<String> _referencedValues(String kind) {
    final values = <String>[];
    void visit(RuleExpr expr) {
      if (expr is PredicateExpr) {
        for (final operand in expr.operands) {
          final value = operand.toString();
          if (value.contains(kind)) values.add(value);
        }
      } else if (expr is AllExpr) {
        for (final node in expr.nodes) {
          visit(node);
        }
      } else if (expr is AnyExpr) {
        for (final node in expr.nodes) {
          visit(node);
        }
      } else if (expr is NotExpr) {
        visit(expr.node);
      } else if (expr is QuantifiedExpr) {
        visit(expr.node);
      }
    }
    for (final rule in rules) {
      visit(rule.condition);
    }
    return values;
  }

  List<CustomShenShaDefinition> get customShenShaDefinitions =>
      customShensha.map(CustomShenShaDefinition.fromJson).toList();
}
