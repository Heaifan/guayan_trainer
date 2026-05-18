import 'training_question.dart';

class QuestionAnswerResult {
  final TrainingQuestion question;
  final String selectedAnswer;
  final bool isCorrect;
  final int milliseconds;
  final String? practiceStyle;

  const QuestionAnswerResult({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.milliseconds,
    this.practiceStyle,
  });
}

class TrainingSessionResult {
  final List<QuestionAnswerResult> results;

  const TrainingSessionResult(this.results);

  int get total => results.length;

  int get correctCount => results.where((e) => e.isCorrect).length;

  int get wrongCount => total - correctCount;

  double get accuracy {
    if (total == 0) return 0;
    return correctCount / total;
  }

  List<QuestionAnswerResult> get wrongResults {
    return results.where((e) => !e.isCorrect).toList();
  }

  List<QuestionAnswerResult> get slowResults {
    return results.where((e) => e.isCorrect && e.milliseconds >= 4000).toList();
  }

  /// 按阶段统计：{ 'wheel': (correct, total), 'colorChoice': ..., 'textChoice': ... }
  Map<String, (int, int)> get stageStats {
    final map = <String, (int, int)>{};
    for (final r in results) {
      final style = r.practiceStyle ?? 'unknown';
      final (c, t) = map[style] ?? (0, 0);
      map[style] = (c + (r.isCorrect ? 1 : 0), t + 1);
    }
    return map;
  }
}
