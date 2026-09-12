import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/hexagram_names.dart';
import 'package:guayan_trainer/domain/casting/najia.dart';
import 'package:guayan_trainer/domain/casting/palace.dart';
import 'package:guayan_trainer/domain/casting/six_relative.dart';
import 'package:guayan_trainer/domain/casting/six_spirit.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';
import 'package:guayan_trainer/domain/wu_xing.dart';

/// R3 排盘引擎 · 基础表与规则测试（八卦 / 64 卦 / 八宫世应 / 纳甲 / 六亲 / 六神）。
void main() {
  group('八卦', () {
    test('八经卦齐备，三爻自下而上', () {
      expect(Bagua.values, hasLength(8));
      expect(Bagua.qian.lines, [true, true, true]);
      expect(Bagua.kun.lines, [false, false, false]);
      // 震 = 初爻阳、二三爻阴；艮 = 初二三爻阴阴阳。
      expect(Bagua.zhen.lines, [true, false, false]);
      expect(Bagua.gen.lines, [false, false, true]);
      expect(Bagua.fromLines([false, false, true]), Bagua.gen);
    });

    test('八卦五行正确（乾兑金 离火 震巽木 坎水 艮坤土）', () {
      expect(
        {for (final b in Bagua.values) b.label: b.wuXing},
        {
          '乾': WuXing.jin,
          '兑': WuXing.jin,
          '离': WuXing.huo,
          '震': WuXing.mu,
          '巽': WuXing.mu,
          '坎': WuXing.shui,
          '艮': WuXing.tu,
          '坤': WuXing.tu,
        },
      );
    });
  });

  group('六十四卦表', () {
    test('8×8 全表齐备、卦名唯一', () {
      final names = <String>[];
      for (final upper in Bagua.values) {
        expect(hexagramNames[upper], hasLength(8), reason: '上卦 $upper 缺列');
        for (final lower in Bagua.values) {
          names.add(hexagramNameOf(upper, lower));
        }
      }
      expect(names, hasLength(64));
      expect(names.toSet(), hasLength(64), reason: '卦名重复');
    });

    test('抽样卦名正确', () {
      expect(hexagramNameOf(Bagua.qian, Bagua.qian), '乾为天');
      expect(hexagramNameOf(Bagua.kun, Bagua.kun), '坤为地');
      expect(hexagramNameOf(Bagua.dui, Bagua.gen), '泽山咸');
      expect(hexagramNameOf(Bagua.dui, Bagua.kan), '泽水困');
      expect(hexagramNameOf(Bagua.qian, Bagua.xun), '天风姤');
      expect(hexagramNameOf(Bagua.li, Bagua.qian), '火天大有');
    });
  });

  group('八宫与世应', () {
    test('64 卦齐备、六爻组合唯一、每宫 8 卦', () {
      expect(baGongTable, hasLength(64));
      final keys = baGongTable
          .map((e) => e.lines.map((b) => b ? '1' : '0').join())
          .toList();
      expect(keys.toSet(), hasLength(64), reason: '六爻组合重复');
      for (final palace in baGongOrder) {
        expect(
          baGongTable.where((e) => e.palace == palace),
          hasLength(8),
          reason: '$palace 宫卦数不为 8',
        );
      }
    });

    test('乾宫八卦顺序与世爻序列（本宫/一世..五世/游魂/归魂）', () {
      final qian = baGongTable.where((e) => e.palace == Bagua.qian).toList();
      expect(qian.map((e) => hexagramNameOf(e.upper, e.lower)), [
        '乾为天',
        '天风姤',
        '天山遁',
        '天地否',
        '风地观',
        '山地剥',
        '火地晋',
        '火天大有',
      ]);
      expect(qian.map((e) => e.shiPosition), [6, 1, 2, 3, 4, 5, 4, 3]);
    });

    test('兑宫八卦顺序（泽山咸为三世）', () {
      final dui = baGongTable.where((e) => e.palace == Bagua.dui).toList();
      expect(dui.map((e) => hexagramNameOf(e.upper, e.lower)), [
        '兑为泽',
        '泽水困',
        '泽地萃',
        '泽山咸',
        '水山蹇',
        '地山谦',
        '雷山小过',
        '雷泽归妹',
      ]);
      expect(dui[3].shiPosition, 3);
      expect(dui[3].yingPosition, 6);
    });

    test('世应恒相隔三位', () {
      for (final e in baGongTable) {
        expect(
          (e.shiPosition - e.yingPosition).abs(),
          3,
          reason: '${e.lines} 世应不相隔三',
        );
      }
    });
  });

  group('纳甲', () {
    test('乾坤内外卦地支（乾 子寅辰/午申戌、坤 未巳卯/丑亥酉）', () {
      expect(najiaLines(Bagua.qian, Bagua.qian), [
        DiZhi.zi,
        DiZhi.yin,
        DiZhi.chen,
        DiZhi.wu,
        DiZhi.shen,
        DiZhi.xu,
      ]);
      expect(najiaLines(Bagua.kun, Bagua.kun), [
        DiZhi.wei,
        DiZhi.si,
        DiZhi.mao,
        DiZhi.chou,
        DiZhi.hai,
        DiZhi.you,
      ]);
    });

    test('纳甲天干：乾纳甲壬、坤纳乙癸，其余内外同干', () {
      expect(najiaGans(Bagua.qian, Bagua.qian), [
        TianGan.jia,
        TianGan.jia,
        TianGan.jia,
        TianGan.ren,
        TianGan.ren,
        TianGan.ren,
      ]);
      expect(najiaGans(Bagua.kan, Bagua.li), [
        TianGan.wu,
        TianGan.wu,
        TianGan.wu,
        TianGan.ji,
        TianGan.ji,
        TianGan.ji,
      ]);
    });

    test('异卦上下装卦：泽山咸 = 下艮(丙辰午申) + 上兑(丁亥酉未)', () {
      final branches = najiaLines(Bagua.gen, Bagua.dui);
      final gans = najiaGans(Bagua.gen, Bagua.dui);
      expect(
        [for (var i = 0; i < 6; i++) '${gans[i].label}${branches[i].label}'],
        ['丙辰', '丙午', '丙申', '丁亥', '丁酉', '丁未'],
      );
    });
  });

  group('六亲', () {
    test('乾为天六亲（宫金：水子孙 木妻财 土父母 火官鬼 金兄弟）', () {
      const palace = Bagua.qian;
      expect(sixRelativeOf(palace, DiZhi.zi), SixRelative.ziSun);
      expect(sixRelativeOf(palace, DiZhi.yin), SixRelative.qiCai);
      expect(sixRelativeOf(palace, DiZhi.chen), SixRelative.fuMu);
      expect(sixRelativeOf(palace, DiZhi.wu), SixRelative.guanGui);
      expect(sixRelativeOf(palace, DiZhi.shen), SixRelative.xiongDi);
      expect(sixRelativeOf(palace, DiZhi.xu), SixRelative.fuMu);
    });
  });

  group('六神', () {
    test('按日干起例：甲青龙 / 己螣蛇 / 庚白虎 / 癸玄武', () {
      expect(sixSpiritsFor(TianGan.jia).first, SixSpirit.qingLong);
      expect(sixSpiritsFor(TianGan.yi).first, SixSpirit.qingLong);
      expect(sixSpiritsFor(TianGan.bing).first, SixSpirit.zhuQue);
      expect(sixSpiritsFor(TianGan.wu).first, SixSpirit.gouChen);
      expect(sixSpiritsFor(TianGan.ji).first, SixSpirit.tengShe);
      expect(sixSpiritsFor(TianGan.geng).first, SixSpirit.baiHu);
      expect(sixSpiritsFor(TianGan.gui).first, SixSpirit.xuanWu);
    });

    test('自初爻向上顺排，六爻恰配满一轮', () {
      final spirits = sixSpiritsFor(TianGan.geng); // 庚 → 初爻白虎
      expect(spirits.map((s) => s.label), ['白虎', '玄武', '青龙', '朱雀', '勾陈', '螣蛇']);
      expect(spirits.toSet(), hasLength(6));
    });
  });
}
