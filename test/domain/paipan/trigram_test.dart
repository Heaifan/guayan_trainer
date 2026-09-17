/// 八卦编码真源测试（T1 · 独立人工冻结值，防「自己证明自己」）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/paipan/trigram.dart';
import 'package:guayan_trainer/domain/paipan/wuxing.dart';

void main() {
  group('八卦编码冻结（bit0 = 初爻，自下而上）', () {
    test('卦形 → 编码表人工冻结', () {
      final expected = <Trigram, List<bool>>{
        Trigram.qian: [true, true, true], // 乾：阳阳阳
        Trigram.dui: [true, true, false], // 兑：阳阳阴
        Trigram.li: [true, false, true], // 离：阳阴阳
        Trigram.zhen: [true, false, false], // 震：阳阴阴
        Trigram.xun: [false, true, true], // 巽：阴阳阳
        Trigram.kan: [false, true, false], // 坎：阴阳阴
        Trigram.gen: [false, false, true], // 艮：阴阴阳
        Trigram.kun: [false, false, false], // 坤：阴阴阴
      };
      expected.forEach((trigram, yangFlags) {
        for (var i = 0; i < 3; i++) {
          expect(trigram.yangAt(i), yangFlags[i],
              reason: '${trigram.name} 第 ${i + 1} 爻');
        }
      });
    });

    test('编码值唯一且恰为 0..7', () {
      final codes = Trigram.values.map((t) => t.code).toSet();
      expect(codes, hasLength(8));
      expect(codes, equals({0, 1, 2, 3, 4, 5, 6, 7}));
    });

    test('卦名与五行冻结', () {
      expect(Trigram.qian.name, '乾');
      expect(Trigram.dui.element, FiveElement.metal);
      expect(Trigram.li.element, FiveElement.fire);
      expect(Trigram.zhen.element, FiveElement.wood);
      expect(Trigram.xun.element, FiveElement.wood);
      expect(Trigram.kan.element, FiveElement.water);
      expect(Trigram.gen.element, FiveElement.earth);
      expect(Trigram.kun.element, FiveElement.earth);
    });

    test('fromCode 往返 + 越界拒绝', () {
      for (final t in Trigram.values) {
        expect(Trigram.fromCode(t.code), same(t));
      }
      expect(() => Trigram.fromCode(8), throwsArgumentError);
      expect(() => Trigram.fromCode(-1), throwsArgumentError);
    });
  });
}
