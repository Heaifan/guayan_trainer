import 'practice_enums.dart';

class PracticeQuestion {
  final String id;
  final PracticeDomain domain;
  final PracticeTopic topic;
  final PracticeStage stage;
  final AnswerKind answerKind;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String? sourceElement;
  final String? targetElement;
  final String? selfElement;
  final String relationText;
  final String explanation;

  const PracticeQuestion({
    required this.id,
    required this.domain,
    required this.topic,
    required this.stage,
    required this.answerKind,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    this.sourceElement,
    this.targetElement,
    this.selfElement,
    required this.relationText,
    required this.explanation,
  });
}
