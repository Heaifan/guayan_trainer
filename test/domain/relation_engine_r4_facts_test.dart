/// R4 基础关系引擎 · 五行事实关系与月建/日辰作用。
///
/// 受控用例见 `domain_test_utils.buildR4Case`（亥辰卯午酉丑，三/五爻动）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

import 'domain_test_utils.dart';

void main() {
  final all = calculateRelations(buildR4Case());

  group('R4 · 五行事实关系（本卦六爻两两穷举）', () {
    test('C(6,2)=15 对中，除同五行一对外全部产出，共 14 条', () {
      final total =
          canonicalsOf(all, SystemRuleIds.sheng).length +
          canonicalsOf(all, SystemRuleIds.ke).length;
      expect(total, 14);
    });

    test('同五行的一对（辰土 / 丑土）不产生生克', () {
      for (final c in [
        ...canonicalsOf(all, SystemRuleIds.sheng),
        ...canonicalsOf(all, SystemRuleIds.ke),
      ]) {
        expect(
          c.contains('yao:original:2') && c.contains('yao:original:6'),
          isFalse,
        );
      }
    });

    test('方向正确：亥水生卯木、亥水克午火', () {
      expect(
        canonicalsOf(all, SystemRuleIds.sheng),
        contains('sheng|sys.sheng|v1|-|yao:original:1->yao:original:3'),
      );
      expect(
        canonicalsOf(all, SystemRuleIds.ke),
        contains('ke|sys.ke|v1|-|yao:original:1->yao:original:4'),
      );
    });

    test('静爻与静爻之间同样产出事实关系（本层不判断作用力）', () {
      // 二爻辰土（静）克 一爻亥水（静）—— 事实存在，是否「真起作用」属作用层。
      expect(
        canonicalsOf(all, SystemRuleIds.ke),
        contains('ke|sys.ke|v1|-|yao:original:2->yao:original:1'),
      );
    });
  });

  group('R4 · 月建 / 日辰基础作用', () {
    test('月建寅木：生午火、克辰土与丑土，共 3 条', () {
      expect(canonicalsOf(all, SystemRuleIds.monthBranch), {
        'sheng|sys.month_branch|v1|-|month->yao:original:4',
        'ke|sys.month_branch|v1|-|month->yao:original:2',
        'ke|sys.month_branch|v1|-|month->yao:original:6',
      });
    });

    test('日辰甲子（日支子水）：生卯木、克午火，共 2 条', () {
      expect(canonicalsOf(all, SystemRuleIds.dayBranch), {
        'sheng|sys.day_branch|v1|-|day->yao:original:3',
        'ke|sys.day_branch|v1|-|day->yao:original:4',
      });
    });

    test('端点不是爻：month / day 没有 position，也不伪装成 month-1', () {
      final month = all.firstWhere(
        (r) => r.key.ruleId == SystemRuleIds.monthBranch,
      );
      expect(month.source, isA<MonthEndpoint>());
      expect(month.source.semanticId, 'month');
      final day = all.firstWhere(
        (r) => r.key.ruleId == SystemRuleIds.dayBranch,
      );
      expect(day.source, isA<DayEndpoint>());
      expect(day.source.semanticId, 'day');
    });
  });
}
