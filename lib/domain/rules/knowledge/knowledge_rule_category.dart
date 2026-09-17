class KnowledgeRuleCategory {
  static const monthDayStrength = 'monthDayStrength';
  static const voidTombGrowth = 'voidTombGrowth';
  static const generationControl = 'generationControl';
  static const combineClashPunishHarm = 'combineClashPunishHarm';
  static const movingChanging = 'movingChanging';
  static const flyingHidden = 'flyingHidden';
  static const sixSpirits = 'sixSpirits';
  static const spiritStars = 'spiritStars';
  static const nayin = 'nayin';
  static const other = 'other';

  static const ids = <String>{
    monthDayStrength,
    voidTombGrowth,
    generationControl,
    combineClashPunishHarm,
    movingChanging,
    flyingHidden,
    sixSpirits,
    spiritStars,
    nayin,
    other,
  };

  static const names = <String, String>{
    monthDayStrength: '月日旺衰',
    voidTombGrowth: '空墓绝生',
    generationControl: '生克制化',
    combineClashPunishHarm: '合冲刑害',
    movingChanging: '动变',
    flyingHidden: '飞伏',
    sixSpirits: '六神',
    spiritStars: '神煞',
    nayin: '纳音',
    other: '其他',
  };

  const KnowledgeRuleCategory._();
}
