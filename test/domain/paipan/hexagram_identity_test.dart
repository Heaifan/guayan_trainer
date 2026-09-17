/// 六十四卦结构身份穷举测试（T1 · 64 输入 → 64 唯一身份 → 0 重复 0 缺失）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/paipan/gua/hexagram_identity.dart';
import 'package:guayan_trainer/domain/paipan/gua/hexagram_names.dart';
import 'package:guayan_trainer/domain/paipan/trigram.dart';

void main() {
  group('位契约（显式端序）', () {
    test('bit0 = 初爻：0b000001 只有初爻为阳', () {
      final h = HexagramIdentity(1); // 0b000001
      expect(h.yangAt(1), isTrue);
      for (var p = 2; p <= 6; p++) {
        expect(h.yangAt(p), isFalse, reason: 'position $p');
      }
      expect(h.lowerTrigram, same(Trigram.zhen)); // 初爻阳、二/三爻阴 → 震
      expect(h.upperTrigram, same(Trigram.kun));
    });

    test('fromYangFlags：自下而上序列', () {
      // 天风姤：下巽（阴阳阳）上乾（阳阳阳）。
      final h = HexagramIdentity.fromYangFlags(
        [false, true, true, true, true, true],
      );
      expect(h.bits, 62); // 0b111110
      expect(h.name, '天风姤');
    });

    test('fromTrigrams 往返', () {
      final h = HexagramIdentity.fromTrigrams(
        upper: Trigram.qian,
        lower: Trigram.xun,
      );
      expect(h.lowerTrigram, same(Trigram.xun));
      expect(h.upperTrigram, same(Trigram.qian));
      expect(h.bits, 62);
    });

    test('构造越界 / 爻数错误拒绝', () {
      expect(() => HexagramIdentity(64), throwsArgumentError);
      expect(() => HexagramIdentity(-1), throwsArgumentError);
      expect(
        () => HexagramIdentity.fromYangFlags([true, true, true]),
        throwsArgumentError,
      );
    });
  });

  group('64 卦穷举', () {
    test('2^6 = 64 输入 → 64 有效身份 → 64 唯一卦名（0 重复 0 缺失）', () {
      final names = <String>{};
      for (var bits = 0; bits < 64; bits++) {
        final h = HexagramIdentity(bits);
        expect(h.name, isNotEmpty, reason: 'bits=$bits 卦名缺失');
        names.add(h.name);
      }
      expect(names, hasLength(64), reason: '卦名必须两两不同');
      expect(hexagramNames, hasLength(64));
    });

    test('decode(encode(identity)) == identity（64 组全验）', () {
      for (var bits = 0; bits < 64; bits++) {
        final h = HexagramIdentity(bits);
        final rebuilt = HexagramIdentity.fromTrigrams(
          upper: h.upperTrigram,
          lower: h.lowerTrigram,
        );
        expect(rebuilt.bits, bits, reason: 'bits=$bits 往返失配');
        final flags =
            List<bool>.generate(6, (i) => h.yangAt(i + 1));
        expect(HexagramIdentity.fromYangFlags(flags).bits, bits,
            reason: 'bits=$bits 阴阳序列往返失配');
      }
    });

    test('八卦代表性卦名抽检（人工冻结）', () {
      final expected = {
        63: '乾为天', // 全阳
        0: '坤为地', // 全阴
        62: '天风姤', // 上乾下巽
        40: '火地晋', // 上离下坤
        27: '兑为泽', // 上兑下兑
        47: '火天大有', // 上离下乾
        9: '震为雷', // 上震下震
        26: '泽水困', // 上兑下坎（审卦演示卦）
        28: '泽山咸', // 上兑下艮（审卦演示卦）
      };
      expected.forEach((bits, name) {
        expect(HexagramIdentity(bits).name, name, reason: 'bits=$bits');
      });
    });
  });
}
