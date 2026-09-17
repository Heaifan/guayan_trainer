import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/packages/portable_rule_package.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_error.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_validator.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack_id.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack_scope.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';

void main() {
  final rules = CommonRuleCorpus.v1();

  PortableRulePackage package({
    List<Map<String, Object?>> mappings = const [],
    List<Map<String, Object?>> customShensha = const [],
    Map<String, List<String>> dependencies = const {},
  }) {
    final userRule = RuleDefinitionCodec.fromJson({
      ...RuleDefinitionCodec.toJson(rules.first),
      'ruleId': 'user.imported.rule',
      'origin': 'CUSTOM',
      'namespace': 'user.imported',
    });
    return PortableRulePackage(
      packId: 'user.example.pack',
      name: '示例规则包',
      version: RuleVersion('1.0.0'),
      rules: [userRule],
      mappings: mappings,
      customShensha: customShensha,
      dependencies: dependencies,
    );
  }

  test('valid package encodes and validates as USER content', () {
    final value = package(
      mappings: [
        {'key': 'branch.卯', 'image': '手脚'},
      ],
      customShensha: [
        {'id': 'custom.test', 'name': '测试神煞', 'description': '测试'},
      ],
    );

    final restored = PortableRulePackage.fromJson(value.toJson());
    final result = RulePackageValidator.validate(
      restored,
      existingRules: rules,
      installedPacks: const [],
      systemRuleIds: rules.map((rule) => rule.ruleId),
    );

    expect(result.isValid, isTrue);
    expect(restored.origin, RuleOrigin.CUSTOM);
  });

  test('rejects malformed schema and future versions with readable errors', () {
    expect(
      () => PortableRulePackage.fromJson({'schema': 'wrong', 'schemaVersion': 1}),
      throwsA(isA<RulePackageFormatException>()),
    );
    expect(
      () => PortableRulePackage.fromJson({
        'schema': 'guayan.rulepack',
        'schemaVersion': 99,
      }),
      throwsA(isA<RulePackageVersionException>()),
    );
  });

  test('rejects system override and same-version duplicate', () {
    final systemOverride = package();
    final systemRule = rules.first;
    final systemResult = RulePackageValidator.validate(
      PortableRulePackage.fromJson({
        ...systemOverride.toJson(),
        'pack': {
          'id': 'system.override',
          'name': '非法系统包',
          'version': '1.0.0',
          'origin': 'SYSTEM',
        },
        'rules': [
          {
            ...RuleDefinitionCodec.toJson(systemOverride.rules.first),
            'origin': 'SYSTEM',
            'ruleId': systemRule.ruleId.id,
          },
        ],
      }),
      existingRules: rules,
      installedPacks: const [],
      systemRuleIds: rules.map((rule) => rule.ruleId),
    );
    expect(systemResult.errors, contains(isA<RulePackageIssue>()));

    final duplicateResult = RulePackageValidator.validate(
      package(),
      existingRules: rules,
      installedPacks: [
        RulePack(
          packId: const RulePackId('user.example.pack'),
          version: RuleVersion('1.0.0'),
          origin: RuleOrigin.CUSTOM,
          scope: RulePackScope.COMMON,
          title: '已有',
          ruleIds: [RuleId(rules.first.ruleId.id)],
        ),
      ],
      systemRuleIds: rules.map((rule) => rule.ruleId),
    );
    expect(duplicateResult.errors, contains(isA<RulePackageIssue>()));
  });

  test('rejects missing declared dependencies before install', () {
    final result = RulePackageValidator.validate(
      package(
        dependencies: {
          'mappings': ['branch.巳'],
          'customShensha': ['custom.missing'],
        },
      ),
      existingRules: rules,
      installedPacks: const [],
      systemRuleIds: rules.map((rule) => rule.ruleId),
    );
    expect(result.errors.map((error) => error.code), contains('missing_mapping'));
    expect(
      result.errors.map((error) => error.code),
      contains('missing_custom_shensha'),
    );
  });
}
