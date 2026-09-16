library;
import '../core/rule_definition.dart';
import '../editor/custom_rule_service.dart';
import '../corpus/common_rule_corpus.dart';
import '../topics/topic_pack_composer.dart';
import '../packs/rule_pack.dart';
import '../packs/rule_pack_id.dart';
import '../governance/rule_resolver.dart';
import '../governance/resolved_rule_set.dart';

class RuntimeRuleSetAssembler {
  final CustomRuleService customRuleService;
  final List<RulePack> availableTopics;
  final Map<RulePackId, List<RuleDefinition>> topicRulesMap;

  const RuntimeRuleSetAssembler({
    required this.customRuleService,
    required this.availableTopics,
    required this.topicRulesMap,
  });

  ResolvedRuleSet assemble(List<String> selectedTopicIds) {
    final commonRules = CommonRuleCorpus.v1();
    final commonPack = CommonRuleCorpus.packV1(commonRules);

    final mergedCommon = customRuleService.getMergedRules(commonRules)
        .where((r) => r.namespace == 'common').toList();
    
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
