import 'rule_variant.dart';

class KnowledgeRule {
  const KnowledgeRule({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.summary,
    required this.variants,
  });

  final String id;
  final String name;
  final String categoryId;
  final String summary;
  final List<RuleVariant> variants;
}
