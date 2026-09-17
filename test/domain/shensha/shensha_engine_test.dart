import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/shensha/shensha_engine.dart';
import 'package:guayan_trainer/domain/shensha/shensha_models.dart';

import 'shensha_golden_fixture.dart';

void main() {
  test('Golden A computes all confirmed date/month/day shen sha', () {
    final results = const ShenShaEngine().calculate(goldenShenShaContext);
    final values = {
      for (final result in results) result.displayName: result.value,
    };

    expect(results, hasLength(19));
    expect(values, containsPair('卦身', '酉'));
    expect(values, containsPair('香闺', '寅卯'));
    expect(values, containsPair('床帐', '子亥'));
    for (final entry in goldenDateMonthDayExpected.entries) {
      expect(values, containsPair(entry.key, entry.value));
    }
  });

  test('Golden B freezes gua shen and multi-branch order', () {
    final results = const ShenShaEngine().calculate(goldenShenShaContext);
    final byName = {for (final result in results) result.displayName: result};

    expect(byName['卦身']!.branches, ['酉']);
    expect(byName['香闺']!.branches, ['寅', '卯']);
    expect(byName['床帐']!.branches, ['子', '亥']);
    expect(byName['贵人']!.branches, ['卯', '巳']);
    expect(byName['贵人']!.ruleSetId, 'shensha.standard.v1');
    expect(byName['贵人']!.reasonSnapshot, '日干=癸 → 卯巳');
  });

  test('results round trip without losing identity or reason snapshot', () {
    final original = const ShenShaEngine()
        .calculate(goldenShenShaContext)
        .first;
    expect(original, ShenShaResult.fromJson(original.toJson()));
  });
}
