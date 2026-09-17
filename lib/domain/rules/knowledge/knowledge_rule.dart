import 'rule_variant.dart';

class KnowledgeRule {
  const KnowledgeRule({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.summary,
    required this.variants,
    this.primaryCategoryId,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String categoryId;
  final String summary;
  final List<RuleVariant> variants;
  final String? primaryCategoryId;
  final List<String> tags;

  KnowledgeRule copyWith({String? primaryCategoryId, List<String>? tags}) {
    return KnowledgeRule(
      id: id,
      name: name,
      categoryId: categoryId,
      summary: summary,
      variants: variants,
      primaryCategoryId: primaryCategoryId ?? this.primaryCategoryId,
      tags: tags ?? this.tags,
    );
  }
}
