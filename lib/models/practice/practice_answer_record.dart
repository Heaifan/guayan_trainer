import 'practice_enums.dart';
import 'practice_question.dart';

class PracticeAnswerRecord {
  final PracticeQuestion question;
  final String? selectedAnswer;
  final bool isCorrect;
  final bool isTimeout;
  final bool isHesitant;
  final int reactionMs;
  final DateTime answeredAt;

  const PracticeAnswerRecord({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.isTimeout,
    required this.isHesitant,
    required this.reactionMs,
    required this.answeredAt,
  });
}

class PracticeSessionResult {
  final List<PracticeAnswerRecord> records;
  final DateTime startedAt;
  final DateTime finishedAt;

  const PracticeSessionResult({
    required this.records,
    required this.startedAt,
    required this.finishedAt,
  });

  int get total => records.length;
  int get correctCount => records.where((r) => r.isCorrect).length;
  int get wrongCount => total - correctCount;
  double get accuracy => total == 0 ? 0 : correctCount / total;
  int get hesitantCount => records.where((r) => r.isHesitant).length;
  int get timeoutCount => records.where((r) => r.isTimeout).length;
  double get averageReactionMs =>
      records.isEmpty ? 0 : records.map((r) => r.reactionMs).reduce((a, b) => a + b) / records.length;
  int get totalDurationMs => finishedAt.difference(startedAt).inMilliseconds;

  Map<PracticeTopic, (int, int)> get topicStats {
    final map = <PracticeTopic, (int, int)>{};
    for (final r in records) {
      final (c, t) = map[r.question.topic] ?? (0, 0);
      map[r.question.topic] = (c + (r.isCorrect ? 1 : 0), t + 1);
    }
    return map;
  }
}
