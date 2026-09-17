import '../core/rule_definition.dart';
import '../corpus/common_rule_corpus.dart';
import '../topics/exam/exam_rule_corpus.dart';
import 'execution_rule_ref.dart';
import 'knowledge_rule.dart';
import 'knowledge_rule_catalog_coverage.dart';
import 'knowledge_rule_catalog_validator.dart';
import 'knowledge_rule_category.dart';
import 'rule_variant.dart';

class SystemKnowledgeRuleCatalog {
  static final List<RuleDefinition> _commonRules = CommonRuleCorpus.v1();
  static final List<RuleDefinition> _examRules = ExamRuleCorpus.v1();
  static final List<RuleDefinition> systemExecutionRules = [
    ..._commonRules,
    ..._examRules,
  ];

  static final List<KnowledgeRule> rules = [
    _common(
      'xun_kong',
      '旬空',
      KnowledgeRuleCategory.voidTombGrowth,
      '判断某爻是否处于旬空状态。',
      'knowledge.category.state',
      ['旬空', '空墓', '状态'],
    ),
    _common(
      'yue_po',
      '月破',
      KnowledgeRuleCategory.voidTombGrowth,
      '判断某爻是否受月破影响。',
      'knowledge.category.calendar_influence',
      ['月', '月建', '破', '时令'],
    ),
    _common(
      'ri_po',
      '日破',
      KnowledgeRuleCategory.voidTombGrowth,
      '判断某爻是否受日破影响。',
      'knowledge.category.calendar_influence',
      ['日', '日辰', '破', '时令'],
    ),
    _common(
      'in_tomb',
      '入墓',
      KnowledgeRuleCategory.voidTombGrowth,
      '判断某爻是否入墓。',
      'knowledge.category.state',
      ['墓', '入墓', '空墓', '状态'],
    ),
    _common(
      'month_generate',
      '月生',
      KnowledgeRuleCategory.monthDayStrength,
      '判断某爻是否得月令相生。',
      'knowledge.category.calendar_influence',
      ['月', '月建', '生', '时令'],
    ),
    _common(
      'day_generate',
      '日生',
      KnowledgeRuleCategory.monthDayStrength,
      '判断某爻是否得日辰相生。',
      'knowledge.category.calendar_influence',
      ['日', '日辰', '生', '时令'],
    ),
    _exam('fu_mu', '父母', '判断规则对象是否属于父母关系。', 'role.fu_mu', ['父母', '六亲', '考试']),
    _exam('guan_gui', '官鬼', '判断规则对象是否属于官鬼关系。', 'role.guan_gui', [
      '官鬼',
      '六亲',
      '考试',
    ]),
    _exam('fu_mu_xun_kong', '父母旬空', '判断父母爻是否同时处于旬空。', 'state.fu_mu_xun_kong', [
      '父母',
      '六亲',
      '旬空',
      '状态',
      '考试',
      '组合规则',
    ]),
    _exam(
      'fu_mu_month_generate',
      '父母月生',
      '判断父母爻是否得月令相生。',
      'relation.fu_mu_month_generate',
      ['父母', '六亲', '月生', '月', '考试', '组合规则'],
    ),
  ];

  static KnowledgeRule _common(
    String suffix,
    String name,
    String category,
    String summary,
    String primaryCategoryId,
    List<String> tags,
  ) {
    return KnowledgeRule(
      id: 'knowledge.$suffix',
      name: name,
      categoryId: category,
      summary: summary,
      primaryCategoryId: primaryCategoryId,
      tags: tags,
      variants: [
        RuleVariant(
          id: 'variant.$suffix.common',
          knowledgeRuleId: 'knowledge.$suffix',
          name: '通用判法',
          origin: 'system',
          version: '1.0.0',
          executionRules: _lineRefs('common.line', suffix),
        ),
      ],
    );
  }

  static KnowledgeRule _exam(
    String suffix,
    String name,
    String summary,
    String executionSuffix,
    List<String> tags,
  ) {
    return KnowledgeRule(
      id: 'knowledge.$suffix',
      name: name,
      categoryId: KnowledgeRuleCategory.other,
      summary: summary,
      primaryCategoryId: 'knowledge.category.six_relatives',
      tags: tags,
      variants: [
        RuleVariant(
          id: 'variant.$suffix.exam',
          knowledgeRuleId: 'knowledge.$suffix',
          name: '考试取象',
          origin: 'system',
          version: '1.0.0',
          executionRules: _lineRefs('exam.line', executionSuffix),
        ),
      ],
    );
  }

  static List<ExecutionRuleRef> _lineRefs(String prefix, String suffix) {
    const names = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    return [
      for (var index = 0; index < names.length; index++)
        ExecutionRuleRef(
          ruleId: '$prefix.${index + 1}.$suffix',
          displayName: names[index],
          order: index + 1,
        ),
    ];
  }

  static KnowledgeRuleCatalogCoverage validateCoverage() {
    final issues = KnowledgeRuleCatalogValidator.validate(
      rules,
      systemExecutionRules.map((rule) => rule.ruleId.id).toList(),
    );
    final mapped = rules
        .expand((rule) => rule.variants)
        .expand((variant) => variant.executionRules)
        .map((ref) => ref.ruleId)
        .toSet();
    final systemIds = systemExecutionRules
        .map((rule) => rule.ruleId.id)
        .toSet();
    return KnowledgeRuleCatalogCoverage(
      systemExecutionRuleCount: systemIds.length,
      mappedExecutionRuleCount: mapped.length,
      orphanExecutionRuleIds: systemIds.difference(mapped).toList(),
      validationIssues: issues,
    );
  }
}
