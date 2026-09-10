import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_parser.dart';

import 'calendar_pack_fixtures.dart';

/// T3 · 数据包解析器测试。
///
/// 解析器只负责语法与结构；语义问题交给校验器（T4）。
void main() {
  group('T3 · 正确 JSON', () {
    test('字段完整解析', () {
      final pack = CalendarDataPackParser.parse(packJson(year: 2026));
      expect(pack.schemaVersion, 1);
      expect(pack.calendarYear, 2026);
      expect(pack.timeStandard, 'UTC');
      expect(pack.revision, 1);
      expect(pack.sourceName, 'Test Source');
      expect(pack.sourceReference, 'https://example.invalid/x');
      expect(pack.generatedAt, '2026-01-01T00:00:00Z');
      expect(pack.terms, hasLength(24));
      expect(pack.terms.first.term, 'xiaoHan');
      expect(pack.terms.last.term, 'dongZhi');
    });

    test('未知节气名原样保留，交由校验器报错', () {
      final terms = defaultTerms(2026);
      terms[3] = {'term': 'notATerm', 'instantUtc': '2026-01-01T00:00:00Z'};
      final pack = CalendarDataPackParser.parse(packJson(terms: terms));
      expect(pack.terms[3].term, 'notATerm');
    });

    test('缺字段解析为 null，不在此层抛错', () {
      final pack = CalendarDataPackParser.parse(
        packJson(overrides: {'revision': null, 'source': null}),
      );
      expect(pack.revision, isNull);
      expect(pack.sourceName, isNull);
    });
  });

  group('T3 · 非法 JSON', () {
    test('语法错误抛 CalendarDataPackInvalid', () {
      expect(
        () => CalendarDataPackParser.parse('{ not json'),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });

    test('根节点非对象抛错', () {
      expect(
        () => CalendarDataPackParser.parse('[1,2,3]'),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
      expect(
        () => CalendarDataPackParser.parse('"str"'),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });

    test('terms 非数组抛错', () {
      expect(
        () => CalendarDataPackParser.parse(
          packJson(overrides: {'terms': 'nope'}),
        ),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
      expect(
        () =>
            CalendarDataPackParser.parse(packJson(overrides: {'terms': null})),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });

    test('terms 元素非对象抛错', () {
      expect(
        () => CalendarDataPackParser.parse(
          packJson(
            overrides: {
              'terms': [1, 2, 3],
            },
          ),
        ),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });

    test('错误信息可读（包含 JSON 语法错误提示）', () {
      try {
        CalendarDataPackParser.parse('{ bad');
        fail('应当抛错');
      } on CalendarDataPackInvalid catch (e) {
        expect(e.reasons, isNotEmpty);
        expect(e.toString(), contains('JSON'));
      }
    });
  });
}
