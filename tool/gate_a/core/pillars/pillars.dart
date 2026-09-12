/// 四柱纯函数（自 `pillars.dart` 拆出）：年/月/日/时干支的推导。
///
/// 依据：
/// - 年柱以**立春**换年（非正月初一），与月建同用十二「节」；
/// - 月干 = 五虎遁（甲己之年丙作首）自寅月起；
/// - 时干 = 五鼠遁（甲己还加甲）自子时起，23:00 起为子时。
///
/// 表在 `pillar_tables.dart`，`CaseFacts` 上的派生取值在 `case_pillars.dart`。
library;

import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

import 'pillar_tables.dart';

export 'pillar_tables.dart';

/// 数学取模（显式封装，便于自检）。
int mod(int a, int b) => ((a % b) + b) % b;

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
  final gan =
      TianGan.values[mod(yinMonthGanByYearGan[yGan.index].index + offset, 10)];
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
  final gan =
      TianGan.values[mod(ziHourGanByDayGan[dayGan.index].index + zhiIndex, 10)];
  return ganZhiText(gan, zhi);
}

/// 次日的日干（`(cycleIndex + 1) % 10`），供晚子时口径对照。
TianGan nextDayGan(TianGan dayGan) => TianGan.values[mod(dayGan.index + 1, 10)];
