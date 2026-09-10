/// 本地历法数据仓储边界。
///
/// 接口与项目既有仓储一致（见 `services/draft/draft_repository.dart`）：
/// 抽象接口 + 内存实现 + `Future` 签名。
/// 后续替换为文件 / SQLite 实现时，CalendarEngine 与导入器均无需改动。
library;

import '../solar_term/calendar_year_data.dart';

/// 历法数据仓储。
abstract class CalendarDataStore {
  /// 保存（或替换）某年数据。调用方必须保证 [data] 已通过校验。
  Future<void> saveYear(CalendarYearData data);

  /// 读取某年数据；未安装返回 null。
  Future<CalendarYearData?> loadYear(int year);

  /// 某年是否已安装。
  Future<bool> hasYear(int year);

  /// 已安装年份（升序）。
  Future<List<int>> installedYears();
}

/// 内存实现：本轮打通边界与原子性语义，不做真实持久化。
class InMemoryCalendarDataStore implements CalendarDataStore {
  final Map<int, CalendarYearData> _years = <int, CalendarYearData>{};

  @override
  Future<void> saveYear(CalendarYearData data) async {
    _years[data.calendarYear] = data;
  }

  @override
  Future<CalendarYearData?> loadYear(int year) async => _years[year];

  @override
  Future<bool> hasYear(int year) async => _years.containsKey(year);

  @override
  Future<List<int>> installedYears() async {
    final years = _years.keys.toList()..sort();
    return years;
  }
}
