/// 八宫归属 + 世应测试（T2 · 8 宫 × 8 卦 = 64 完整性 + 人工冻结 Golden）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/paipan/gua/hexagram_identity.dart';
import 'package:guayan_trainer/domain/paipan/gua/palace.dart';
import 'package:guayan_trainer/domain/paipan/trigram.dart';
import 'package:guayan_trainer/domain/paipan/wuxing.dart';

void main() {
  group('八宫完整性（穷举 64）', () {
    test('64 卦每卦恰属一宫一阶段；8 宫 × 8 阶段恰各一次', () {
      final seen = <int>{};
      final pairCounts = <String, int>{};
      for (var bits = 0; bits < 64; bits++) {
        final info = classifyPalace(bits);
        seen.add(bits);
        final key = '${info.palaceTrigram.name}|${info.stage.name}';
        pairCounts[key] = (pairCounts[key] ?? 0) + 1;
      }
      expect(seen, hasLength(64));
      expect(pairCounts, hasLength(64));
      for (final e in pairCounts.entries) {
        expect(e.value, 1, reason: '${e.key} 出现 ${e.value} 次');
      }
    });

    test('每宫 8 阶段齐备且宫五行 = 本宫卦五行', () {
      final expectedElement = {
        '乾': FiveElement.metal, '兑': FiveElement.metal,
        '离': FiveElement.fire, '震': FiveElement.wood,
        '巽': FiveElement.wood, '坎': FiveElement.water,
        '艮': FiveElement.earth, '坤': FiveElement.earth,
      };
      for (final t in Trigram.values) {
        var count = 0;
        for (var bits = 0; bits < 64; bits++) {
          final info = classifyPalace(bits);
          if (info.palaceTrigram == t) {
            count++;
            expect(info.palaceElement, expectedElement[t.name]);
            expect(info.palaceName, '${t.name}宫');
          }
        }
        expect(count, 8, reason: '${t.name}宫应有 8 卦');
      }
    });

    test('世应位置契约冻结（阶段 → 世/应）', () {
      final expected = {
        PalaceStage.benGong: (6, 3),
        PalaceStage.yiShi: (1, 4),
        PalaceStage.erShi: (2, 5),
        PalaceStage.sanShi: (3, 6),
        PalaceStage.siShi: (4, 1),
        PalaceStage.wuShi: (5, 2),
        PalaceStage.youHun: (4, 1),
        PalaceStage.guiHun: (3, 6),
      };
      for (var bits = 0; bits < 64; bits++) {
        final info = classifyPalace(bits);
        final (shi, ying) = expected[info.stage]!;
        expect(info.shiPosition, shi, reason: '${info.palaceName} ${info.stage.label}');
        expect(info.yingPosition, ying, reason: '${info.palaceName} ${info.stage.label}');
      }
    });
  });

  group('Golden · 八纯卦（人工冻结）', () {
    test('卦名 / 宫 / 阶段 / 世应', () {
      final expected = {
        63: ('乾为天', '乾宫', PalaceStage.benGong),
        27: ('兑为泽', '兑宫', PalaceStage.benGong),
        45: ('离为火', '离宫', PalaceStage.benGong), // 下离上离
        9: ('震为雷', '震宫', PalaceStage.benGong),
        54: ('巽为风', '巽宫', PalaceStage.benGong), // 下巽上巽
        18: ('坎为水', '坎宫', PalaceStage.benGong), // 下坎上坎
        36: ('艮为山', '艮宫', PalaceStage.benGong), // 下艮上艮
        0: ('坤为地', '坤宫', PalaceStage.benGong),
      };
      expected.forEach((bits, value) {
        final (name, palace, stage) = value;
        final h = HexagramIdentity(bits);
        final info = classifyPalace(bits);
        expect(h.name, name, reason: 'bits=$bits');
        expect(info.palaceName, palace);
        expect(info.stage, stage);
      });
    });
  });

  group('Golden · 乾宫 / 坎宫八阶序列（人工冻结）', () {
    test('乾宫：姤一世 → 遁二世 → 否三世 → 观四世 → 剥五世 → 晋游魂 → 大有归魂', () {
      final expected = {
        '天风姤': PalaceStage.yiShi,
        '天山遁': PalaceStage.erShi,
        '天地否': PalaceStage.sanShi,
        '风地观': PalaceStage.siShi,
        '山地剥': PalaceStage.wuShi,
        '火地晋': PalaceStage.youHun,
        '火天大有': PalaceStage.guiHun,
      };
      expected.forEach((name, stage) {
        final bits = _bitsByName(name);
        final info = classifyPalace(bits);
        expect(info.palaceName, '乾宫', reason: name);
        expect(info.stage, stage, reason: name);
      });
    });

    test('坎宫：节一世 → 屯二世 → 既济三世 → 革四世 → 丰五世 → 明夷游魂 → 师归魂', () {
      final expected = {
        '水泽节': PalaceStage.yiShi,
        '水雷屯': PalaceStage.erShi,
        '水火既济': PalaceStage.sanShi,
        '泽火革': PalaceStage.siShi,
        '雷火丰': PalaceStage.wuShi,
        '地火明夷': PalaceStage.youHun,
        '地水师': PalaceStage.guiHun,
      };
      expected.forEach((name, stage) {
        final bits = _bitsByName(name);
        final info = classifyPalace(bits);
        expect(info.palaceName, '坎宫', reason: name);
        expect(info.stage, stage, reason: name);
      });
    });
  });
}

/// 由卦名反查 bits 的测试辅助（按上/下卦名拼 bits，仅测试用）。
int _bitsByName(String name) {
  for (var bits = 0; bits < 64; bits++) {
    if (HexagramIdentity(bits).name == name) return bits;
  }
  throw StateError('未知卦名：$name');
}
