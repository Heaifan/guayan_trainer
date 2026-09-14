library;

import 'nayin_id.dart';
import 'nayin_entry.dart';

/// 六十甲子 -> 三十纳音 映射
class NaYinCatalog {
  static const List<NaYinEntry> _entries = [
    NaYinEntry(NaYinId.haiZhongJin, '海中金'),
    NaYinEntry(NaYinId.luZhongHuo, '炉中火'),
    NaYinEntry(NaYinId.daLinMu, '大林木'),
    NaYinEntry(NaYinId.luPangTu, '路旁土'),
    NaYinEntry(NaYinId.jianFengJin, '剑锋金'),
    
    NaYinEntry(NaYinId.shanTouHuo, '山头火'),
    NaYinEntry(NaYinId.jianXiaShui, '涧下水'),
    NaYinEntry(NaYinId.chengTouTu, '城头土'),
    NaYinEntry(NaYinId.baiLaJin, '白蜡金'),
    NaYinEntry(NaYinId.yangLiuMu, '杨柳木'),
    
    NaYinEntry(NaYinId.quanZhongShui, '泉中水'),
    NaYinEntry(NaYinId.wuShangTu, '屋上土'),
    NaYinEntry(NaYinId.piLiHuo, '霹雳火'),
    NaYinEntry(NaYinId.songBaiMu, '松柏木'),
    NaYinEntry(NaYinId.changLiuShui, '长流水'),
    
    NaYinEntry(NaYinId.shaZhongJin, '沙中金'),
    NaYinEntry(NaYinId.shanXiaHuo, '山下火'),
    NaYinEntry(NaYinId.pingDiMu, '平地木'),
    NaYinEntry(NaYinId.biShangTu, '壁上土'),
    NaYinEntry(NaYinId.jinBoJin, '金箔金'),
    
    NaYinEntry(NaYinId.fuDengHuo, '佛灯火'),
    NaYinEntry(NaYinId.tianHeShui, '天河水'),
    NaYinEntry(NaYinId.daYiTu, '大驿土'),
    NaYinEntry(NaYinId.chaiChuanJin, '钗钏金'),
    NaYinEntry(NaYinId.sangZheMu, '桑柘木'),
    
    NaYinEntry(NaYinId.daXiShui, '大溪水'),
    NaYinEntry(NaYinId.shaZhongTu, '沙中土'),
    NaYinEntry(NaYinId.tianShangHuo, '天上火'),
    NaYinEntry(NaYinId.shiLiuMu, '石榴木'),
    NaYinEntry(NaYinId.daHaiShui, '大海水'),
  ];

  /// 通过六十甲子序号 (0-59) 获取纳音，相邻两个甲子共用一个纳音
  static NaYinEntry getByJiaZiIndex(int index) {
    if (index < 0 || index > 59) {
      throw ArgumentError.value(index, 'index', '六十甲子序号必须在 0..59 之间');
    }
    return _entries[index ~/ 2];
  }

  static Iterable<NaYinEntry> get all => _entries;
}
