/// R4 基础关系引擎 · 九类关系与端点不变量。
///
/// 受控用例见 `domain_test_utils.buildR4Case`；
/// 五行事实关系与月建/日辰的组成见 `relation_engine_r4_facts_test.dart`。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

import 'domain_test_utils.dart';

void main() {
  final all = calculateRelations(buildR4Case());

  group('R4 · 九类关系全部产出', () {
    test('§12.1 第一批九类的规则 id 都出现在账本里', () {
      final rules = all.map((r) => r.key.ruleId).toSet();
      for (final id in <String>[
        SystemRuleIds.dongBian,
        SystemRuleIds.liuChong,
        SystemRuleIds.liuHe,
        SystemRuleIds.sheng,
        SystemRuleIds.ke,
        SystemRuleIds.huiTouSheng,
        SystemRuleIds.huiTouKe,
        SystemRuleIds.monthBranch,
        SystemRuleIds.dayBranch,
      ]) {
        expect(rules, contains(id), reason: '缺少规则 $id');
      }
    });

    test('动变：两条动爻，本卦 p → 变卦 p', () {
      expect(canonicalsOf(all, SystemRuleIds.dongBian), {
        'dong_bian|sys.dong_bian|v1|-|yao:original:3->yao:changed:3',
        'dong_bian|sys.dong_bian|v1|-|yao:original:5->yao:changed:5',
      });
    });

    test('六冲 / 六合：卯酉冲（3-5）、辰酉合（2-5）', () {
      expect(canonicalsOf(all, SystemRuleIds.liuChong), {
        'liu_chong|sys.liu_chong|v1|-|yao:original:3<->yao:original:5',
      });
      expect(canonicalsOf(all, SystemRuleIds.liuHe), {
        'liu_he|sys.liu_he|v1|-|yao:original:2<->yao:original:5',
      });
    });

    test('回头生 / 回头克：方向恒为 变爻 → 本爻', () {
      // 三爻：变申(金) 克 卯(木) → 回头克；五爻：变丑(土) 生 酉(金) → 回头生。
      expect(canonicalsOf(all, SystemRuleIds.huiTouKe), {
        'hui_tou_ke|sys.hui_tou_ke|v1|-|yao:changed:3->yao:original:3',
      });
      expect(canonicalsOf(all, SystemRuleIds.huiTouSheng), {
        'hui_tou_sheng|sys.hui_tou_sheng|v1|-|yao:changed:5->yao:original:5',
      });
    });
  });

  group('R4 · 端点不变量', () {
    test('爻端点仍校验 1..6', () {
      expect(() => YaoEndpoint(LineScope.original, 0), throwsArgumentError);
      expect(() => YaoEndpoint(LineScope.changed, 7), throwsArgumentError);
    });

    test('canonical 升序（确定性输出）', () {
      final list = all.map((r) => r.key.canonical).toList();
      final sorted = [...list]..sort();
      expect(list, sorted);
    });
  });
}
