import '../models/practice/practice_enums.dart';

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

String practiceStageLabel(PracticeStage stage) {
  switch (stage) {
    case PracticeStage.wheel:
      return '轮盘题';
    case PracticeStage.colorChoice:
      return '彩色单选';
    case PracticeStage.textChoice:
      return '文字单选';
    case PracticeStage.relationChoice:
      return '关系判断';
    case PracticeStage.stateChoice:
      return '旺衰判断';
  }
}

int practicePoolSize(PracticeTopic topic) {
  switch (topic) {
    case PracticeTopic.wuxingGenerate:
      return 5;
    case PracticeTopic.wuxingControl:
      return 5;
    case PracticeTopic.wuxingSelfCenter:
      return 25;
    case PracticeTopic.wuxingState:
      return 25;
  }
}

String formatMs(int ms) {
  return '${(ms / 1000).toStringAsFixed(1)} 秒';
}
