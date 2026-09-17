import '../../../domain/rules/core/rule_definition.dart';
import '../../../domain/rules/dsl/guayan_dsl_formatter.dart';
import '../../../domain/rules/dsl/guayan_rule_body.dart';
import 'rule_display_model.dart';

class RulePresentationMapper {
  static const _titles = <String, String>{
    'xun_kong': '旬空',
    'yue_po': '月破',
    'ri_po': '日破',
    'in_tomb': '入墓',
    'month_generate': '月生',
    'day_generate': '日生',
    'fu_mu': '父母',
    'guan_gui': '官鬼',
  };

  static RuleDisplayModel map(RuleDefinition rule) {
    final key = rule.ruleId.id.split('.').last;
    final title = _titles[key] ?? _titleFromId(rule) ?? rule.title;
    final category = _category(rule.categoryId, rule.ruleId.id);
    final description = _description(title, rule.description);
    final dsl = const GuayanDslFormatter().format(
      GuayanRuleBody(
        bindings: rule.bindings,
        condition: rule.condition,
        actions: rule.actions,
      ),
    );
    return RuleDisplayModel(
      title: title,
      categoryLabel: category,
      originLabel: rule.origin.name == 'SYSTEM' ? '系统规则' : '自定义规则',
      ruleId: rule.ruleId.id,
      version: rule.version.toString(),
      description: description,
      dsl: dsl,
      origin: rule.origin,
    );
  }

  static String? _titleFromId(RuleDefinition rule) {
    for (final entry in _titles.entries) {
      if (rule.ruleId.id.endsWith(entry.key)) return entry.value;
    }
    return null;
  }

  static String _category(String categoryId, String ruleId) {
    if (categoryId == 'state' || ruleId.contains('.state.')) return '状态';
    if (categoryId == 'relation' || ruleId.contains('.relation.')) return '关系';
    if (categoryId == 'exam') return '取象';
    return '其他';
  }

  static String _description(String title, String original) {
    if (title == '旬空') return '判断某爻是否处于旬空状态，影响其力量。';
    if (title == '月破') return '判断某爻是否受月破影响，主不利。';
    if (title == '日破') return '判断某爻是否受日破影响，主不利。';
    if (title == '入墓') return '判断某爻是否入墓，力量受限。';
    if (title == '月生') return '判断某爻是否得月令相生。';
    if (title == '日生') return '判断某爻是否得日辰相生。';
    if (title == '父母') return '判断规则对象是否属于父母关系。';
    if (title == '官鬼') return '判断规则对象是否属于官鬼关系。';
    return original;
  }
}
