import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_catalog.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_id.dart';

void main() {
  group('Full JiaZi Truth 60/60', () {
    test('Exact matches for all 60', () {
      final truth = [
        ['甲子', NaYinId.haiZhongJin, '海中�?], ['乙丑', NaYinId.haiZhongJin, '海中�?],
        ['丙寅', NaYinId.luZhongHuo, '炉中�?], ['丁卯', NaYinId.luZhongHuo, '炉中�?],
        ['戊辰', NaYinId.daLinMu, '大林�?], ['己巳', NaYinId.daLinMu, '大林�?],
        ['庚午', NaYinId.luPangTu, '路旁�?], ['辛未', NaYinId.luPangTu, '路旁�?],
        ['壬申', NaYinId.jianFengJin, '剑锋�?], ['癸酉', NaYinId.jianFengJin, '剑锋�?],

        ['甲戌', NaYinId.shanTouHuo, '山头�?], ['乙亥', NaYinId.shanTouHuo, '山头�?],
        ['丙子', NaYinId.jianXiaShui, '涧下�?], ['丁丑', NaYinId.jianXiaShui, '涧下�?],
        ['戊寅', NaYinId.chengTouTu, '城头�?], ['己卯', NaYinId.chengTouTu, '城头�?],
        ['庚辰', NaYinId.baiLaJin, '白蜡�?], ['辛巳', NaYinId.baiLaJin, '白蜡�?],
        ['壬午', NaYinId.yangLiuMu, '杨柳�?], ['癸未', NaYinId.yangLiuMu, '杨柳�?],

        ['甲申', NaYinId.quanZhongShui, '泉中�?], ['乙酉', NaYinId.quanZhongShui, '泉中�?],
        ['丙戌', NaYinId.wuShangTu, '屋上�?], ['丁亥', NaYinId.wuShangTu, '屋上�?],
        ['戊子', NaYinId.piLiHuo, '霹雳�?], ['己丑', NaYinId.piLiHuo, '霹雳�?],
        ['庚寅', NaYinId.songBaiMu, '松柏�?], ['辛卯', NaYinId.songBaiMu, '松柏�?],
        ['壬辰', NaYinId.changLiuShui, '长流�?], ['癸巳', NaYinId.changLiuShui, '长流�?],

        ['甲午', NaYinId.shaZhongJin, '沙中�?], ['乙未', NaYinId.shaZhongJin, '沙中�?],
        ['丙申', NaYinId.shanXiaHuo, '山下�?], ['丁酉', NaYinId.shanXiaHuo, '山下�?],
        ['戊戌', NaYinId.pingDiMu, '平地�?], ['己亥', NaYinId.pingDiMu, '平地�?],
        ['庚子', NaYinId.biShangTu, '壁上�?], ['辛丑', NaYinId.biShangTu, '壁上�?],
        ['壬寅', NaYinId.jinBoJin, '金箔�?], ['癸卯', NaYinId.jinBoJin, '金箔�?],

        ['甲辰', NaYinId.fuDengHuo, '佛灯�?], ['乙巳', NaYinId.fuDengHuo, '佛灯�?],
        ['丙午', NaYinId.tianHeShui, '天河�?], ['丁未', NaYinId.tianHeShui, '天河�?],
        ['戊申', NaYinId.daYiTu, '大驿�?], ['己酉', NaYinId.daYiTu, '大驿�?],
        ['庚戌', NaYinId.chaiChuanJin, '钗钏�?], ['辛亥', NaYinId.chaiChuanJin, '钗钏�?],
        ['壬子', NaYinId.sangZheMu, '桑柘�?], ['癸丑', NaYinId.sangZheMu, '桑柘�?],

        ['甲寅', NaYinId.daXiShui, '大溪�?], ['乙卯', NaYinId.daXiShui, '大溪�?],
        ['丙辰', NaYinId.shaZhongTu, '沙中�?], ['丁巳', NaYinId.shaZhongTu, '沙中�?],
        ['戊午', NaYinId.tianShangHuo, '天上�?], ['己未', NaYinId.tianShangHuo, '天上�?],
        ['庚申', NaYinId.shiLiuMu, '石榴�?], ['辛酉', NaYinId.shiLiuMu, '石榴�?],
        ['壬戌', NaYinId.daHaiShui, '大海�?], ['癸亥', NaYinId.daHaiShui, '大海�?],
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
