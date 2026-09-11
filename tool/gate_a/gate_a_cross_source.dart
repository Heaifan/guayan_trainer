/// Gate A2 官方双源交叉核验：HKO（HKT） vs NAOJ（JST→HKT），24 项逐条比对。
///
/// 这是 Gate A2 的**真值来源**：两个互相独立的官方机构发布表。
/// 自建天文算法（`gate_a_sun_longitude.dart`）只是 diagnostic，
/// **不参与**本核验，也不得据此判定数据源有误。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import 'gate_a_hko_source.dart';
import 'gate_a_naoj_source.dart';

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

  bool get sameDate =>
      hkoHkt.year == naojHkt.year &&
      hkoHkt.month == naojHkt.month &&
      hkoHkt.day == naojHkt.day;

  bool get sameMinute =>
      sameDate && hkoHkt.hour == naojHkt.hour && hkoHkt.minute == naojHkt.minute;

  /// 分钟差（HKO − NAOJ），单位分钟。
  int get minuteDelta => hkoHkt.difference(naojHkt).inMinutes;
}

String _two(int v) => v.toString().padLeft(2, '0');

String _ymdhm(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

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

void main(List<String> args) async {
  final rows = buildCrossSourceRows();
  const year = 2026;

  stdout.writeln('=== HKO (HKT) vs NAOJ (JST→HKT) — $year 二十四节气 ===');
  stdout.writeln('来源（均为官方原始发布件，不是本仓库数据包）：');
  stdout.writeln('  HKO  $hkoFixturePath');
  stdout.writeln('  NAOJ $naojFixturePath');
  stdout.writeln('');
  stdout.writeln(
    '| 节气 | HKO(HKT) | NAOJ(JST) | NAOJ→HKT | 日期一致 | 分钟一致 | Δ分钟 |',
  );
  stdout.writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final r in rows) {
    stdout.writeln(
      '| ${r.term.label} | ${_ymdhm(r.hkoHkt)} '
      '| ${_ymdhm(DateTime.utc(2026, r.naojJst.month, r.naojJst.day, r.naojJst.hour, r.naojJst.minute))} '
      '| ${_ymdhm(r.naojHkt)} '
      '| ${r.sameDate ? '✅' : '❌'} | ${r.sameMinute ? '✅' : '❌'} '
      '| ${r.minuteDelta} |',
    );
  }

  final dateOk = rows.where((r) => r.sameDate).length;
  final minuteOk = rows.where((r) => r.sameMinute).length;
  stdout.writeln('');
  stdout.writeln('日期一致：$dateOk / 24');
  stdout.writeln('分钟一致：$minuteOk / 24');

  if (dateOk != 24 || minuteOk != 24) {
    stdout.writeln('');
    stdout.writeln('STOP — 官方双源出现不一致，按 GATE-A-PREP-FIX2 §3 停止并上报。');
    for (final r in rows.where((r) => !r.sameMinute)) {
      stdout.writeln(
        '  ${r.term.label} HKO ${_ymdhm(r.hkoHkt)} vs NAOJ→HKT '
        '${_ymdhm(r.naojHkt)}（Δ${r.minuteDelta} 分钟）',
      );
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('');
  stdout.writeln('交叉核验 PASS：HKO 与 NAOJ 在 2026 年 24 / 24 分钟级一致。');
  stdout.writeln('结论：官方分钟级真值成立（这与「立春另有秒级真值」不矛盾：');
  stdout.writeln('      官方的 04:02 表示「该分钟内交节」，秒级真值把它细化为 04:02:08）。');
}
