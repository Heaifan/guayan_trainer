enum QuestionType {
  wuxingGenerate,
  wuxingControl,
  wuxingGeneratedBy,
  wuxingControlledBy,
  dizhiWuxing,
  sixChong,
  sixHe,
  relationJudge,
  wuxingSelfCenter,
}

class TrainingQuestion {
  final QuestionType type;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String knowledgeKey;
  final String explanation;
  final String? sourceElement;
  final String? targetElement;
  final String? relationType;

  const TrainingQuestion({
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.knowledgeKey,
    required this.explanation,
    this.sourceElement,
    this.targetElement,
    this.relationType,
  });
}
