/// 年度历法数据包的**原始解析结果**（尚未校验）。
///
/// 字段一律可空：语法正确但语义缺失 / 类型错误的内容在此原样保留，
/// 由校验器一次性汇总全部问题，而不是在解析阶段就抛第一个错。
library;

/// 单条原始节气记录。
class CalendarDataPackTerm {
  const CalendarDataPackTerm({this.term, this.instantUtc});

  /// 节气机器名（如 `xiaoHan`）；未知值原样保留供校验器报错。
  final String? term;

  /// UTC 瞬间字符串（ISO-8601）；非法值原样保留供校验器报错。
  final String? instantUtc;
}

/// 年度数据包原始形态。
class CalendarDataPack {
  const CalendarDataPack({
    this.schemaVersion,
    this.calendarYear,
    this.timeStandard,
    this.revision,
    this.sourceName,
    this.sourceReference,
    this.generatedAt,
    this.terms = const <CalendarDataPackTerm>[],
  });

  final int? schemaVersion;
  final int? calendarYear;
  final String? timeStandard;
  final int? revision;
  final String? sourceName;
  final String? sourceReference;
  final String? generatedAt;

  /// 原始节气列表（顺序即文件顺序）。
  final List<CalendarDataPackTerm> terms;
}
