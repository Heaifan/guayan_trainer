/// 一条节气记录：节气标识 + 精确 UTC 瞬间。
///
/// 真源是 **瞬间**，不是日期 —— 禁止用「2026-02-04 = 立春」这类
/// 只有日期没有时刻的数据，否则无法区分交节前 1 秒与交节后 1 秒。
library;

import 'solar_term_id.dart';

/// 节气记录。
class SolarTerm {
  const SolarTerm({required this.id, required this.instantUtc});

  /// 节气标识。
  final SolarTermId id;

  /// 交节瞬间（UTC）。
  final DateTime instantUtc;

  /// 该瞬间的 Unix 秒（便于数据表与断言）。
  int get epochSeconds => instantUtc.millisecondsSinceEpoch ~/ 1000;

  @override
  String toString() =>
      'SolarTerm(${id.label} @ ${instantUtc.toIso8601String()})';
}
