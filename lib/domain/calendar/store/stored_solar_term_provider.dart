/// 由 [CalendarDataStore] 提供节气数据的 [SolarTermProvider]。
///
/// 依赖链（任务书 §18）：
/// ```text
/// CalendarEngine → SolarTermProvider → StoredSolarTermProvider → CalendarDataStore
/// ```
/// 仓储读取是异步的，而排盘引擎必须同步 —— 因此在 App 启动时
/// **异步装载一次快照**，此后全部同步读取，引擎保持纯同步。
library;

import '../calendar_error.dart';
import '../solar_term/calendar_year_data.dart';
import '../solar_term/solar_term.dart';
import '../solar_term/solar_term_provider.dart';
import 'calendar_data_store.dart';

/// 基于仓储快照的节气提供者。
class StoredSolarTermProvider implements SolarTermProvider {
  StoredSolarTermProvider._(this._years)
    : minYear = _years.keys.reduce((a, b) => a < b ? a : b),
      maxYear = _years.keys.reduce((a, b) => a > b ? a : b);

  final Map<int, CalendarYearData> _years;

  @override
  final int minYear;

  @override
  final int maxYear;

  /// 从仓储装载快照；没有任何已安装年份时抛 [StateError]。
  static Future<StoredSolarTermProvider> load(CalendarDataStore store) async {
    final years = await store.installedYears();
    if (years.isEmpty) {
      throw StateError('历法数据仓储为空：至少需要安装一年数据才能排盘');
    }
    final map = <int, CalendarYearData>{};
    for (final year in years) {
      final data = await store.loadYear(year);
      if (data != null) map[year] = data;
    }
    return StoredSolarTermProvider._(map);
  }

  /// 已装载的年份（升序）。
  List<int> get installedYears => _years.keys.toList()..sort();

  @override
  List<SolarTerm> termsOfYear(int year) {
    final data = _years[year];
    if (data == null) {
      // 未安装年份：明确失败，绝不近似补算。
      throw CalendarDataMissing(year);
    }
    return List<SolarTerm>.unmodifiable(data.terms);
  }
}
