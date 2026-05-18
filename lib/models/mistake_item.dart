import 'dart:convert';

/// 错题记录，持久化到本地存储。
class MistakeItem {
  final String id; // "wuxing_generate_土_金"
  final String module;
  final String topic;
  final String questionText;
  final String sourceElement;
  final String correctAnswer;
  final String wrongAnswer;
  final String relationText;
  final String practiceStyle;
  final int wrongCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? explanation;
  final int? reactionMs;
  final bool? isHesitant;

  const MistakeItem({
    required this.id,
    required this.module,
    required this.topic,
    required this.questionText,
    required this.sourceElement,
    required this.correctAnswer,
    required this.wrongAnswer,
    required this.relationText,
    required this.practiceStyle,
    required this.wrongCount,
    required this.createdAt,
    required this.updatedAt,
    this.explanation,
    this.reactionMs,
    this.isHesitant,
  });

  MistakeItem copyWith({
    String? id,
    String? module,
    String? topic,
    String? questionText,
    String? sourceElement,
    String? correctAnswer,
    String? wrongAnswer,
    String? relationText,
    String? practiceStyle,
    int? wrongCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MistakeItem(
      id: id ?? this.id,
      module: module ?? this.module,
      topic: topic ?? this.topic,
      questionText: questionText ?? this.questionText,
      sourceElement: sourceElement ?? this.sourceElement,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      wrongAnswer: wrongAnswer ?? this.wrongAnswer,
      relationText: relationText ?? this.relationText,
      practiceStyle: practiceStyle ?? this.practiceStyle,
      wrongCount: wrongCount ?? this.wrongCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'topic': topic,
        'questionText': questionText,
        'sourceElement': sourceElement,
        'correctAnswer': correctAnswer,
        'wrongAnswer': wrongAnswer,
        'relationText': relationText,
        'practiceStyle': practiceStyle,
        'wrongCount': wrongCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (explanation != null) 'explanation': explanation,
        if (reactionMs != null) 'reactionMs': reactionMs,
        if (isHesitant != null) 'isHesitant': isHesitant,
      };

  factory MistakeItem.fromJson(Map<String, dynamic> json) => MistakeItem(
        id: json['id'] as String,
        module: json['module'] as String,
        topic: json['topic'] as String,
        questionText: json['questionText'] as String,
        sourceElement: json['sourceElement'] as String,
        correctAnswer: json['correctAnswer'] as String,
        wrongAnswer: json['wrongAnswer'] as String,
        relationText: json['relationText'] as String,
        practiceStyle: json['practiceStyle'] as String,
        wrongCount: json['wrongCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        explanation: json['explanation'] as String?,
        reactionMs: json['reactionMs'] as int?,
        isHesitant: json['isHesitant'] as bool?,
      );
}
