import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_parser.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_validator.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import 'calendar_pack_fixtures.dart';

/// T4 · 数据包校验器测试。
void main() {
  void expectRejected(String json, {required String because}) {
    expect(
      () => CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(json),
      ),
      throwsA(isA<CalendarDataPackInvalid>()),
      reason: because,
    );
  }

  group('T4 · 数量 24/24', () {
    test('24 条 → PASS', () {
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(year: 2026)),
      );
      expect(data.calendarYear, 2026);
      expect(data.terms, hasLength(24));
      expect(data.monthStartTerms, hasLength(12));
      expect(data.termOf(SolarTermId.liChun).id, SolarTermId.liChun);
    });

    test('23 条 → FAIL', () {
      final terms = defaultTerms(2026)..removeLast();
      expectRejected(packJson(terms: terms), because: '少一条必须拒绝');
    });

    test('25 条 → FAIL', () {
      final terms = defaultTerms(2026)
        ..add({'term': 'dongZhi', 'instantUtc': '2027-01-01T00:00:00Z'});
      expectRejected(packJson(terms: terms), because: '多一条必须拒绝');
    });
  });

  group('T4 · 节气唯一性 / 完整性', () {
    test('重复节气 → FAIL', () {
      final terms = defaultTerms(2026);
      terms[5] = Map<String, Object?>.of(terms[4]);
      expectRejected(packJson(terms: terms), because: '重复必须拒绝');
    });

    test('未知节气 → FAIL', () {
      final terms = defaultTerms(2026);
      terms[7] = {'term': 'bogus', 'instantUtc': '2026-05-05T00:00:00Z'};
      expectRejected(packJson(terms: terms), because: '未知值必须拒绝');
    });
  });

  group('T4 · 时间合法性', () {
    test('时间倒序 → FAIL', () {
      final terms = defaultTerms(2026);
      final tmp = terms[3];
      terms[3] = terms[4];
      terms[4] = tmp;
      expectRejected(packJson(terms: terms), because: '倒序必须拒绝');
    });

    test('时间相同（非严格递增）→ FAIL', () {
      final terms = defaultTerms(2026);
      terms[4] = Map<String, Object?>.of(terms[3]);
      terms[4]['term'] = termNames[4];
      expectRejected(packJson(terms: terms), because: '非严格递增必须拒绝');
    });

    test('非法 UTC 字符串 → FAIL', () {
      final terms = defaultTerms(2026);
      terms[2] = {'term': termNames[2], 'instantUtc': 'not-a-date'};
      expectRejected(packJson(terms: terms), because: '不可解析必须拒绝');
    });

    test('非 Z 结尾（非 UTC 基准）→ FAIL', () {
      final terms = defaultTerms(2026);
      terms[2] = {
        'term': termNames[2],
        'instantUtc': '2026-02-04T04:02:00+08:00',
      };
      expectRejected(packJson(terms: terms), because: '必须显式 UTC');
    });
  });

  group('T4 · 元数据', () {
    test('schemaVersion 不支持 → FAIL', () {
      expectRejected(packJson(schemaVersion: 99), because: '版本不支持');
    });

    test('timeStandard 非 UTC → FAIL', () {
      expectRejected(packJson(timeStandard: 'HKT'), because: '时间基准必须 UTC');
    });

    test('revision < 1 → FAIL', () {
      expectRejected(packJson(revision: 0), because: 'revision 非法');
    });

    test('来源缺失 → FAIL', () {
      expectRejected(packJson(sourceName: null), because: '缺 source.name');
      expectRejected(packJson(sourceReference: null), because: '缺 reference');
      expectRejected(packJson(generatedAt: null), because: '缺 generatedAt');
    });
  });

  group('T4 · 年份合理性（按真实节气范围，不做僵硬全范围限制）', () {
    test('把 2028 年数据当作 2026 → FAIL', () {
      expectRejected(
        packJson(year: 2026, terms: defaultTerms(2028)),
        because: '整年错位必须拒绝',
      );
    });

    test('跨公历年边界的正确数据不被误杀（小寒在 1 月、冬至在 12 月）', () {
      // 极端但合法：小寒落在 1 月 2 日，冬至落在 12 月 30 日。
      final terms = <Map<String, Object?>>[
        for (var i = 0; i < 23; i++)
          {
            'term': termNames[i],
            'instantUtc': _isoUtc(
              DateTime.utc(2026, 1, 2).add(Duration(minutes: i * 21888)),
            ),
          },
        {'term': termNames[23], 'instantUtc': '2026-12-30T12:00:00Z'},
      ];
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(year: 2026, terms: terms)),
      );
      expect(data.terms, hasLength(24));
      expect(data.terms.first.id, SolarTermId.xiaoHan);
      expect(data.terms.last.id, SolarTermId.dongZhi);
      expect(data.terms.last.instantUtc.month, 12);
    });
  });
}

String _isoUtc(DateTime utc) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
      '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
      '${two(utc.second)}Z';
}
