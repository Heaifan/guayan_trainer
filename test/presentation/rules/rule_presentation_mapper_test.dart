import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/presentation/rules/presentation/rule_presentation_mapper.dart';

void main() {
  test('maps common xun kong to Chinese display metadata', () {
    final rule = CommonRuleCorpus.v1().first;
    final display = RulePresentationMapper.map(rule);

    expect(display.title, '旬空');
    expect(display.categoryLabel, '状态');
    expect(display.ruleId, 'common.line.1.xun_kong');
    expect(display.description, contains('旬空'));
    expect(display.dsl, contains('若'));
  });

  test('keeps technical identity while mapping relation category', () {
    final rule = CommonRuleCorpus.v1().firstWhere(
      (r) => r.ruleId.id.endsWith('month_generate'),
    );
    final display = RulePresentationMapper.map(rule);

    expect(display.title, '月生');
    expect(display.categoryLabel, '关系');
    expect(display.ruleId, rule.ruleId.id);
    expect(display.originLabel, '系统规则');
  });

  test('falls back safely for an unknown rule id', () {
    final source = CommonRuleCorpus.v1().first;
    final rule = RuleDefinition(
      ruleId: RuleId('future.rule'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.SYSTEM,
      namespace: 'future',
      categoryId: 'future',
      stage: RuleStage.tag,
      title: 'Unknown title',
      description: source.description,
      provenance: source.provenance,
      bindings: source.bindings,
      condition: source.condition,
      actions: source.actions,
    );
    final display = RulePresentationMapper.map(rule);

    expect(display.title, 'Unknown title');
    expect(display.categoryLabel, '其他');
  });
}
