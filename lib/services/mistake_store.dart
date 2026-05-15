class MistakeRecord {
  final String knowledgeKey;
  final String explanation;
  int wrongCount;
  int slowCount;
  int correctInReview;

  MistakeRecord({
    required this.knowledgeKey,
    required this.explanation,
    this.wrongCount = 0,
    this.slowCount = 0,
    this.correctInReview = 0,
  });
}

class MistakeStore {
  MistakeStore._();

  static final MistakeStore instance = MistakeStore._();

  final Map<String, MistakeRecord> _records = {};

  List<MistakeRecord> get records => _records.values.toList();

  void markWrong({
    required String knowledgeKey,
    required String explanation,
  }) {
    final record = _records.putIfAbsent(
      knowledgeKey,
      () => MistakeRecord(
        knowledgeKey: knowledgeKey,
        explanation: explanation,
      ),
    );

    record.wrongCount += 1;
    record.correctInReview = 0;
  }

  void markSlow({
    required String knowledgeKey,
    required String explanation,
  }) {
    final record = _records.putIfAbsent(
      knowledgeKey,
      () => MistakeRecord(
        knowledgeKey: knowledgeKey,
        explanation: explanation,
      ),
    );

    record.slowCount += 1;
  }

  void markReviewCorrect(String knowledgeKey) {
    final record = _records[knowledgeKey];
    if (record == null) return;

    record.correctInReview += 1;

    if (record.correctInReview >= 2) {
      _records.remove(knowledgeKey);
    }
  }

  void clear() {
    _records.clear();
  }
}
