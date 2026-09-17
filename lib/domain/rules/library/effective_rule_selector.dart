import '../core/rule_definition.dart';
import 'rule_library_index.dart';

List<RuleDefinition> selectEffectiveRules(
  Iterable<RuleDefinition> rules,
  RuleLibraryIndex index,
) => [
  for (final rule in rules)
    if (index.effectiveEnabled(rule.ruleId.id, ruleEnabled: rule.enabled)) rule,
];
