/// R4 基础关系引擎 · 缺失输入与确定性（「缺失不得静默」的可判定口径）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

import 'domain_test_utils.dart';

void main() {
  group('R4 · 缺失输入必须显式报告', () {
    test('无历法快照：不产出月建 / 日辰关系，并报告缺失', () {
      final result = calculateRelationResult(buildR4Case(calendar: null));
      final rules = result.instances.map((r) => r.key.ruleId).toSet();
      expect(rules, isNot(contains(SystemRuleIds.monthBranch)));
      expect(rules, isNot(contains(SystemRuleIds.dayBranch)));
      expect(
        result.diagnostics.missingInputs,
        containsAll(<String>['calendar.monthBranch', 'calendar.dayBranch']),
      );
      // 其余家族照常产出 —— 缺快照不影响与本卦自身有关的关系。
      expect(rules, contains(SystemRuleIds.dongBian));
      expect(rules, contains(SystemRuleIds.liuChong));
    });

    test('无变爻地支：不产出回头生 / 回头克，只保留动变，并报告缺失', () {
      final result = calculateRelationResult(
        buildR4Case(withChangedBranch: false),
      );
      final rules = result.instances.map((r) => r.key.ruleId).toSet();
      expect(rules, contains(SystemRuleIds.dongBian));
      expect(rules, isNot(contains(SystemRuleIds.huiTouSheng)));
      expect(rules, isNot(contains(SystemRuleIds.huiTouKe)));
      expect(
        result.diagnostics.missingInputs,
        containsAll(<String>['line[3].changedBranch', 'line[5].changedBranch']),
      );
    });

    test('完整输入时诊断无缺失、无警告', () {
      final result = calculateRelationResult(buildR4Case());
      expect(result.diagnostics.missingInputs, isEmpty);
      expect(result.diagnostics.warnings, isEmpty);
      expect(result.diagnostics.isComplete, isTrue);
    });
  });

  group('R4 · 确定性契约', () {
    test('相同 HexagramCase => 相同 RelationInstance 集合（含顺序）', () {
      final c = buildR4Case();
      final a = calculateRelations(c).map((r) => r.key.canonical).toList();
      final b = calculateRelations(c).map((r) => r.key.canonical).toList();
      expect(a, b);
    });

    test('canonical 无重复（规则之间不互相踩）', () {
      final list = calculateRelations(buildR4Case());
      final set = list.map((r) => r.key.canonical).toSet();
      expect(set.length, list.length);
    });

    test('账本是全量事实：静卦（无动爻）仍产出五行与冲合关系', () {
      final result = calculateRelationResult(
        buildR4Case(withMoving: false, calendar: null),
      );
      final rules = result.instances.map((r) => r.key.ruleId).toSet();
      expect(rules, contains(SystemRuleIds.sheng));
      expect(rules, contains(SystemRuleIds.ke));
      expect(rules, contains(SystemRuleIds.liuChong));
      expect(rules, contains(SystemRuleIds.liuHe));
      // 静卦没有动爻，因此既无动变也无回头生克。
      expect(rules, isNot(contains(SystemRuleIds.dongBian)));
      expect(rules, isNot(contains(SystemRuleIds.huiTouSheng)));
      expect(rules, isNot(contains(SystemRuleIds.huiTouKe)));
    });
  });
}
