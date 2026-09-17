library;
import '../core/rule_definition.dart';
import '../editor/custom_rule_service.dart';
import '../corpus/common_rule_corpus.dart';
import '../topics/topic_pack_composer.dart';
import '../packs/rule_pack.dart';
import '../packs/rule_pack_id.dart';
import '../governance/rule_resolver.dart';
import '../governance/resolved_rule_set.dart';
import '../packages/global_rule_pack_registry.dart';
import '../packages/rule_package_store.dart';
import '../library/effective_rule_selector.dart';
import '../library/rule_library_index.dart';

class RuntimeRuleSetAssembler {
  final CustomRuleService customRuleService;
  final List<RulePack> availableTopics;
  final Map<RulePackId, List<RuleDefinition>> topicRulesMap;
  final GlobalRulePackRegistry? globalRegistry;
  final RuleLibraryIndex? libraryIndex;

  const RuntimeRuleSetAssembler({
    required this.customRuleService,
    required this.availableTopics,
    required this.topicRulesMap,
    this.globalRegistry,
    this.libraryIndex,
  });

  ResolvedRuleSet assemble(List<String> selectedTopicIds) {
    final commonRules = CommonRuleCorpus.v1();
    final commonPack = CommonRuleCorpus.packV1(commonRules);

    final mergedCommon = customRuleService.getMergedRules(commonRules)
        .where((r) => r.namespace == 'common').toList();
    if (libraryIndex != null) {
      mergedCommon
        ..removeWhere((rule) => rule.origin.name == 'CUSTOM')
        ..addAll(selectEffectiveRules(
          customRuleService.store.getAll(),
          libraryIndex!,
        ));
    }
    for (final installed in
        globalRegistry?.enabledUserPacks ?? const <InstalledRulePack>[]) {
      final packageRules = libraryIndex == null
          ? installed.package.rules.where((rule) => rule.enabled).toList()
          : selectEffectiveRules(installed.package.rules, libraryIndex!);
      mergedCommon.addAll(packageRules);
    }
    
    final finalTopicRules = <RulePackId, List<RuleDefinition>>{};
    
    for (final pack in availableTopics) {
      if (selectedTopicIds.contains(pack.topicId)) {
        final sysRules = topicRulesMap[pack.packId] ?? [];
        final merged = customRuleService.getMergedRules(sysRules)
            .where((r) => r.namespace == 'topic.${pack.topicId}').toList();
        finalTopicRules[pack.packId] = merged;
      } else {
        finalTopicRules[pack.packId] = []; // isolate unselected
      }
    }

    final composed = RulePackComposer.compose(
      commonPack: commonPack,
      commonRules: mergedCommon,
      availableTopics: availableTopics,
      selectedTopicIds: selectedTopicIds,
      topicRules: finalTopicRules,
    );

    return RuleResolver.resolve(composed.composedRules);
  }
}
