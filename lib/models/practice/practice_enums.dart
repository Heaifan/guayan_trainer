enum PracticeDomain { wuxing, dizhi }

enum PracticeTopic {
  wuxingGenerate,
  wuxingControl,
  wuxingSelfCenter,
  wuxingState,
}

enum AnswerKind { wuxingElement, selfRelation, wuxingState, text }

enum PracticeStage { wheel, colorChoice, textChoice, relationChoice, stateChoice }

enum PracticeMode { normal }

String practiceTopicLabel(PracticeTopic topic) {
  switch (topic) {
    case PracticeTopic.wuxingGenerate:
      return '五行相生';
    case PracticeTopic.wuxingControl:
      return '五行相克';
    case PracticeTopic.wuxingSelfCenter:
      return '以我为中心';
    case PracticeTopic.wuxingState:
      return '旺相休囚死';
  }
}
