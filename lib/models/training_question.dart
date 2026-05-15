enum QuestionType {
  wuxingGenerate,
  wuxingControl,
  wuxingGeneratedBy,
  wuxingControlledBy,
  dizhiWuxing,
  sixChong,
  sixHe,
  relationJudge,
}

class TrainingQuestion {
  final QuestionType type;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String knowledgeKey;
  final String explanation;

  const TrainingQuestion({
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.knowledgeKey,
    required this.explanation,
  });
}
