enum TrainingModule { wuxing, dizhi }

enum RelationType { generate, overcome, clash, combine }

class TrainingQuestion {
  final String id;
  final TrainingModule module;
  final RelationType relationType;
  final String prompt;
  final String answer;
  final List<String> options;
  final String explanation;
  final int difficulty;

  const TrainingQuestion({
    required this.id,
    required this.module,
    required this.relationType,
    required this.prompt,
    required this.answer,
    required this.options,
    required this.explanation,
    this.difficulty = 1,
  });
}
