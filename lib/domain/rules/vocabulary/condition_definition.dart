library;

enum VocabularyPolicy { open, closed }

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
  final List<String> operandKinds;
  final VocabularyPolicy? vocabularyPolicy;
}
