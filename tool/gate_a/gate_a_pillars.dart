/// 四柱（年/月/日/时）计算 —— **仅供 Gate A 人工对照旁证使用**。
///
/// 刻意放在 `tool/` 而非 `lib/`：R3 冻结范围只包含月建、日辰、旬空，
/// 四柱（年柱/月柱/时柱）尚未进入产品域。Gate A 需要它只为
/// 「专业软件显示的年月时柱是否与卦眼同一时刻」提供旁证，
/// 因此这里是最小、独立、可丢弃的重算，不冒充产品能力。
///
/// 依据：
/// - 年柱以**立春**换年（非正月初一），与月建同用十二「节」；
/// - 月干 = 五虎遁（甲己之年丙作首）自寅月起；
/// - 时干 = 五鼠遁（甲己还加甲）自子时起，23:00 起为子时。
library;

import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

/// 数学取模（显式封装，便于自检）。
int mod(int a, int b) => ((a % b) + b) % b;

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

/// 干支文本。
String ganZhiText(TianGan gan, DiZhi zhi) => '${gan.label}${zhi.label}';

/// 年柱干支（立春换年后的年干支）。
///
/// [beforeLiChun] 为 true 表示该时刻尚未交立春，仍属上一干支年。
TianGan yearGan(int gregorianYear, bool beforeLiChun) {
  final effective = beforeLiChun ? gregorianYear - 1 : gregorianYear;
  return TianGan.values[mod(effective - 4, 60) % 10];
}

/// 年柱文本。
String yearPillar(int gregorianYear, bool beforeLiChun) {
  final effective = beforeLiChun ? gregorianYear - 1 : gregorianYear;
  final index = mod(effective - 4, 60);
  return ganZhiText(TianGan.values[index % 10], DiZhi.values[index % 12]);
}

/// 月柱：由**年干**与**月建地支**推出月干（五虎遁）。
///
/// [monthBranch] 必须来自 MonthBranchResolver（十二「节」判定）。
String monthPillar(TianGan yGan, DiZhi monthBranch) {
  // 寅月为一年第 1 月；地支序上寅 = 2，故 offset = (zhiIndex - 2) mod 12。
  final offset = mod(monthBranch.index - DiZhi.yin.index, 12);
  final gan = TianGan.values[mod(
    yinMonthGanByYearGan[yGan.index].index + offset,
    10,
  )];
  return ganZhiText(gan, monthBranch);
}

/// 时柱：由**日干**与挂钟小时推出（五鼠遁；23:00 起为子时）。
///
/// 注意：23:00—23:59 的时干存在「用当日日干（晚子时）」与
/// 「用次日日干（早子时）」两种流派，本函数按**传入的日干**起例，
/// 不替业务层决定用哪一个 —— GA-4 会同时给出两种口径。
String hourPillar(TianGan dayGan, int hour) {
  final zhiIndex = mod((hour + 1) ~/ 2, 12);
  final zhi = DiZhi.values[zhiIndex];
  final gan = TianGan.values[mod(
    ziHourGanByDayGan[dayGan.index].index + zhiIndex,
    10,
  )];
  return ganZhiText(gan, zhi);
}

/// 次日的日干（`(cycleIndex + 1) % 10`），供晚子时口径对照。
TianGan nextDayGan(TianGan dayGan) =>
    TianGan.values[mod(dayGan.index + 1, 10)];
