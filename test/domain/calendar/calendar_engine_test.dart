import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import 'calendar_pack_fixtures.dart';

/// T8 · 缺少年份行为；T9 · CalendarEngine 综合 Golden Tests。
///
/// 全部使用 `assets/calendar/` 中由 HKO 权威数据生成的真实数据包，
/// 走完整链路：JSON → 解析 → 校验 → 导入 → 仓储 → Provider → Engine。
void main() {
  const tz = Duration(hours: 8);
  late CalendarEngine engine;

  Future<CalendarEngine> buildEngine(List<int> years) async {
    final store = InMemoryCalendarDataStore();
    final importer = CalendarDataPackImporter(store);
    for (final y in years) {
      await importer.importPack(readSeedPack(y));
    }
    return CalendarEngine(
      monthBranchResolver: MonthBranchResolver(
        await StoredSolarTermProvider.load(store),
      ),
    );
  }

  setUpAll(() async {
    engine = await buildEngine(seedYears);
  });

  CalendarContext at(
    String ymdhms, {
    DayBoundaryRule rule = DayBoundaryRule.midnight,
  }) {
    final p = ymdhms.split(RegExp(r'[- :]')).map(int.parse).toList();
    return engine.resolve(
      CalendarRequest(
        localDateTime: DateTime(p[0], p[1], p[2], p[3], p[4], p[5]),
        utcOffset: tz,
        dayBoundaryRule: rule,
      ),
    );
  }

  group('T9 · 月建（全部锚定真实交节瞬间）', () {
    test('普通日期：2026-06-15 → 午月（芒种后、小暑前）', () {
      expect(at('2026-06-15 12:00:00').monthBranch, DiZhi.wu);
    });

    test('立春交界：秒级 04:02:08 交节，寅月；前 1 秒仍为丑月', () {
      // R3-B-DATA-PRECISION-FIX：立春已被修正为**秒级**真值
      // 2026-02-04 04:02:08 +08:00。故 04:02:00 仍在交节之前 → 丑月。
      // （此处原文曾断言 04:02:00 即寅月，那是把「该分钟内交节」
      //  误当成「恰在第 0 秒交节」的旧行为，已随数据包修正。）
      expect(at('2026-02-04 04:02:07').monthBranch, DiZhi.chou);
      expect(at('2026-02-04 04:02:08').monthBranch, DiZhi.yin);
      expect(at('2026-02-04 04:02:09').monthBranch, DiZhi.yin);
    });

    test('立春分钟级粗测点：该分钟内（04:02:00）尚未交节 → 丑月', () {
      expect(at('2026-02-04 04:01:00').monthBranch, DiZhi.chou);
      expect(at('2026-02-04 04:02:00').monthBranch, DiZhi.chou);
      expect(at('2026-02-04 04:03:00').monthBranch, DiZhi.yin);
    });

    test('白露交界：22:41:00 交节，酉月；前 1 秒仍为申月', () {
      expect(at('2026-09-07 22:40:59').monthBranch, DiZhi.shen);
      expect(at('2026-09-07 22:41:00').monthBranch, DiZhi.you);
    });

    test('小寒交界（跨公历年）：16:23:00 交节，丑月；前 1 秒为子月', () {
      expect(at('2026-01-05 16:22:59').monthBranch, DiZhi.zi);
      expect(at('2026-01-05 16:23:00').monthBranch, DiZhi.chou);
    });

    test('年末 2026-12-31 → 子月（大雪后）', () {
      expect(at('2026-12-31 12:00:00').monthBranch, DiZhi.zi);
    });

    test('年初 2026-01-01 → 子月（需读 2025 年数据）', () {
      expect(at('2026-01-01 12:00:00').monthBranch, DiZhi.zi);
    });

    test('闰日 2024-02-29 → 寅月', () {
      expect(at('2024-02-29 12:00:00').monthBranch, DiZhi.yin);
    });
  });

  group('T9 · 日辰 / 旬空（跨年代锚点）', () {
    test('2023-09-29 → 庚寅日 · 酉月 · 旬空午未', () {
      // 日柱 庚寅 由独立公开黄历源校验（见 ganzhi_day_test.dart）。
      final c = at('2023-09-29 12:00:00');
      expect(c.dayGanZhi, '庚寅');
      expect(c.monthBranch, DiZhi.you);
      expect(c.xunKongLabel, '午未');
      expect(c.xunKong.xunHeadLabel, '甲申');
    });

    test('2026 年内日辰逐日连续（与 Engine 输出一致）', () {
      final a = at('2026-06-15 12:00:00');
      final b = at('2026-06-16 12:00:00');
      expect((a.day.cycleIndex + 1) % 60, b.day.cycleIndex);
    });
  });

  group('T9 · 日界规则贯穿 Engine', () {
    test('23:30 在两种规则下日辰不同', () {
      final midnight = at('2026-09-07 23:30:00');
      final ziHour = at(
        '2026-09-07 23:30:00',
        rule: DayBoundaryRule.ziHourStart,
      );
      expect(midnight.dayGanZhi, isNot(ziHour.dayGanZhi));
      expect((midnight.day.cycleIndex + 1) % 60, ziHour.day.cycleIndex);
    });

    test('00:00 在两种规则下日辰相同', () {
      expect(
        at('2026-09-07 00:00:00').dayGanZhi,
        at('2026-09-07 00:00:00', rule: DayBoundaryRule.ziHourStart).dayGanZhi,
      );
    });
  });

  group('T8 · 缺少年份明确失败，禁止 fallback', () {
    test('只装 2026/2027，查询 2028 → CalendarDataMissing', () async {
      final limited = await buildEngine(<int>[2026, 2027]);
      expect(
        () => limited.resolve(
          CalendarRequest(
            localDateTime: DateTime(2028, 5, 1, 12),
            utcOffset: tz,
            dayBoundaryRule: DayBoundaryRule.midnight,
          ),
        ),
        throwsA(isA<CalendarDataMissing>()),
      );
    });

    test('缺上一年时年初同样拒绝（2026-01-01 需读 2025）', () async {
      final limited = await buildEngine(<int>[2026]);
      expect(
        () => limited.resolve(
          CalendarRequest(
            localDateTime: DateTime(2026, 1, 1, 12),
            utcOffset: tz,
            dayBoundaryRule: DayBoundaryRule.midnight,
          ),
        ),
        throwsA(isA<CalendarDataMissing>()),
      );
    });

    test('空仓储构造 Provider 直接失败', () async {
      await expectLater(
        StoredSolarTermProvider.load(InMemoryCalendarDataStore()),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('T9 · CalendarContext 为完整上下文（不允许半成品）', () {
    test('月建 / 日辰 / 旬空 三者恒非空', () {
      final c = at('2026-09-07 22:41:00');
      expect(c.monthBranch, isNotNull);
      expect(c.dayGanZhi, isNotEmpty);
      expect(c.xunKongLabel, isNotEmpty);
      expect(c.instantUtc.isUtc, isTrue);
    });

    test('时区偏移参与月建判定（同一挂钟时间、不同偏移可跨节）', () {
      // 立春 = 2026-02-03T20:02:08Z（秒级真值）。
      // local 02:00 @+8 → UTC 18:00（交节前）→ 丑月；
      // local 02:00 @+0 → UTC 02:00（交节后）→ 寅月。
      final plus8 = engine.resolve(
        CalendarRequest(
          localDateTime: DateTime(2026, 2, 4, 2),
          utcOffset: tz,
          dayBoundaryRule: DayBoundaryRule.midnight,
        ),
      );
      final plus0 = engine.resolve(
        CalendarRequest(
          localDateTime: DateTime(2026, 2, 4, 2),
          utcOffset: Duration.zero,
          dayBoundaryRule: DayBoundaryRule.midnight,
        ),
      );
      expect(plus8.monthBranch, DiZhi.chou, reason: 'UTC 18:00 尚未交节');
      expect(plus0.monthBranch, DiZhi.yin, reason: 'UTC 02:00 已交节');
    });
  });
}
