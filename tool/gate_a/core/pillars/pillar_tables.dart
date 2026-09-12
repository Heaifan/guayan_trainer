/// 四柱三张对照表（自 `pillars.dart` 拆出）。
///
/// 依据（与产品域无关，纯旁证用）：
/// - 月干 = 五虎遁（甲己之年丙作首）自寅月起；
/// - 时干 = 五鼠遁（甲己还加甲）自子时起，23:00 起为子时。
///
/// 表按 [TianGan.index] 对齐，索引即年干 / 日干序号。
library;

import 'package:guayan_trainer/domain/tian_gan.dart';

/// 五虎遁：年干 → 该年**寅月**的天干。索引与 [TianGan.index] 对齐。
const List<TianGan> yinMonthGanByYearGan = <TianGan>[
  TianGan.bing, // 甲
  TianGan.wu, // 乙
  TianGan.geng, // 丙
  TianGan.ren, // 丁
  TianGan.jia, // 戊
  TianGan.bing, // 己
  TianGan.wu, // 庚
  TianGan.geng, // 辛
  TianGan.ren, // 壬
  TianGan.jia, // 癸
];

/// 五鼠遁：日干 → 该日子时的天干。
const List<TianGan> ziHourGanByDayGan = <TianGan>[
  TianGan.jia, // 甲
  TianGan.bing, // 乙
  TianGan.wu, // 丙
  TianGan.geng, // 丁
  TianGan.ren, // 戊
  TianGan.jia, // 己
  TianGan.bing, // 庚
  TianGan.wu, // 辛
  TianGan.geng, // 壬
  TianGan.ren, // 癸
];
