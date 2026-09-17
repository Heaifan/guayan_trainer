import '../vocabulary/nayin_catalog.dart';

/// Closed value vocabularies used by the rule editor.
/// Stable IDs remain in AST; normal UI consumes display names only.
class RuleValueCatalog {
  static const stems = <String>[
    '甲',
    '乙',
    '丙',
    '丁',
    '戊',
    '己',
    '庚',
    '辛',
    '壬',
    '癸',
  ];
  static const branches = <String>[
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥',
  ];
  static const elements = <String>['木', '火', '土', '金', '水'];
  static const structures = <String>[
    'sanHe.木',
    'sanHe.火',
    'sanHe.金',
    'sanHe.水',
  ];
  static const sixSpirits = <String>[
    'spirit.qing_long',
    'spirit.zhu_que',
    'spirit.gou_chen',
    'spirit.teng_she',
    'spirit.bai_hu',
    'spirit.xuan_wu',
  ];

  static const sixRelatives = <String>[
    'relative.parent',
    'relative.brother',
    'relative.child',
    'relative.wife',
    'relative.officer',
  ];

  static List<String> get naYin =>
      NaYinCatalog.all.map((entry) => entry.id.value).toList(growable: false);

  static String display(String id) {
    const names = {
      'relative.parent': '父母',
      'relative.brother': '兄弟',
      'relative.sibling': '兄弟',
      'relative.child': '子孙',
      'relative.wife': '妻财',
      'relative.spouse': '妻财',
      'relative.officer': '官鬼',
      'spirit.qing_long': '青龙',
      'spirit.zhu_que': '朱雀',
      'spirit.gou_chen': '勾陈',
      'spirit.teng_she': '螣蛇',
      'spirit.bai_hu': '白虎',
      'spirit.xuan_wu': '玄武',
    };
    final direct = names[id];
    if (direct != null) return direct;
    for (final entry in NaYinCatalog.all) {
      if (entry.id.value == id) return entry.name;
    }
    return id;
  }
}
