import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';
import 'package:guayan_trainer/presentation/rules/presentation/knowledge_rule_presentation_mapper.dart';

void main() {
  test('maps the real catalog to ten KnowledgeRule display models', () {
    final models = KnowledgeRulePresentationMapper.mapAll(
      SystemKnowledgeRuleCatalog.rules,
    );

    expect(models, hasLength(10));
    expect(models.first.name, '旬空');
    expect(models.first.executionRuleCount, 6);
    expect(models.expand((model) => model.variantNames), contains('通用判法'));
    expect(models.expand((model) => model.variantNames), contains('考试取象'));
  });

  test('searches KnowledgeRule name, variant name, and KnowledgeRule id', () {
    final models = KnowledgeRulePresentationMapper.mapAll(
      SystemKnowledgeRuleCatalog.rules,
    );

    expect(
      KnowledgeRulePresentationMapper.search(
        models,
        '旬空',
      ).map((model) => model.name),
      containsAll(<String>['旬空', '父母旬空']),
    );
    expect(
      KnowledgeRulePresentationMapper.search(models, '考试取象'),
      hasLength(4),
    );
    expect(
      KnowledgeRulePresentationMapper.search(
        models,
        'knowledge.yue_po',
      ).single.name,
      '月破',
    );
  });
}
