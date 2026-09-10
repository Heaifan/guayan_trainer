import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/calendar_year_data.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';

import 'calendar_pack_fixtures.dart';

/// T5 · 导入原子性（强制 Golden Test）与 T6 · 修订规则。
void main() {
  late InMemoryCalendarDataStore store;
  late CalendarDataPackImporter importer;

  setUp(() {
    store = InMemoryCalendarDataStore();
    importer = CalendarDataPackImporter(store);
  });

  /// 取某年已安装数据的「指纹」，用于证明未被改动。
  CalendarYearData? snapshot(CalendarYearData? d) => d;

  group('T5 · 导入原子性', () {
    test('合法导入 → NEW，数据落库', () async {
      final change = await importer.importPack(packJson(year: 2026));
      expect(change, CalendarPackChange.isNew);
      final stored = await store.loadYear(2026);
      expect(stored, isNotNull);
      expect(stored!.calendarYear, 2026);
      expect(stored.terms, hasLength(24));
    });

    test('旧数据存在 → 导入 INVALID 包 → 失败且旧数据完全不变', () async {
      // 1) 先安装一份合法 2026（revision 2）。
      await importer.importPack(packJson(year: 2026, revision: 2));
      final before = await store.loadYear(2026);
      expect(before, isNotNull);
      expect(before!.revision, 2);
      final beforeRevision = before.revision;
      final beforeTerms = before.terms.map((t) => t.instantUtc).toList();
      final beforeSource = before.sourceName;

      // 2) 导入一个 revision 更高但内容非法的包（少一条节气）。
      final broken = defaultTerms(2026)..removeLast();
      await expectLater(
        importer.importPack(packJson(year: 2026, revision: 3, terms: broken)),
        throwsA(isA<CalendarDataPackInvalid>()),
      );

      // 3) 旧数据必须逐字段保持原样。
      final after = await store.loadYear(2026);
      expect(after, isNotNull);
      expect(after!.revision, beforeRevision, reason: 'revision 被改动');
      expect(after.sourceName, beforeSource, reason: '来源被改动');
      expect(
        after.terms.map((t) => t.instantUtc).toList(),
        beforeTerms,
        reason: '节气数据被改动 —— 导入不具备原子性',
      );
      expect((await store.installedYears()), [2026]);
      expect(snapshot(after)!.terms.length, 24);
    });

    test('解析失败的包不影响已安装的其它年份', () async {
      await importer.importPack(packJson(year: 2025));
      await expectLater(
        importer.importPack('{ this is not json'),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
      expect(await store.hasYear(2025), isTrue);
      expect(await store.loadYear(2025), isNotNull);
    });
  });

  group('T6 · 修订规则', () {
    test('无数据 + rev1 → NEW', () async {
      expect(
        await importer.importPack(packJson(year: 2026, revision: 1)),
        CalendarPackChange.isNew,
      );
    });

    test('rev1 + rev2 → UPDATE 并替换数据', () async {
      await importer.importPack(packJson(year: 2026, revision: 1));
      final change = await importer.importPack(
        packJson(year: 2026, revision: 2),
      );
      expect(change, CalendarPackChange.update);
      expect((await store.loadYear(2026))!.revision, 2);
    });

    test('rev2 + rev2 → SAME 且为空操作', () async {
      await importer.importPack(packJson(year: 2026, revision: 2));
      final change = await importer.importPack(
        packJson(year: 2026, revision: 2),
      );
      expect(change, CalendarPackChange.same);
      expect((await store.loadYear(2026))!.revision, 2);
    });

    test('rev2 + rev1 → DOWNGRADE 被拒绝，旧数据不变', () async {
      await importer.importPack(packJson(year: 2026, revision: 2));
      await expectLater(
        importer.importPack(packJson(year: 2026, revision: 1)),
        throwsA(isA<CalendarRevisionRejected>()),
      );
      expect((await store.loadYear(2026))!.revision, 2, reason: '禁止静默降级');
    });

    test('changeOf 纯函数覆盖四种情形', () {
      CalendarYearData d(int rev) => CalendarYearData(
        calendarYear: 2026,
        schemaVersion: 1,
        revision: rev,
        sourceName: 's',
        sourceReference: 'r',
        generatedAt: DateTime.utc(2026),
        terms: const [],
      );
      expect(
        CalendarDataPackImporter.changeOf(null, d(1)),
        CalendarPackChange.isNew,
      );
      expect(
        CalendarDataPackImporter.changeOf(d(1), d(2)),
        CalendarPackChange.update,
      );
      expect(
        CalendarDataPackImporter.changeOf(d(2), d(2)),
        CalendarPackChange.same,
      );
      expect(
        CalendarDataPackImporter.changeOf(d(2), d(1)),
        CalendarPackChange.downgrade,
      );
    });
  });
}
