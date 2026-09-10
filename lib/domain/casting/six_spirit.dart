/// 六神：按**日干**起例，自初爻向上依次安配。
///
/// 起例规则（固定）：
/// ```text
/// 甲乙 → 青龙    丙丁 → 朱雀    戊 → 勾陈
/// 己   → 螣蛇    庚辛 → 白虎    壬癸 → 玄武
/// ```
/// 自初爻起顺排，六爻恰好配满一轮六神。
library;

import '../tian_gan.dart';

/// 六神。
enum SixSpirit {
  qingLong('青龙'),
  zhuQue('朱雀'),
  gouChen('勾陈'),
  tengShe('螣蛇'),
  baiHu('白虎'),
  xuanWu('玄武');

  const SixSpirit(this.label);

  /// 中文名，如「青龙」。
  final String label;
}

/// 日干 → 初爻所起之神（索引与 [TianGan.index] 对齐）。
const List<SixSpirit> spiritStartByGan = [
  SixSpirit.qingLong, // 甲
  SixSpirit.qingLong, // 乙
  SixSpirit.zhuQue, // 丙
  SixSpirit.zhuQue, // 丁
  SixSpirit.gouChen, // 戊
  SixSpirit.tengShe, // 己
  SixSpirit.baiHu, // 庚
  SixSpirit.baiHu, // 辛
  SixSpirit.xuanWu, // 壬
  SixSpirit.xuanWu, // 癸
];

/// 按日干给出六爻六神（index 0 = 初爻，index 5 = 上爻）。
List<SixSpirit> sixSpiritsFor(TianGan dayGan) {
  final start = spiritStartByGan[dayGan.index].index;
  return [for (var i = 0; i < 6; i++) SixSpirit.values[(start + i) % 6]];
}
