/// 一条节气记录：节气标识 + 精确 UTC 瞬间 + **来源精度**。
///
/// 真源是 **瞬间**，不是日期 —— 禁止用「2026-02-04 = 立春」这类
/// 只有日期没有时刻的数据，否则无法区分交节前 1 秒与交节后 1 秒。
///
/// 但瞬间的**秒位是否有意义**取决于来源精度：
/// `precision == minute` 时秒位恒为 `:00`，只表示「该分钟内交节」，
/// **不**表示「恰在第 0 秒交节」；此时该分钟内存在真实交节时刻。
/// `precision == second` 时秒位才是可信边界。
library;

import '../import/calendar_data_pack.dart';
import 'solar_term_id.dart';

/// 节气记录。
class SolarTerm {
  const SolarTerm({
    required this.id,
    required this.instantUtc,
    this.precision = TermPrecision.minute,
    this.sourceName,
    this.sourceReference,
  });

  /// 节气标识。
  final SolarTermId id;

  /// 交节瞬间（UTC）。
  final DateTime instantUtc;

  /// 该瞬间的记录精度（缺省 = 分钟级）。
  final TermPrecision precision;

  /// 逐节气来源覆盖：机构名；未覆盖时由年度 source 说明。
  final String? sourceName;

  /// 逐节气来源覆盖：引用。
  final String? sourceReference;

  /// 秒位是否具有实际意义。
  bool get isSecondPrecise => precision == TermPrecision.second;

  /// 该瞬间的 Unix 秒（便于数据表与断言）。
  int get epochSeconds => instantUtc.millisecondsSinceEpoch ~/ 1000;

  @override
  String toString() =>
      'SolarTerm(${id.label} @ ${instantUtc.toIso8601String()}, '
      '${precision.label}'
      '${sourceName == null ? '' : ', $sourceName'})';
}
