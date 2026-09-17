import '../../../domain/rules/knowledge/knowledge_rule.dart';
import 'knowledge_rule_display_model.dart';

class KnowledgeRulePresentationMapper {
  static List<KnowledgeRuleDisplayModel> mapAll(List<KnowledgeRule> rules) =>
      rules.map((rule) => KnowledgeRuleDisplayModel(rule: rule)).toList();

  static List<KnowledgeRuleDisplayModel> search(
    List<KnowledgeRuleDisplayModel> models,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return models;
    return models
        .where((model) => model.searchText.contains(normalized))
        .toList();
  }
}
