/// Gate A 时间文本工具：UTC ↔ 东八区挂钟、RFC3339、分钟/秒级偏移。
library;

/// 参考时间的记录精度。
enum TimePrecision {
  /// 来源（HKO）给出的分钟精度，秒位恒为 `:00`。
  minute,

  /// 按整分加减得到的分钟精度测试点。
  shiftedMinute,

  /// 秒级测试点（由分钟值 ±30 秒构造，**不代表来源精度**）。
  shiftedSecond,
}

/// 东八区（HKT / 北京时间）挂钟时间。
DateTime hktOf(DateTime utc) => utc.toUtc().add(const Duration(hours: 8));

/// RFC3339（UTC，带 Z）。
String rfc3339(DateTime utc) {
  final u = utc.toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}'
      'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
}

/// `YYYY-MM-DD HH:mm:ss`（用于专业软件输入）。
String wallClockText(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

/// `YYYY-MM-DD HH:mm:ss +08:00`。
String wallClockWithOffsetText(DateTime t) =>
    '${wallClockText(t)} +08:00';

/// 分钟精度标注文本。
String precisionLabel(TimePrecision p) => switch (p) {
  TimePrecision.minute => '来源精度（分钟）',
  TimePrecision.shiftedMinute => '整分偏移',
  TimePrecision.shiftedSecond => '秒级探测（非来源精度）',
};
