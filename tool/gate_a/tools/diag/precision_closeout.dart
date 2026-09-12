/// R3-B-DATA-PRECISION-FIX · 验收断言（走真实产品链路）。
///
/// 链路：CalendarDataPack JSON → parser → validator → importer → store
///       → StoredSolarTermProvider → MonthBranchResolver → CalendarEngine
/// **不**绕过任何一层，也**不**手改 Markdown。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';

const Duration _tz = Duration(hours: 8);

Future<void> main() async {
  final store = InMemoryCalendarDataStore();
  final importer = CalendarDataPackImporter(store);
  for (final y in <int>[2025, 2026]) {
    await importer.importPack(
      File('assets/calendar/$y.calendar.json').readAsStringSync(),
    );
  }
  final provider = await StoredSolarTermProvider.load(store);
  final engine = CalendarEngine(
    monthBranchResolver: MonthBranchResolver(provider),
  );

  final liChun = provider.termsOfYear(2026).firstWhere(
    (t) => t.id == SolarTermId.liChun,
  );

  stdout.writeln('== 数据包记录 ==');
  stdout.writeln('liChun.instantUtc = ${liChun.instantUtc.toIso8601String()}');
  stdout.writeln('precision         = ${liChun.precision.label}');
  stdout.writeln('sourceOverride    = ${liChun.sourceName}');
  stdout.writeln('sourceReference   = ${liChun.sourceReference}');

  const probes = <String>[
    '2026-02-04 04:01:00',
    '2026-02-04 04:02:00',
    '2026-02-04 04:02:07',
    '2026-02-04 04:02:08',
    '2026-02-04 04:02:09',
    '2026-02-04 04:03:00',
  ];
  const expected = <String>['丑', '丑', '丑', '寅', '寅', '寅'];

  stdout.writeln('');
  stdout.writeln('== 验收断言（CalendarEngine 实际执行） ==');
  var failures = 0;
  for (var i = 0; i < probes.length; i++) {
    final p = probes[i].split(RegExp(r'[- :]')).map(int.parse).toList();
    final now = DateTime(p[0], p[1], p[2], p[3], p[4], p[5]);
    final utc = DateTime.utc(p[0], p[1], p[2], p[3], p[4], p[5]).subtract(_tz);
    final month = engine
        .resolve(
          CalendarRequest(
            localDateTime: now,
            utcOffset: _tz,
            dayBoundaryRule: DayBoundaryRule.midnight,
          ),
        )
        .monthBranchLabel;
    final ok = month == expected[i];
    if (!ok) failures++;
    stdout.writeln(
      '${ok ? 'PASS' : 'FAIL'}  ${probes[i]} +08:00  UTC ${utc.toIso8601String()} '
      '→ $month（期望 ${expected[i]}）',
    );
  }
  stdout.writeln('');
  stdout.writeln(failures == 0 ? '验收断言全部 PASS' : '验收断言 FAIL $failures 项');
  exitCode = failures == 0 ? 0 : 1;
}
