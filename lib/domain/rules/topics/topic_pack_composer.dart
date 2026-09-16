library;

import '../core/rule_definition.dart';
import '../packs/rule_pack.dart';
import '../packs/rule_pack_id.dart';

class CompositionResult {
  final List<RulePack> selectedPacks;
  final List<RuleDefinition> composedRules;
  CompositionResult(this.selectedPacks, this.composedRules);
}

class RulePackComposer {
  static CompositionResult compose({
    required RulePack commonPack,
    required List<RuleDefinition> commonRules,
    required List<RulePack> availableTopics,
    required List<String> selectedTopicIds,
    required Map<RulePackId, List<RuleDefinition>> topicRules,
  }) {
    final selectedPacks = <RulePack>[commonPack];
    final composedRules = <RuleDefinition>[...commonRules];
    final uniqueSelected = selectedTopicIds.toSet();

    for (final topicId in uniqueSelected) {
      final pack = availableTopics.where((p) => p.topicId == topicId).firstOrNull;
      if (pack == null) {
        throw StateError('Unknown packId: $topicId');
      }
      selectedPacks.add(pack);
      final rules = topicRules[pack.packId] ?? [];
      composedRules.addAll(rules);
    }

    return CompositionResult(selectedPacks, composedRules);
  }
}
