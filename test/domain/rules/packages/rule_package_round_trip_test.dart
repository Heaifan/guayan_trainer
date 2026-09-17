import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/packages/global_rule_pack_registry.dart';
import 'package:guayan_trainer/domain/rules/packages/portable_rule_package.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_importer.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('external golden package imports, persists, and exports semantically equal JSON', () async {
    final raw = await File('test/fixtures/external_test_pack.json').readAsString();
    final package = PortableRulePackage.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
    expect(package.rules, hasLength(4));
    expect(package.mappings, hasLength(2));
    expect(package.customShensha, hasLength(1));
    expect(package.rules.first.condition.runtimeType.toString(), 'QuantifiedExpr');

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
    final restored = store.loadInstalled().single.package;
    expect(restored.toJson(), package.toJson());
  });
}
