import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';
import 'package:guayan_trainer/domain/rules/packages/global_rule_pack_registry.dart';
import 'package:guayan_trainer/domain/rules/packages/portable_rule_package.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_importer.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PortableRulePackage sample() {
    final source = CommonRuleCorpus.v1().first;
    final rule = RuleDefinitionCodec.fromJson({
      ...RuleDefinitionCodec.toJson(source),
      'ruleId': 'user.store.rule',
      'origin': 'CUSTOM',
      'namespace': 'user.imported',
    });
    return PortableRulePackage(
      packId: 'user.store.pack',
      name: '持久化测试包',
      version: RuleVersion('1.0.0'),
      rules: [rule],
    );
  }

  test('install defaults enabled and survives a fresh registry load', () async {
    final package = sample();
    final store = RulePackageStore();
    final registry = GlobalRulePackRegistry(store);
    final importer = RulePackageImporter(
      store: store,
      registry: registry,
      existingRules: CommonRuleCorpus.v1(),
      systemRuleIds: CommonRuleCorpus.v1().map((rule) => rule.ruleId),
    );

    final result = await importer.install(package);
    expect(result.isValid, isTrue);
    expect(registry.enabledUserPacks.single.package.packId, package.packId);
    expect(registry.enabledUserPacks.single.enabled, isTrue);

    final restored = GlobalRulePackRegistry(RulePackageStore());
    await restored.load();
    expect(restored.enabledUserPacks.single.enabled, isTrue);
    await restored.setEnabled(package.packId, false);
    expect(restored.enabledUserPacks, isEmpty);
    await restored.setEnabled(package.packId, true);
    expect(restored.enabledUserPacks.single.package.version, package.version);
  });

  test('failed install leaves previously installed package untouched', () async {
    final store = RulePackageStore();
    final registry = GlobalRulePackRegistry(store);
    final importer = RulePackageImporter(
      store: store,
      registry: registry,
      existingRules: CommonRuleCorpus.v1(),
      systemRuleIds: CommonRuleCorpus.v1().map((rule) => rule.ruleId),
    );
    await importer.install(sample());
    final invalid = PortableRulePackage(
      packId: 'user.invalid.pack',
      name: '坏包',
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.SYSTEM,
      rules: const [],
    );

    final result = await importer.install(invalid);
    expect(result.isValid, isFalse);
    expect(store.loadInstalled().map((item) => item.package.packId),
        ['user.store.pack']);
  });
}
