import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import 'calendar_pack_fixtures.dart';

/// T7 · 立春**秒级**边界 Golden Test（R3-B-DATA-PRECISION-FIX）。
///
/// 根因：官方只发布到分钟（`04:02`），数据包曾把该分钟直接存为
/// `04:02:00` 的瞬间，于是「该分钟内交节」被误当成「恰在第 0 秒交节」，
/// 导致 `04:02:00`—`04:02:07` 这 8 秒内提前切到寅月。
///
/// 已核秒级真值（紫金山天文台科普部公开值）：
/// ```text
/// 2026-02-04 04:02:08 +08:00  =  2026-02-03T20:02:08Z
/// ```
void main() {
  const tz = Duration(hours: 8);
  late CalendarEngine engine;

  setUpAll(() async {
    final store = InMemoryCalendarDataStore();
    final importer = CalendarDataPackImporter(store);
    // 月建解析器需要能看到上一年（2 月初尚未交小寒时属上一年大雪所开子月）。
    for (final year in <int>[2025, 2026]) {
      await importer.importPack(readSeedPack(year));
    }
    engine = CalendarEngine(
      monthBranchResolver: MonthBranchResolver(
        await StoredSolarTermProvider.load(store),
      ),
    );
  });

  DiZhi monthAt(String hkt) {
    final p = hkt.split(RegExp(r'[- :]')).map(int.parse).toList();
    return engine
        .resolve(
          CalendarRequest(
            localDateTime: DateTime(p[0], p[1], p[2], p[3], p[4], p[5]),
            utcOffset: tz,
            dayBoundaryRule: DayBoundaryRule.midnight,
          ),
        )
        .monthBranch;
  }

  group('T7 · 数据包必须记录秒级立春', () {
    test('liChun 瞬间 = 2026-02-03T20:02:08Z 且精度为 second', () async {
      final store = InMemoryCalendarDataStore();
      await CalendarDataPackImporter(store).importPack(readSeedPack(2026));
      final data = (await store.loadYear(2026))!;
      final liChun = data.termOf(SolarTermId.liChun);

      expect(liChun.instantUtc, DateTime.utc(2026, 2, 3, 20, 2, 8));
      expect(liChun.isSecondPrecise, isTrue);
      expect(liChun.sourceName, contains('紫金山'));
    });

    test('其余十一「节」仍为分钟级，秒位恒为 :00（不得伪造秒）', () async {
      final store = InMemoryCalendarDataStore();
      await CalendarDataPackImporter(store).importPack(readSeedPack(2026));
      final data = (await store.loadYear(2026))!;

      for (final t in data.monthStartTerms) {
        if (t.id == SolarTermId.liChun) continue;
        expect(t.isSecondPrecise, isFalse, reason: '${t.id.label} 不应是秒级');
        expect(t.instantUtc.second, 0, reason: '${t.id.label} 为分钟级，秒位必须是 0');
      }
    });
  });

  group('T7 · 秒级边界三态（04:02:08 前后必须分开）', () {
    test('04:02:07 → 丑（交节前 1 秒）', () {
      expect(monthAt('2026-02-04 04:02:07'), DiZhi.chou);
    });

    test('04:02:08 → 寅（交节瞬间，含）', () {
      expect(monthAt('2026-02-04 04:02:08'), DiZhi.yin);
    });

    test('04:02:09 → 寅（交节后 1 秒）', () {
      expect(monthAt('2026-02-04 04:02:09'), DiZhi.yin);
    });
  });

  group('T7 · 分钟级相邻点（修复后 04:02:00 不再是寅）', () {
    test('04:01:00 → 丑', () {
      expect(monthAt('2026-02-04 04:01:00'), DiZhi.chou);
    });

    test('04:02:00 → 丑（**修复点**：该分钟尚未交节）', () {
      expect(monthAt('2026-02-04 04:02:00'), DiZhi.chou);
    });

    test('04:03:00 → 寅', () {
      expect(monthAt('2026-02-04 04:03:00'), DiZhi.yin);
    });
  });

  group('T7 · 边界前后远端对照（确认不是整体位移）', () {
    test('交节前 1 小时 → 丑', () {
      expect(monthAt('2026-02-04 03:02:08'), DiZhi.chou);
    });

    test('交节后 1 小时 → 寅', () {
      expect(monthAt('2026-02-04 05:02:08'), DiZhi.yin);
    });

    test('前一日 → 丑（丑月区间内）', () {
      expect(monthAt('2026-02-03 12:00:00'), DiZhi.chou);
    });
  });
}
