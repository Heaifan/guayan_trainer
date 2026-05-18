import 'dart:math';

import '../../data/wuxing_data.dart';
import '../../data/wuxing_self_center_data.dart';
import '../../models/practice/practice_enums.dart';
import '../../models/practice/practice_question.dart';

class WuxingPracticeQuestionGenerator {
  final Random _random = Random();

  List<PracticeQuestion> generate({
    required Set<PracticeTopic> topics,
    int count = 12,
  }) {
    final pool = <PracticeQuestion>[];

    if (topics.contains(PracticeTopic.wuxingGenerate)) {
      pool.addAll(_generateGenerateQuestions());
    }
    if (topics.contains(PracticeTopic.wuxingControl)) {
      pool.addAll(_generateControlQuestions());
    }
    if (topics.contains(PracticeTopic.wuxingSelfCenter)) {
      pool.addAll(_generateSelfCenterQuestions());
    }
    if (topics.contains(PracticeTopic.wuxingState)) {
      pool.addAll(_generateStateQuestions());
    }

    pool.shuffle(_random);
    return pool.take(count).toList();
  }

  List<PracticeQuestion> _generateGenerateQuestions() {
    final elements = WuxingData.elements;
    return [
      for (final el in elements)
        PracticeQuestion(
          id: 'wuxing_generate_${el}_${WuxingData.generates[el]!}',
          domain: PracticeDomain.wuxing,
          topic: PracticeTopic.wuxingGenerate,
          stage: PracticeStage.textChoice,
          answerKind: AnswerKind.wuxingElement,
          prompt: '$el 生谁？',
          options: List.from(elements),
          correctAnswer: WuxingData.generates[el]!,
          sourceElement: el,
          targetElement: WuxingData.generates[el]!,
          relationText: '${el}生${WuxingData.generates[el]!}',
          explanation: '${el} 生 ${WuxingData.generates[el]!}。',
        ),
    ];
  }

  List<PracticeQuestion> _generateControlQuestions() {
    final elements = WuxingData.elements;
    return [
      for (final el in elements)
        PracticeQuestion(
          id: 'wuxing_control_${el}_${WuxingData.controls[el]!}',
          domain: PracticeDomain.wuxing,
          topic: PracticeTopic.wuxingControl,
          stage: PracticeStage.textChoice,
          answerKind: AnswerKind.wuxingElement,
          prompt: '$el 克谁？',
          options: List.from(elements),
          correctAnswer: WuxingData.controls[el]!,
          sourceElement: el,
          targetElement: WuxingData.controls[el]!,
          relationText: '${el}克${WuxingData.controls[el]!}',
          explanation: '${el} 克 ${WuxingData.controls[el]!}。',
        ),
    ];
  }

  List<PracticeQuestion> _generateSelfCenterQuestions() {
    final elements = WuxingData.elements;
    final questions = <PracticeQuestion>[];
    for (final self in elements) {
      final relations = wuxingSelfCenterRelations[self]!;
      for (final entry in relations.entries) {
        if (entry.key == '同我') continue;
        final other = entry.value;
        final rel = entry.key;
        questions.add(PracticeQuestion(
          id: 'self_center_relation_${self}_$other',
          domain: PracticeDomain.wuxing,
          topic: PracticeTopic.wuxingSelfCenter,
          stage: PracticeStage.relationChoice,
          answerKind: AnswerKind.selfRelation,
          prompt: '以$self为中心，$other是？',
          options: ['生我', '我生', '克我', '我克', '同我'],
          correctAnswer: rel,
          selfElement: self,
          targetElement: other,
          relationText: selfCenterRelationText(self: self, other: other),
          explanation: selfCenterExplanation(self: self, other: other),
        ));
      }
    }
    return questions;
  }

  List<PracticeQuestion> _generateStateQuestions() {
    final elements = WuxingData.elements;
    final questions = <PracticeQuestion>[];
    for (final self in elements) {
      final relations = wuxingSelfCenterRelations[self]!;
      for (final entry in relations.entries) {
        final other = entry.value;
        final state = relationStateMap[entry.key]!;
        questions.add(PracticeQuestion(
          id: 'self_center_state_${self}_$other',
          domain: PracticeDomain.wuxing,
          topic: PracticeTopic.wuxingState,
          stage: PracticeStage.stateChoice,
          answerKind: AnswerKind.wuxingState,
          prompt: '以$self为中心，$other为？',
          options: ['旺', '相', '休', '囚', '死'],
          correctAnswer: state,
          selfElement: self,
          targetElement: other,
          relationText: selfCenterRelationText(self: self, other: other),
          explanation: selfCenterExplanation(self: self, other: other),
        ));
      }
    }
    return questions;
  }
}
