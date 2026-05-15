import 'dart:math';

import '../data/dizhi_data.dart';
import '../data/relation_data.dart';
import '../data/wuxing_data.dart';
import '../models/training_question.dart';

enum TrainingMode {
  wuxing,
  dizhi,
  sixChong,
  sixHe,
  mixed,
  wuxingGenerate,
}

class QuestionGenerator {
  final Random _random = Random();

  List<TrainingQuestion> generateSession({
    required TrainingMode mode,
    int count = 10,
  }) {
    return List.generate(count, (_) {
      switch (mode) {
        case TrainingMode.wuxing:
          return _generateWuxingQuestion();
        case TrainingMode.wuxingGenerate:
          return _generatePureGenerateQuestion();
        case TrainingMode.dizhi:
          return _generateDizhiWuxingQuestion();
        case TrainingMode.sixChong:
          return _generateSixChongQuestion();
        case TrainingMode.sixHe:
          return _generateSixHeQuestion();
        case TrainingMode.mixed:
          return _generateMixedQuestion();
      }
    });
  }

  /// Pure "X生谁？" questions for wuxingGenerate mode.
  TrainingQuestion _generatePureGenerateQuestion() {
    final element = _pick(WuxingData.elements);
    final answer = WuxingData.generates[element]!;

    return TrainingQuestion(
      type: QuestionType.wuxingGenerate,
      prompt: '$element 生谁？',
      correctAnswer: answer,
      options: WuxingData.elements,
      knowledgeKey: '$element生$answer',
      explanation: _generateExplanation(element, answer),
      sourceElement: element,
      targetElement: answer,
      relationType: 'generate',
    );
  }

  String _generateExplanation(String from, String to) {
    const explanations = {
      '木火': '木燃则生火，所以木生火。',
      '火土': '火尽成灰，灰归于土，所以火生土。',
      '土金': '金藏于土，土中生金，所以土生金。',
      '金水': '金寒生水，金气凝水，所以金生水。',
      '水木': '水润生木，万木得水而生，所以水生木。',
    };
    return explanations['$from$to'] ?? '$from 生 $to。';
  }

  TrainingQuestion _generateMixedQuestion() {
    final generators = [
      _generateWuxingQuestion,
      _generateDizhiWuxingQuestion,
      _generateSixChongQuestion,
      _generateSixHeQuestion,
      _generateRelationJudgeQuestion,
    ];
    return generators[_random.nextInt(generators.length)]();
  }

  TrainingQuestion _generateWuxingQuestion() {
    final element = _pick(WuxingData.elements);
    final type = _random.nextInt(4);

    if (type == 0) {
      final answer = WuxingData.generates[element]!;
      return TrainingQuestion(
        type: QuestionType.wuxingGenerate,
        prompt: '$element 生谁？',
        correctAnswer: answer,
        options: _makeOptions(answer, WuxingData.elements),
        knowledgeKey: '$element生$answer',
        explanation: '$element 生 $answer。',
        sourceElement: element,
        targetElement: answer,
        relationType: 'generate',
      );
    }

    if (type == 1) {
      final answer = WuxingData.controls[element]!;
      return TrainingQuestion(
        type: QuestionType.wuxingControl,
        prompt: '$element 克谁？',
        correctAnswer: answer,
        options: _makeOptions(answer, WuxingData.elements),
        knowledgeKey: '$element克$answer',
        explanation: '$element 克 $answer。',
      );
    }

    if (type == 2) {
      final answer = WuxingData.getGeneratedBy(element)!;
      return TrainingQuestion(
        type: QuestionType.wuxingGeneratedBy,
        prompt: '谁来生 $element？',
        correctAnswer: answer,
        options: _makeOptions(answer, WuxingData.elements),
        knowledgeKey: '$answer生$element',
        explanation: '$answer 生 $element。',
      );
    }

    final answer = WuxingData.getControlledBy(element)!;
    return TrainingQuestion(
      type: QuestionType.wuxingControlledBy,
      prompt: '谁克$element？',
      correctAnswer: answer,
      options: _makeOptions(answer, WuxingData.elements),
      knowledgeKey: '$answer克$element',
      explanation: '$answer 克 $element。',
    );
  }

  TrainingQuestion _generateDizhiWuxingQuestion() {
    final branch = _pick(DizhiData.branches);
    return TrainingQuestion(
      type: QuestionType.dizhiWuxing,
      prompt: '${branch.name} 属什么五行？',
      correctAnswer: branch.wuxing,
      options: _makeOptions(branch.wuxing, WuxingData.elements),
      knowledgeKey: '${branch.name}${branch.wuxing}',
      explanation: '${branch.name} 为${branch.yinyang}${branch.wuxing}，方位${branch.direction}，对应${branch.month}。',
    );
  }

  TrainingQuestion _generateSixChongQuestion() {
    final branch = _pick(DizhiData.names);
    final answer = RelationData.getChongPartner(branch)!;

    return TrainingQuestion(
      type: QuestionType.sixChong,
      prompt: '$branch 的冲神是谁？',
      correctAnswer: answer,
      options: _makeOptions(answer, DizhiData.names),
      knowledgeKey: '$branch$answer冲',
      explanation: '$branch$answer冲。',
    );
  }

  TrainingQuestion _generateSixHeQuestion() {
    final branch = _pick(DizhiData.names);
    final answer = RelationData.getHePartner(branch)!;

    return TrainingQuestion(
      type: QuestionType.sixHe,
      prompt: '$branch 的合神是谁？',
      correctAnswer: answer,
      options: _makeOptions(answer, DizhiData.names),
      knowledgeKey: '$branch$answer合',
      explanation: '$branch$answer合。',
    );
  }

  TrainingQuestion _generateRelationJudgeQuestion() {
    final relationType = _random.nextBool() ? '六冲' : '六合';
    final pairMap = relationType == '六冲'
        ? RelationData.sixChong
        : RelationData.sixHe;

    final entry = _pick(pairMap.entries.toList());
    final a = entry.key;
    final b = entry.value;

    return TrainingQuestion(
      type: QuestionType.relationJudge,
      prompt: '$a$b 是什么关系？',
      correctAnswer: relationType,
      options: const ['六冲', '六合', '三合', '无特殊冲合'],
      knowledgeKey: '$a$b$relationType',
      explanation: '$a$b 为$relationType。',
    );
  }

  T _pick<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  List<String> _makeOptions(String answer, List<String> source, {int count = 4}) {
    final set = <String>{answer};

    while (set.length < count && set.length < source.length) {
      set.add(_pick(source));
    }

    final result = set.toList();
    result.shuffle(_random);
    return result;
  }
}
