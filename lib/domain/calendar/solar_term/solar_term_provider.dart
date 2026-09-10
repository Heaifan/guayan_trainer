/// 节气数据来源抽象。
///
/// 依赖方向被刻意固定为：
/// ```text
/// MonthBranchResolver → SolarTermProvider → TableSolarTermProvider → 内嵌精确表
/// ```
/// 上层只依赖本接口；未来若要换成 `AstronomicalSolarTermProvider`，
/// 月建解析、四柱、神煞等消费者一律无需改动。
library;

import 'solar_term.dart';

/// 节气数据提供者。
abstract interface class SolarTermProvider {
  /// 支持范围下界公历年（含）。
  int get minYear;

  /// 支持范围上界公历年（含）。
  int get maxYear;

  /// 取某公历年的 24 节气，自小寒起、按交节瞬间升序。
  ///
  /// 超出 [minYear]..[maxYear] 必须抛 `UnsupportedCalendarYear`，
  /// **禁止静默降级到近似算法**。
  List<SolarTerm> termsOfYear(int year);
}
