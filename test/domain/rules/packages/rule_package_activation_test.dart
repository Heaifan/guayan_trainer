import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/domain/rules/engine/runtime_rule_set_assembler.dart';
import 'package:guayan_trainer/domain/rules/packages/global_rule_pack_registry.dart';
import 'package:guayan_trainer/domain/rules/packages/portable_rule_package.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_importer.dart';
import 'package:guayan_trainer/domain/rules/packages/rule_package_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('new assembly includes enabled USER packs and excludes disabled packs', () async {
    final system = CommonRuleCorpus.v1();
    final userRule = RuleDefinitionCodec.fromJson({
      ...RuleDefinitionCodec.toJson(system.first),
      'ruleId': 'user.activation.rule',
      'origin': 'CUSTOM',
      'namespace': 'user.imported',
    });
    final package = PortableRulePackage(
      packId: 'user.activation.pack',
      name: '启用测试',
      version: RuleVersion('1.0.0'),
      rules: [userRule],
    );
    final store = RulePackageStore();
    final registry = GlobalRulePackRegistry(store);
    final importer = RulePackageImporter(
      store: store,
      registry: registry,
      existingRules: system,
      systemRuleIds: system.map((rule) => rule.ruleId),
    );
    await importer.install(package);
    final assembler = RuntimeRuleSetAssembler(
      customRuleService: CustomRuleService(
        CustomRuleStore(),
        UserGovernanceState(),
      ),
      availableTopics: const [],
      topicRulesMap: const {},
      globalRegistry: registry,
    );

    expect(
      assembler.assemble([]).activeRules.any(
            (rule) => rule.ruleId.id == 'user.activation.rule',
          ),
      isTrue,
    );
    await registry.setEnabled(package.packId, false);
    expect(
      assembler.assemble([]).activeRules.any(
            (rule) => rule.ruleId.id == 'user.activation.rule',
          ),
      isFalse,
    );
  });
}
