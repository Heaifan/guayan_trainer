/// 自建尺子的**搜索锚点**与 HKT 文本（自 `oracle_residual.dart` 拆出）。
///
/// 锚点必须保证求根起点**尚未越过**目标黄经 —— 起点若已越过，
/// 牛顿迭代会直接跳到下一年的同名节气，残差会变成 ~365 天。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

/// 「节」的搜索锚点（UTC），保证起点尚未越过目标黄经。
const Map<SolarTermId, (int, int)> residualAnchor = <SolarTermId, (int, int)>{
  SolarTermId.xiaoHan: (1, 1),
  SolarTermId.liChun: (2, 1),
  SolarTermId.jingZhe: (3, 1),
  SolarTermId.qingMing: (3, 30),
  SolarTermId.liXia: (4, 30),
  SolarTermId.mangZhong: (5, 30),
  SolarTermId.xiaoShu: (6, 30),
  SolarTermId.liQiu: (8, 1),
  SolarTermId.baiLu: (8, 31),
  SolarTermId.hanLu: (9, 30),
  SolarTermId.liDong: (11, 1),
  SolarTermId.daXue: (12, 1),
};

String _two(int v) => v.toString().padLeft(2, '0');

/// 秒级 HKT 文本（`YYYY-MM-DD HH:mm:ss`，+08:00 挂钟）。
String hktText(DateTime utc) {
  final t = utc.add(const Duration(hours: 8));
  return '${t.year}-${_two(t.month)}-${_two(t.day)} '
      '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
}
