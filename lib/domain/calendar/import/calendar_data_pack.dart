/// 年度历法数据包的**原始解析结果**（尚未校验）。
///
/// 字段一律可空：语法正确但语义缺失 / 类型错误的内容在此原样保留，
/// 由校验器一次性汇总全部问题，而不是在解析阶段就抛第一个错。
library;

/// 节气黄经数值的记录精度（schemaVersion 2 起可用）。
///
/// 这是**如实记录来源精度**的字段，不是计算精度：
/// 官方若只发布到分钟，`instantUtc` 的秒位恒为 `:00`，
/// 但那只表示「该分钟内交节」，**不**表示「恰在第 0 秒交节」。
enum TermPrecision {
  /// 来源只精确到分钟；`instantUtc` 的秒位为 `:00`。
  minute('minute'),

  /// 来源给出秒级瞬间；`instantUtc` 的秒位有实际意义。
  second('second');

  const TermPrecision(this.label);

  /// 数据包中的文本值。
  final String label;

  /// 解析文本值；未知值返回 null（交由校验器报错，不在此抛异常）。
  static TermPrecision? tryParse(String? text) {
    if (text == null) return null;
    for (final p in TermPrecision.values) {
      if (p.label == text) return p;
    }
    return null;
  }
}

/// 单条原始节气记录。
class CalendarDataPackTerm {
  const CalendarDataPackTerm({
    this.term,
    this.instantUtc,
    this.precision,
    this.sourceName,
    this.sourceReference,
    this.sourceNote,
    this.hasSourceOverride = false,
    this.hasPrecisionKey = false,
  });

  /// 节气机器名（如 `xiaoHan`）；未知值原样保留供校验器报错。
  final String? term;

  /// UTC 瞬间字符串（ISO-8601）；非法值原样保留供校验器报错。
  final String? instantUtc;

  /// 记录精度文本（如 `minute` / `second`）；缺省或未知值原样保留供校验器报错。
  final String? precision;

  /// 逐节气来源覆盖：机构名。未覆盖时沿用年度 source。
  final String? sourceName;

  /// 逐节气来源覆盖：引用（URL / 文献标识）。
  final String? sourceReference;

  /// 逐节气来源覆盖：说明。
  final String? sourceNote;

  /// 是否出现过 `sourceOverride` 字段（用于区分「未提供」与「提供了但为空」）。
  final bool hasSourceOverride;

  /// 是否出现过 `precision` 字段（用于区分「未提供」与「提供了但类型错误」）。
  final bool hasPrecisionKey;
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
