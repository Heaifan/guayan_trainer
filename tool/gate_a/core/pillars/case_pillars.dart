/// `CaseFacts` 上的四柱派生取值（自 `pillars.dart` 拆出）。
///
/// 这里**不含算法**：算法在 `pillars.dart`，本文件只负责
/// 「从卦例事实里取哪几个字段、喂给哪个函数」。
///
/// 刻意**不**由 `pillars.dart` 转出（虽然那样能少改一处 import）：
/// 那会让 `pillars.dart` ↔ `case_pillars.dart` 形成循环依赖，
/// 而 AGENTS.md 明令禁止循环依赖 —— 宁可多写一行 import。
library;

import 'package:guayan_trainer/domain/tian_gan.dart';

import '../../cases/derive.dart';
import 'pillars.dart';

/// 四柱旁证扩展：把 `CaseFacts` 与 `pillars.dart` 的纯函数连接起来。
extension CasePillars on CaseFacts {
  /// 年柱文本。
  String get yearPillarText => yearPillar(local.year, beforeLiChun);

  /// 月柱文本（五虎遁 + 月建）。
  String get monthPillarText => monthPillar(yearGanOf(), calendar.monthBranch);

  /// 时柱文本（按当日日干起例；23 时后即「晚子时」口径）。
  String get hourPillarText => hourPillar(calendar.day.gan, local.hour);

  /// 是否落在 23:00—23:59（时干口径存在流派差异的窗口）。
  bool get isLateZiHour => local.hour == 23;

  /// 时柱的另一种口径（按次日日干起例；仅供 23 时后对照）。
  String get hourPillarNextDayText =>
      hourPillar(nextDayGan(calendar.day.gan), local.hour);

  /// 年干（立春换年后的年干）。
  TianGan yearGanOf() => yearGan(local.year, beforeLiChun);
}
