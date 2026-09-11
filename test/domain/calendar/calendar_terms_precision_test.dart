import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_parser.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_validator.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import 'calendar_pack_fixtures.dart';

/// T8 · 精度与来源元数据校验（R3-B-DATA-PRECISION-FIX）。
///
/// 契约冻结：
/// ```text
/// 年度 source        = 默认来源
/// term sourceOverride = 可选覆盖（须含 name + reference）
/// term precision      = minute（缺省） / second
/// ```
/// 未知 precision、残缺 sourceOverride 一律拒绝 —— 宁可失败，
/// 也不要把「不知道精度的数据」当成可信数据导入。
void main() {
  Map<String, Object?> withPrecision(
    String precision, {
    Map<String, Object?>? override,
  }) {
    final term = <String, Object?>{
      ...defaultTerms(2026)[2],
      'precision': precision,
    };
    if (override != null) term['sourceOverride'] = override;
    return term;
  }

  void expectRejected(Map<String, Object?> term, {required String because}) {
    final terms = defaultTerms(2026)..[2] = term;
    expect(
      () => CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(terms: terms, schemaVersion: 2)),
      ),
      throwsA(isA<CalendarDataPackInvalid>()),
      reason: because,
    );
  }

  group('T8 · v1 老包保持兼容（缺省 = 分钟级）', () {
    test('v1 无 precision → 解析为 minute，秒位语义等同旧行为', () {
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(schemaVersion: 1)),
      );
      expect(data.schemaVersion, 1);
      for (final t in data.terms) {
        expect(t.precision, TermPrecision.minute);
        expect(t.isSecondPrecise, isFalse);
      }
    });

    test('v2 中显式 minute 同样合法', () {
      final terms = defaultTerms(2026)..[2] = withPrecision('minute');
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(terms: terms, schemaVersion: 2)),
      );
      expect(data.termOf(SolarTermId.liChun).precision, TermPrecision.minute);
    });
  });

  group('T8 · v2 精度声明', () {
    test('second + 完整 sourceOverride → 合法且可读出来源', () {
      final terms = defaultTerms(2026)
        ..[2] = withPrecision(
          'second',
          override: {
            'name': '某天文机构',
            'reference': 'https://example.invalid/x',
            'note': '秒级公布值',
          },
        );
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(terms: terms, schemaVersion: 2)),
      );
      final liChun = data.termOf(SolarTermId.liChun);
      expect(liChun.isSecondPrecise, isTrue);
      expect(liChun.sourceName, '某天文机构');
      expect(liChun.sourceReference, 'https://example.invalid/x');
    });

    test('second 无 sourceOverride → 合法（沿用年度来源）', () {
      final terms = defaultTerms(2026)..[2] = withPrecision('second');
      final data = CalendarDataPackValidator.validate(
        CalendarDataPackParser.parse(packJson(terms: terms, schemaVersion: 2)),
      );
      expect(data.termOf(SolarTermId.liChun).sourceName, isNull);
    });

    test('未知 precision → 拒绝', () {
      expectRejected(withPrecision('microsecond'), because: '未知精度必须拒绝');
    });

    test('precision 类型错误（数字）→ 拒绝', () {
      final terms = defaultTerms(2026);
      terms[2] = {...terms[2], 'precision': 1};
      expect(
        () => CalendarDataPackValidator.validate(
          CalendarDataPackParser.parse(
            packJson(terms: terms, schemaVersion: 2),
          ),
        ),
        throwsA(isA<CalendarDataPackInvalid>()),
        reason: '类型错误必须拒绝',
      );
    });
  });

  group('T8 · v2 来源覆盖契约', () {
    test('sourceOverride 缺 name → 拒绝', () {
      expectRejected(
        withPrecision('second', override: {'reference': 'x'}),
        because: '缺 name',
      );
    });

    test('sourceOverride 缺 reference → 拒绝', () {
      expectRejected(
        withPrecision('second', override: {'name': '某机构'}),
        because: '缺 reference',
      );
    });

    test('sourceOverride 为空对象 → 拒绝', () {
      expectRejected(
        withPrecision('second', override: <String, Object?>{}),
        because: '空覆盖无意义',
      );
    });
  });

  group('T8 · 版本范围', () {
    test('schemaVersion 0 → 拒绝', () {
      expect(
        () => CalendarDataPackValidator.validate(
          CalendarDataPackParser.parse(packJson(schemaVersion: 0)),
        ),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });

    test('schemaVersion 3 → 拒绝（高于支持上限）', () {
      expect(
        () => CalendarDataPackValidator.validate(
          CalendarDataPackParser.parse(packJson(schemaVersion: 3)),
        ),
        throwsA(isA<CalendarDataPackInvalid>()),
      );
    });
  });
}
