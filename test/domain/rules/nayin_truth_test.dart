import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_catalog.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_id.dart';

void main() {
  group('Full JiaZi Truth 60/60', () {
    test('Exact matches for all 60', () {
      final truth = [
        ['甲子', NaYinId.haiZhongJin, '海中金'], ['乙丑', NaYinId.haiZhongJin, '海中金'],
        ['丙寅', NaYinId.luZhongHuo, '炉中火'], ['丁卯', NaYinId.luZhongHuo, '炉中火'],
        ['戊辰', NaYinId.daLinMu, '大林木'], ['己巳', NaYinId.daLinMu, '大林木'],
        ['庚午', NaYinId.luPangTu, '路旁土'], ['辛未', NaYinId.luPangTu, '路旁土'],
        ['壬申', NaYinId.jianFengJin, '剑锋金'], ['癸酉', NaYinId.jianFengJin, '剑锋金'],

        ['甲戌', NaYinId.shanTouHuo, '山头火'], ['乙亥', NaYinId.shanTouHuo, '山头火'],
        ['丙子', NaYinId.jianXiaShui, '涧下水'], ['丁丑', NaYinId.jianXiaShui, '涧下水'],
        ['戊寅', NaYinId.chengTouTu, '城头土'], ['己卯', NaYinId.chengTouTu, '城头土'],
        ['庚辰', NaYinId.baiLaJin, '白蜡金'], ['辛巳', NaYinId.baiLaJin, '白蜡金'],
        ['壬午', NaYinId.yangLiuMu, '杨柳木'], ['癸未', NaYinId.yangLiuMu, '杨柳木'],

        ['甲申', NaYinId.quanZhongShui, '泉中水'], ['乙酉', NaYinId.quanZhongShui, '泉中水'],
        ['丙戌', NaYinId.wuShangTu, '屋上土'], ['丁亥', NaYinId.wuShangTu, '屋上土'],
        ['戊子', NaYinId.piLiHuo, '霹雳火'], ['己丑', NaYinId.piLiHuo, '霹雳火'],
        ['庚寅', NaYinId.songBaiMu, '松柏木'], ['辛卯', NaYinId.songBaiMu, '松柏木'],
        ['壬辰', NaYinId.changLiuShui, '长流水'], ['癸巳', NaYinId.changLiuShui, '长流水'],

        ['甲午', NaYinId.shaZhongJin, '沙中金'], ['乙未', NaYinId.shaZhongJin, '沙中金'],
        ['丙申', NaYinId.shanXiaHuo, '山下火'], ['丁酉', NaYinId.shanXiaHuo, '山下火'],
        ['戊戌', NaYinId.pingDiMu, '平地木'], ['己亥', NaYinId.pingDiMu, '平地木'],
        ['庚子', NaYinId.biShangTu, '壁上土'], ['辛丑', NaYinId.biShangTu, '壁上土'],
        ['壬寅', NaYinId.jinBoJin, '金箔金'], ['癸卯', NaYinId.jinBoJin, '金箔金'],

        ['甲辰', NaYinId.fuDengHuo, '佛灯火'], ['乙巳', NaYinId.fuDengHuo, '佛灯火'],
        ['丙午', NaYinId.tianHeShui, '天河水'], ['丁未', NaYinId.tianHeShui, '天河水'],
        ['戊申', NaYinId.daYiTu, '大驿土'], ['己酉', NaYinId.daYiTu, '大驿土'],
        ['庚戌', NaYinId.chaiChuanJin, '钗钏金'], ['辛亥', NaYinId.chaiChuanJin, '钗钏金'],
        ['壬子', NaYinId.sangZheMu, '桑柘木'], ['癸丑', NaYinId.sangZheMu, '桑柘木'],

        ['甲寅', NaYinId.daXiShui, '大溪水'], ['乙卯', NaYinId.daXiShui, '大溪水'],
        ['丙辰', NaYinId.shaZhongTu, '沙中土'], ['丁巳', NaYinId.shaZhongTu, '沙中土'],
        ['戊午', NaYinId.tianShangHuo, '天上火'], ['己未', NaYinId.tianShangHuo, '天上火'],
        ['庚申', NaYinId.shiLiuMu, '石榴木'], ['辛酉', NaYinId.shiLiuMu, '石榴木'],
        ['壬戌', NaYinId.daHaiShui, '大海水'], ['癸亥', NaYinId.daHaiShui, '大海水'],
      ];

      for (int i = 0; i < 60; i++) {
        final label = GanZhiDay.fromCycleIndex(i).label;
        final entry = NaYinCatalog.getByJiaZiIndex(i);
        final expected = truth[i];

        expect(label, expected[0]);
        expect(entry.id, expected[1]);
        expect(entry.name, expected[2]);
      }
    });
  });
}
