import '../../../domain/rules/knowledge/knowledge_rule.dart';

class KnowledgeRuleDisplayModel {
  const KnowledgeRuleDisplayModel({required this.rule});

  final KnowledgeRule rule;

  String get name => rule.name;
  String get knowledgeRuleId => rule.id;
  String get summary => rule.summary;
  int get executionRuleCount => rule.variants.fold(
    0,
    (count, variant) => count + variant.executionRules.length,
  );
  List<String> get variantNames =>
      rule.variants.map((variant) => variant.name).toSet().toList();
  String get searchText =>
      '$name $knowledgeRuleId ${variantNames.join(' ')}'.toLowerCase();
}
