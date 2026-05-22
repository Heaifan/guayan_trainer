enum PracticeDomain { wuxing, dizhi }

enum PracticeTopic {
  wuxingGenerate,
  wuxingControl,
  wuxingSelfCenter,
  wuxingState,
}

enum AnswerKind { wuxingElement, selfRelation, wuxingState, text }

enum PracticeStage { wheel, colorChoice, textChoice, relationChoice, stateChoice, linkMatch }

enum PracticeMode { normal, fallingBlock, linkMatch }

enum RelationEffectKind { heart, break_ }

enum HitEffectKind { heart, break_ }

enum FallingRuleKind {
  wuxingGenerate,
  wuxingControl,
  dizhiCombine,
  dizhiConflict,
}
