/// 以我为中心：五行关系与旺相休囚死映射数据。

/// 以某个五行为「我」的五种关系映射。
const wuxingSelfCenterRelations = {
  '木': {
    '生我': '水',
    '我生': '火',
    '克我': '金',
    '我克': '土',
    '同我': '木',
  },
  '火': {
    '生我': '木',
    '我生': '土',
    '克我': '水',
    '我克': '金',
    '同我': '火',
  },
  '土': {
    '生我': '火',
    '我生': '金',
    '克我': '木',
    '我克': '水',
    '同我': '土',
  },
  '金': {
    '生我': '土',
    '我生': '水',
    '克我': '火',
    '我克': '木',
    '同我': '金',
  },
  '水': {
    '生我': '金',
    '我生': '木',
    '克我': '土',
    '我克': '火',
    '同我': '水',
  },
};

/// 五种关系 → 旺相休囚死状态。
const relationStateMap = {
  '同我': '旺',
  '生我': '相',
  '我生': '休',
  '克我': '囚',
  '我克': '死',
};

/// 旺相休囚死解释。
const stateDescriptions = {
  '旺': '同我者，同类帮身，力量最足。',
  '相': '生我者，得到生扶，力量增强。',
  '休': '我生者，我去生人，力量外泄。',
  '囚': '克我者，被人克制，受困受制。',
  '死': '我克者，我去克人，力量耗损。',
};

/// 旺相休囚死短标签。
const stateLabels = {
  '同我': '旺',
  '生我': '相',
  '我生': '休',
  '克我': '囚',
  '我克': '死',
};

/// 关系解释模板。
String relationExplanation(String self, String other, String relation) {
  switch (relation) {
    case '生我':
      return '$other 生 $self，故 $other 为生我。';
    case '我生':
      return '$self 生 $other，故 $other 为我生。';
    case '克我':
      return '$other 克 $self，故 $other 为克我。';
    case '我克':
      return '$self 克 $other，故 $other 为我克。';
    case '同我':
      return '$other 与 $self 同类，故为同我。';
    default:
      return '';
  }
}

/// 速查表行：我为某 → 旺相休囚死顺序。
const selfCenterRows = [
  '我为木：旺木，相水，休火，囚金，死土。',
  '我为火：旺火，相木，休土，囚水，死金。',
  '我为土：旺土，相火，休金，囚木，死水。',
  '我为金：旺金，相土，休水，囚火，死木。',
  '我为水：旺水，相金，休木，囚土，死火。',
];

/// 关系显示顺序。
const relationOrder = ['生我', '我生', '克我', '我克', '同我'];

/// 反查：以 self 为中心，other 是什么关系。
String relationOfOtherToSelf({required String self, required String other}) {
  final relations = wuxingSelfCenterRelations[self]!;
  return relations.entries.firstWhere((e) => e.value == other).key;
}

/// 反查：以 self 为中心，other 的状态（旺相休囚死）。
String stateOfOtherToSelf({required String self, required String other}) {
  final relation = relationOfOtherToSelf(self: self, other: other);
  return relationStateMap[relation]!;
}

/// 练习反馈解释。
String selfCenterExplanation({required String self, required String other}) {
  final relation = relationOfOtherToSelf(self: self, other: other);
  final state = relationStateMap[relation]!;
  switch (relation) {
    case '生我': return '$other 生 $self，所以 $other 为生我；生我对应：$state。';
    case '我生': return '$self 生 $other，所以 $other 为我生；我生对应：$state。';
    case '克我': return '$other 克 $self，所以 $other 为克我；克我对应：$state。';
    case '我克': return '$self 克 $other，所以 $other 为我克；我克对应：$state。';
    case '同我': return '$other 与 $self 同类，所以 $other 为同我；同我对应：$state。';
    default: return '';
  }
}

/// 练习关系摘要（例：金克木｜克我｜囚）。
String selfCenterRelationText({required String self, required String other}) {
  final relation = relationOfOtherToSelf(self: self, other: other);
  final state = relationStateMap[relation]!;
  return '$other$self｜$relation｜$state';
}

/// 以我为中心圆盘外圈坐标 (相对值 0~1)。
const selfCenterPositions = {
  '生我': (0.50, 0.20),
  '我生': (0.78, 0.50),
  '我克': (0.50, 0.80),
  '克我': (0.22, 0.50),
};

/// 圆盘关系解释文案（简洁版）。
String selfCenterRelationSentence(String self, String relation, String other) {
  switch (relation) {
    case '生我':
      return '$other 生 $self，得到生扶，力量增强。';
    case '我生':
      return '$self 生 $other，我去生人，力量外泄。';
    case '克我':
      return '$other 克 $self，被人克制，受困受制。';
    case '我克':
      return '$self 克 $other，我去克人，力量耗损。';
    case '同我':
      return '$other 与 $self 同类，同类帮身，力量最足。';
    default:
      return '';
  }
}
