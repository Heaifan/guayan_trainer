import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import 'calendar_pack_fixtures.dart';

/// T9 · 立春精度修订的**导入回归**（R3-B-DATA-PRECISION-FIX）。
///
/// 目标不是「revision 数字变了」，而是证明：
/// ```text
/// 旧包已安装（分钟级 04:02:00）
///   ↓ 导入更高 revision
/// UPDATE
///   ↓
/// 新月建边界真实生效（04:02:08）
/// ```
/// 同时保留原有纪律：旧包重新导入 = DOWNGRADE 拒绝，且已装数据不变。
void main() {
  const tz = Duration(hours: 8);

  /// 造一份「旧」包：立春为分钟级 04:02:00 +08:00，无精度声明。
  List<Map<String, Object?>> legacyTerms() {
    final terms = defaultTerms(2026);
    terms[2] = {
      'term': SolarTermId.liChun.name,
      'instantUtc': '2026-02-03T20:02:00Z',
    };
    return terms;
  }

  /// 造一份「新」包：立春为秒级 04:02:08 +08:00，带逐节气来源覆盖。
  List<Map<String, Object?>> fixedTerms() {
    final terms = defaultTerms(2026);
    terms[2] = {
      'term': SolarTermId.liChun.name,
      'instantUtc': '2026-02-03T20:02:08Z',
      'precision': 'second',
      'sourceOverride': {
        'name': '中国科学院紫金山天文台科普部',
        'reference': 'https://example.invalid/sentinel',
        'note': '秒级公开值',
      },
    };
    return terms;
  }

  Future<DiZhi> monthAt(
    CalendarDataStore store,
    String hkt,
  ) async {
    final engine = CalendarEngine(
      monthBranchResolver: MonthBranchResolver(
        await StoredSolarTermProvider.load(store),
      ),
    );
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

  group('T9 · 精度修订导入', () {
    test('旧包（分钟级）在 04:02:00 给出寅月 —— 复刻缺陷', () async {
      final store = InMemoryCalendarDataStore();
      final importer = CalendarDataPackImporter(store);
      // 需要上一年供月建解析（此处用同一年即可：立春在 2 月，跨年查找不会触发）。
      await importer.importPack(
        packJson(year: 2026, revision: 1, terms: legacyTerms()),
      );
      await importer.importPack(readSeedPack(2025));
      expect(await monthAt(store, '2026-02-04 04:02:00'), DiZhi.yin);
      expect(await monthAt(store, '2026-02-04 04:02:08'), DiZhi.yin);
    });

    test('导入新 revision → UPDATE，且 04:02:00 起改判为丑月', () async {
      final store = InMemoryCalendarDataStore();
      final importer = CalendarDataPackImporter(store);
      await importer.importPack(
        packJson(year: 2026, revision: 1, terms: legacyTerms()),
      );
      await importer.importPack(readSeedPack(2025));

      final change = await importer.importPack(
        packJson(
          year: 2026,
          revision: 2,
          schemaVersion: 2,
          terms: fixedTerms(),
        ),
      );
      expect(change, CalendarPackChange.update);

      // 新瞬间真实生效：边界被推到 04:02:08。
      expect(await monthAt(store, '2026-02-04 04:02:00'), DiZhi.chou);
      expect(await monthAt(store, '2026-02-04 04:02:07'), DiZhi.chou);
      expect(await monthAt(store, '2026-02-04 04:02:08'), DiZhi.yin);

      final installed = (await store.loadYear(2026))!;
      expect(installed.revision, 2);
      final liChun = installed.termOf(SolarTermId.liChun);
      expect(liChun.isSecondPrecise, isTrue);
      expect(liChun.sourceName, contains('紫金山'));
    });

    test('旧包重新导入 → DOWNGRADE 拒绝，且已升级数据不被回退', () async {
      final store = InMemoryCalendarDataStore();
      final importer = CalendarDataPackImporter(store);
      await importer.importPack(
        packJson(
          year: 2026,
          revision: 2,
          schemaVersion: 2,
          terms: fixedTerms(),
        ),
      );
      await expectLater(
        importer.importPack(
          packJson(year: 2026, revision: 1, terms: legacyTerms()),
        ),
        throwsA(isA<CalendarRevisionRejected>()),
      );
      final installed = (await store.loadYear(2026))!;
      expect(installed.revision, 2, reason: '禁止静默降级');
      expect(installed.termOf(SolarTermId.liChun).isSecondPrecise, isTrue);
    });

    test('真实 2026 种子包：revision 2、立春秒级、其余分钟级', () async {
      final store = InMemoryCalendarDataStore();
      await CalendarDataPackImporter(store).importPack(readSeedPack(2026));
      final data = (await store.loadYear(2026))!;

      expect(data.revision, 2);
      expect(data.schemaVersion, 2);
      expect(data.termOf(SolarTermId.liChun).isSecondPrecise, isTrue);
      expect(
        data.terms.where((t) => t.isSecondPrecise).length,
        1,
        reason: '2026 年只有立春有已核实秒级真值，不得伪升级其他节气',
      );
    });
  });
}
