/// HKO vs NAOJ 交叉核验：数据行与装配（CLI 见 `cross_source.dart`）。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import '../data/hko_source.dart';
import '../data/naoj_source.dart';

String _two(int v) => v.toString().padLeft(2, '0');

/// `YYYY-MM-DD HH:mm` 文本。
String ymdhm(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

/// 单条交叉核验结果。
class CrossSourceRow {
  const CrossSourceRow({
    required this.term,
    required this.hkoHkt,
    required this.naojJst,
    required this.naojHkt,
  });

  final SolarTermId term;

  /// HKO 官方 XML 公布值（HKT 挂钟）。
  final DateTime hkoHkt;

  /// NAOJ 公布值（JST 挂钟）。
  final NaojTerm naojJst;

  /// NAOJ 值换算到 HKT。
  final DateTime naojHkt;

  /// NAOJ 原始公布挂钟（JST），供展示。
  DateTime get naojJstWallClock => DateTime.utc(
    2026,
    naojJst.month,
    naojJst.day,
    naojJst.hour,
    naojJst.minute,
  );

  bool get sameDate =>
      hkoHkt.year == naojHkt.year &&
      hkoHkt.month == naojHkt.month &&
      hkoHkt.day == naojHkt.day;

  bool get sameMinute =>
      sameDate && hkoHkt.hour == naojHkt.hour && hkoHkt.minute == naojHkt.minute;

  /// 分钟差（HKO − NAOJ），单位分钟。
  int get minuteDelta => hkoHkt.difference(naojHkt).inMinutes;
}

/// 构建 24 条交叉核验行（HKO 官方 XML vs NAOJ 官方页面）。
List<CrossSourceRow> buildCrossSourceRows() {
  final hko = loadHkoFixture();
  final naoj = loadNaojFixture();
  if (hko.length != 24 || naoj.length != 24) {
    throw StateError('夹具条数异常：HKO ${hko.length} / NAOJ ${naoj.length}');
  }
  return [
    for (var i = 0; i < 24; i++)
      CrossSourceRow(
        term: SolarTermId.values[i],
        hkoHkt: hko[i].hkt,
        naojJst: naoj[i],
        naojHkt: naoj[i].hktJstShifted,
      ),
  ];
}
