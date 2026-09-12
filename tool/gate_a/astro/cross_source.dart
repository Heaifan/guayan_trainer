/// Gate A-Truth 官方双源交叉核验 CLI：HKO（HKT） vs NAOJ（JST→HKT）。
///
/// 这是 Gate A-Truth 中「节气数据」一项的真值来源：两个互相独立的官方机构
/// 发布表。自建天文算法（`sun_longitude.dart`）只是 diagnostic，
/// **不参与**本核验，也不得据此判定数据源有误。
/// 数据行与装配见 `cross_source_rows.dart`。
library;

import 'dart:io';

import 'cross_source_rows.dart';
import '../data/hko_source.dart';
import '../data/naoj_source.dart';

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
      '| ${r.term.label} | ${ymdhm(r.hkoHkt)} '
      '| ${ymdhm(r.naojJstWallClock)} '
      '| ${ymdhm(r.naojHkt)} '
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
        '  ${r.term.label} HKO ${ymdhm(r.hkoHkt)} vs NAOJ→HKT '
        '${ymdhm(r.naojHkt)}（Δ${r.minuteDelta} 分钟）',
      );
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('');
  stdout.writeln('交叉核验 PASS：HKO 与 NAOJ 在 $year 年 24 / 24 分钟级一致。');
  stdout.writeln('结论：官方分钟级真值成立（这与「立春另有秒级真值」不矛盾：');
  stdout.writeln('      官方的 04:02 表示「该分钟内交节」，秒级真值把它细化为 04:02:08）。');
}
