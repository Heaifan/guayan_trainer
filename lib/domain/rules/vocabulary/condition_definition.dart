library;

enum VocabularyPolicy { open, closed }

enum OperandKind {
  bindingRef,
  literal,
  nayinIdLiteral,
  tagCategoryLiteral,
  shenShaIdLiteral,
}

class CanonicalConditionDefinition {
  const CanonicalConditionDefinition({
    required this.operatorId,
    required this.displayName,
    required this.operandCount,
    this.operandKinds = const [],
    this.vocabularyPolicy,
  });

  final String operatorId;
  final String displayName;
  final int operandCount;
  final List<OperandKind> operandKinds;
  final VocabularyPolicy? vocabularyPolicy;
}
