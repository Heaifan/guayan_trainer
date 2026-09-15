library;

import '../core/rule_definition.dart';
import '../core/rule_origin.dart';
import '../core/rule_version.dart';
import '../packs/rule_pack.dart';
import '../packs/rule_pack_id.dart';
import '../packs/rule_pack_scope.dart';
import 'common_rule_factory.dart';

class CommonRuleCorpus {
  static List<RuleDefinition> v1() {
    final rules = <RuleDefinition>[];
    for (int i = 1; i <= 6; i++) {
      rules.addAll(CommonRuleFactory.buildLineRules(i));
    }
    return rules;
  }

  static RulePack packV1(List<RuleDefinition> rules) {
    return RulePack(
      packId: RulePackId('common'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.SYSTEM,
      scope: RulePackScope.COMMON,
      title: 'Common Base Rules',
      ruleIds: rules.map((r) => r.ruleId).toList(),
    );
  }
}
