/// 六十四卦名表：以「上卦 → 下卦」为坐标。
///
/// 本表是卦名的唯一来源；禁止 UI 或引擎自行拼接卦名。
library;

import 'bagua.dart';

/// 六十四卦名（键 = 上卦/外卦，子键 = 下卦/内卦）。
const Map<Bagua, Map<Bagua, String>> hexagramNames = {
  Bagua.qian: {
    Bagua.qian: '乾为天',
    Bagua.dui: '天泽履',
    Bagua.li: '天火同人',
    Bagua.zhen: '天雷无妄',
    Bagua.xun: '天风姤',
    Bagua.kan: '天水讼',
    Bagua.gen: '天山遁',
    Bagua.kun: '天地否',
  },
  Bagua.dui: {
    Bagua.qian: '泽天夬',
    Bagua.dui: '兑为泽',
    Bagua.li: '泽火革',
    Bagua.zhen: '泽雷随',
    Bagua.xun: '泽风大过',
    Bagua.kan: '泽水困',
    Bagua.gen: '泽山咸',
    Bagua.kun: '泽地萃',
  },
  Bagua.li: {
    Bagua.qian: '火天大有',
    Bagua.dui: '火泽睽',
    Bagua.li: '离为火',
    Bagua.zhen: '火雷噬嗑',
    Bagua.xun: '火风鼎',
    Bagua.kan: '火水未济',
    Bagua.gen: '火山旅',
    Bagua.kun: '火地晋',
  },
  Bagua.zhen: {
    Bagua.qian: '雷天大壮',
    Bagua.dui: '雷泽归妹',
    Bagua.li: '雷火丰',
    Bagua.zhen: '震为雷',
    Bagua.xun: '雷风恒',
    Bagua.kan: '雷水解',
    Bagua.gen: '雷山小过',
    Bagua.kun: '雷地豫',
  },
  Bagua.xun: {
    Bagua.qian: '风天小畜',
    Bagua.dui: '风泽中孚',
    Bagua.li: '风火家人',
    Bagua.zhen: '风雷益',
    Bagua.xun: '巽为风',
    Bagua.kan: '风水涣',
    Bagua.gen: '风山渐',
    Bagua.kun: '风地观',
  },
  Bagua.kan: {
    Bagua.qian: '水天需',
    Bagua.dui: '水泽节',
    Bagua.li: '水火既济',
    Bagua.zhen: '水雷屯',
    Bagua.xun: '水风井',
    Bagua.kan: '坎为水',
    Bagua.gen: '水山蹇',
    Bagua.kun: '水地比',
  },
  Bagua.gen: {
    Bagua.qian: '山天大畜',
    Bagua.dui: '山泽损',
    Bagua.li: '山火贲',
    Bagua.zhen: '山雷颐',
    Bagua.xun: '山风蛊',
    Bagua.kan: '山水蒙',
    Bagua.gen: '艮为山',
    Bagua.kun: '山地剥',
  },
  Bagua.kun: {
    Bagua.qian: '地天泰',
    Bagua.dui: '地泽临',
    Bagua.li: '地火明夷',
    Bagua.zhen: '地雷复',
    Bagua.xun: '地风升',
    Bagua.kan: '地水师',
    Bagua.gen: '地山谦',
    Bagua.kun: '坤为地',
  },
};

/// 查卦名；坐标非法抛异常（表必须完整覆盖 8×8）。
String hexagramNameOf(Bagua upper, Bagua lower) {
  final byLower = hexagramNames[upper];
  final name = byLower?[lower];
  if (name == null) {
    throw StateError('六十四卦表缺失：上卦 $upper / 下卦 $lower');
  }
  return name;
}
