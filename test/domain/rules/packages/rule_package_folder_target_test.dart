import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_service.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_store.dart';
import 'package:guayan_trainer/domain/rules/packages/global_rule_pack_registry.dart';
import 'package:guayan_trainer/domain/rules/packages/portable_rule_package.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_importer.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_store.dart';

void main() {
  test('imports package rules into the selected folder', () async {
    SharedPreferences.setMockInitialValues({});
    final package = PortableRulePackage.fromJson(
      Map<String, Object?>.from(jsonDecode(
        await File('test/fixtures/external_test_pack.json').readAsString(),
      ) as Map),
    );
    final packageStore = RulePackageStore();
    final registry = GlobalRulePackRegistry(packageStore);
    final library = RuleLibraryService(RuleLibraryStore());
    await library.load();
    final folder = await library.createFolder('家宅');
    final importer = RulePackageImporter(
      store: packageStore,
      registry: registry,
      libraryService: library,
      existingRules: CommonRuleCorpus.v1(),
      systemRuleIds: CommonRuleCorpus.v1().map((rule) => rule.ruleId),
    );

    expect((await importer.install(package, targetFolderId: folder.folderId)).isValid, isTrue);
    expect(library.index.recursiveRuleCount(folder.folderId), package.rules.length);
  });
}
