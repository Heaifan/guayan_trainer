import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_provider.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

/// 合成节气源：用确定公式摆放 24 节气，使边界可精确断言。
///
/// 刻意不依赖真实数据表 —— 本文件验证的是**边界语义与区间逻辑**，
/// 真实数据表的正确性由 T3 数据完整性与 T6 综合 Golden 另行覆盖。
const _yearStart = 2000;
const _yearEnd = 2030;

/// 节气 i 的交节瞬间：以年初为基准，每节气相隔 21888 分钟（= 15.2 天）。
DateTime fakeInstant(int year, SolarTermId id) =>
    DateTime.utc(year, 1, 1).add(Duration(minutes: id.index * 21888 + 1000));

class _FakeProvider implements SolarTermProvider {
  @override
  int get minYear => _yearStart;

  @override
  int get maxYear => _yearEnd;

  @override
  List<SolarTerm> termsOfYear(int year) {
    if (year < minYear || year > maxYear) {
      throw CalendarDataMissing(year);
    }
    return [
      for (final id in SolarTermId.values)
        SolarTerm(id: id, instantUtc: fakeInstant(year, id)),
    ];
  }
}

void main() {
  final resolver = MonthBranchResolver(_FakeProvider());

  group('T4 · 十二「节」边界：前 1 秒 / 交节 / 后 1 秒', () {
    for (final id in SolarTermId.monthStartTerms) {
      final boundary = fakeInstant(2026, id);
      final expected = id.monthBranch!;

      test('${id.label} → ${expected.label}（$boundary）', () {
        // 交节前 1 秒仍是上一个月建。
        final before = resolver.resolve(
          boundary.subtract(const Duration(seconds: 1)),
        );
        // 交节时刻与之后 1 秒均为新月建。
        final at = resolver.resolve(boundary);
        final after = resolver.resolve(
          boundary.add(const Duration(seconds: 1)),
        );

        expect(at, expected, reason: '${id.label} 交节时刻应切换月建');
        expect(after, expected, reason: '${id.label} 交节后 1 秒应属新月建');
        expect(before, isNot(expected), reason: '${id.label} 交节前 1 秒不应已切换');
      });
    }
  });

  group('T4 · 跨公历年边界（小寒 / 立春 / 大雪）', () {
    test('年初尚未交小寒 → 上一年大雪所开的子月', () {
      final t = DateTime.utc(2026, 1, 1, 0, 0, 0);
      expect(resolver.resolve(t), DiZhi.zi);
    });

    test('小寒交节后 → 丑月', () {
      expect(
        resolver.resolve(fakeInstant(2026, SolarTermId.xiaoHan)),
        DiZhi.chou,
      );
    });

    test('立春交节 → 寅月（跨年后的第一个月建切换）', () {
      expect(
        resolver.resolve(fakeInstant(2026, SolarTermId.liChun)),
        DiZhi.yin,
      );
    });

    test('大雪交节 → 子月，并持续到年末', () {
      expect(resolver.resolve(fakeInstant(2026, SolarTermId.daXue)), DiZhi.zi);
      final lastDay = fakeInstant(
        2026,
        SolarTermId.daXue,
      ).add(const Duration(days: 20));
      expect(lastDay.year, 2026);
      expect(resolver.resolve(lastDay), DiZhi.zi);
    });
  });

  group('T4 · 「气」不切换月建', () {
    test('冬至（气）不改变月建，仍为子月', () {
      final t = fakeInstant(2026, SolarTermId.dongZhi);
      expect(SolarTermId.dongZhi.isMonthStart, isFalse);
      expect(resolver.resolve(t), DiZhi.zi);
    });

    test('十二「节」= 12，十二「气」= 12', () {
      expect(SolarTermId.monthStartTerms, hasLength(12));
      expect(SolarTermId.values.where((t) => !t.isMonthStart), hasLength(12));
    });
  });

  group('T8 · 缺少年份明确失败（禁止 fallback）', () {
    test('未安装年份抛 CalendarDataMissing，绝不近似补算', () {
      expect(
        () => resolver.resolve(DateTime.utc(1999, 6, 1)),
        throwsA(isA<CalendarDataMissing>()),
      );
      expect(
        () => resolver.resolve(DateTime.utc(2031, 6, 1)),
        throwsA(isA<CalendarDataMissing>()),
      );
    });

    test('年初需读上一年：上一年缺失时同样明确失败', () {
      // 2000-01-01 尚未交小寒，月建取决于 1999 年大雪；1999 未安装。
      expect(
        () => resolver.resolve(DateTime.utc(2000, 1, 1)),
        throwsA(isA<CalendarDataMissing>()),
      );
    });
  });
}
