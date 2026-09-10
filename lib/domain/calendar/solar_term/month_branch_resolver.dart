/// 月建解析：起卦瞬间 → 月支。
///
/// 边界语义（冻结，不接受其他解释）：
/// ```text
/// instant <  交节瞬间 → 上一个月建
/// instant >= 交节瞬间 → 新月建
/// ```
/// 月建**只由十二「节」切换**，与公历月份无关
/// （禁止「9 月 = 酉月」这类按公历月推断的写法）。
library;

import '../../di_zhi.dart';
import '../calendar_error.dart';
import 'solar_term.dart';
import 'solar_term_provider.dart';

/// 由节气表解出月建。
class MonthBranchResolver {
  const MonthBranchResolver(this.provider);

  final SolarTermProvider provider;

  /// 求 [instantUtc] 所属月建。
  ///
  /// 取「不晚于该瞬间的最后一个节」所开启的月建；
  /// 由于一月初尚未交小寒时仍属上一年大雪所开的子月，
  /// 需要同时看上一年的节。
  DiZhi resolve(DateTime instantUtc) {
    final instant = instantUtc.toUtc();
    final year = instant.year;

    // 缺哪一年就报哪一年；provider 负责抛 CalendarDataMissing。
    // 一月初未交小寒时仍属上一年大雪所开的子月，故必须能读到上一年。
    final boundaries = <SolarTerm>[
      for (final t in provider.termsOfYear(year - 1))
        if (t.id.isMonthStart) t,
      for (final t in provider.termsOfYear(year))
        if (t.id.isMonthStart) t,
    ]..sort((a, b) => a.instantUtc.compareTo(b.instantUtc));

    SolarTerm? latest;
    for (final t in boundaries) {
      if (!t.instantUtc.isAfter(instant)) {
        latest = t;
      } else {
        break;
      }
    }
    if (latest == null) {
      // provider 时区/数据异常导致找不到任何更早的节 —— 不允许猜测。
      throw CalendarDataMissing(year);
    }
    return latest.id.monthBranch!;
  }
}
