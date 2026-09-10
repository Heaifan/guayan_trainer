/// 某一年**已校验通过**的历法数据（年度数据包的落地形态）。
///
/// 只有通过 [CalendarDataPackValidator] 的数据才会成为本类型，
/// CalendarDataStore 也只保存本类型 —— 引擎读到的永远是可信数据。
library;

import 'solar_term.dart';
import 'solar_term_id.dart';

/// 单年历法数据。
class CalendarYearData {
  const CalendarYearData({
    required this.calendarYear,
    required this.schemaVersion,
    required this.revision,
    required this.sourceName,
    required this.sourceReference,
    required this.generatedAt,
    required this.terms,
  });

  /// 数据包所属公历年。
  final int calendarYear;

  /// 数据包结构版本。
  final int schemaVersion;

  /// 同一年数据包的修订号（用于 NEW / UPDATE / SAME / DOWNGRADE 判定）。
  final int revision;

  /// 数据来源名称（如「香港天文台」）。
  final String sourceName;

  /// 数据来源引用（URL / 文献标识）。
  final String sourceReference;

  /// 数据生成时刻（UTC）。
  final DateTime generatedAt;

  /// 24 条节气，自小寒起、按交节瞬间升序。
  final List<SolarTerm> terms;

  /// 按节气标识取记录。
  SolarTerm termOf(SolarTermId id) => terms.firstWhere((t) => t.id == id);

  /// 「节」子集（12 条），供月建使用。
  List<SolarTerm> get monthStartTerms =>
      terms.where((t) => t.id.isMonthStart).toList();

  @override
  String toString() =>
      'CalendarYearData($calendarYear, '
      'rev$revision, ${terms.length} terms, $sourceName)';
}
