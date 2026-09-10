import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/calendar/day/xun_kong.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

/// T2 · 旬空测试。
///
/// 关键：不仅比对期望串，还独立验证「空亡 = 该旬十日未覆盖的两个地支」，
/// 避免实现与期望表同源而互相掩盖方向错误。
void main() {
  /// 六旬 → 旬首 / 空亡（任务书冻结值）。
  const expectations = <int, (String, String)>{
    0: ('甲子', '戌亥'),
    10: ('甲戌', '申酉'),
    20: ('甲申', '午未'),
    30: ('甲午', '辰巳'),
    40: ('甲辰', '寅卯'),
    50: ('甲寅', '子丑'),
  };

  test('六旬旬首与空亡与冻结值一致', () {
    expectations.forEach((head, exp) {
      final xk = xunKongOf(GanZhiDay.fromCycleIndex(head));
      expect(xk.xunHeadIndex, head);
      expect(xk.xunHeadLabel, exp.$1);
      expect(xk.label, exp.$2);
    });
  });

  test('完整 60 日循环：每日归旬正确、空亡恒为两个地支', () {
    var seen = <String>{};
    for (var c = 0; c < 60; c++) {
      final xk = xunKongOf(GanZhiDay.fromCycleIndex(c));
      final head = (c ~/ 10) * 10;
      expect(xk.xunHeadIndex, head, reason: '第 $c 日归旬错误');
      expect(xk.label, expectations[head]!.$2, reason: '第 $c 日空亡错误');
      expect(xk.first, isNot(xk.second));
      seen.add(xk.label);
    }
    expect(seen, hasLength(6), reason: '60 日应恰好归入六旬');
  });

  test('独立性质验证：空亡恰为该旬十日未覆盖的两个地支', () {
    for (var head = 0; head < 60; head += 10) {
      // 该旬十日的实际支序（由日柱自身推导，不引用旬空实现）。
      final covered = <DiZhi>{
        for (var i = 0; i < 10; i++) GanZhiDay.fromCycleIndex(head + i).zhi,
      };
      expect(covered, hasLength(10));

      final xk = xunKongOf(GanZhiDay.fromCycleIndex(head));
      final missing = DiZhi.values.where((z) => !covered.contains(z)).toList();
      expect(missing, hasLength(2));
      expect(
        {xk.first, xk.second},
        missing.toSet(),
        reason: '旬首 $head 的空亡与「未覆盖地支」不一致',
      );
      expect(xk.contains(missing[0]), isTrue);
      expect(xk.contains(missing[1]), isTrue);
    }
  });

  test('contains 对旬内四支返回 false', () {
    // 甲子旬（0..9）：支 子丑寅卯辰巳午未申酉，空 戌亥。
    final xk = xunKongOf(GanZhiDay.fromCycleIndex(0));
    for (var i = 0; i < 10; i++) {
      expect(xk.contains(GanZhiDay.fromCycleIndex(i).zhi), isFalse);
    }
    expect(xk.contains(DiZhi.xu), isTrue);
    expect(xk.contains(DiZhi.hai), isTrue);
  });
}
