/// 二十四节气标识：中文名 + 太阳黄经 + 是否为「节」。
///
/// 枚举顺序 = 公历年内顺序（自小寒起，冬至止），因此
/// `index` 同时也是该节气在某一年内的位次。
///
/// 「节」与「气」交替：**十二「节」是月建的分界**，
/// 十二「气」不改变月建（但未来供旺衰、神煞等模块复用）。
library;

import '../../di_zhi.dart';

/// 二十四节气。
enum SolarTermId {
  xiaoHan('小寒', 285, DiZhi.chou),
  daHan('大寒', 300, null),
  liChun('立春', 315, DiZhi.yin),
  yuShui('雨水', 330, null),
  jingZhe('惊蛰', 345, DiZhi.mao),
  chunFen('春分', 0, null),
  qingMing('清明', 15, DiZhi.chen),
  guYu('谷雨', 30, null),
  liXia('立夏', 45, DiZhi.si),
  xiaoMan('小满', 60, null),
  mangZhong('芒种', 75, DiZhi.wu),
  xiaZhi('夏至', 90, null),
  xiaoShu('小暑', 105, DiZhi.wei),
  daShu('大暑', 120, null),
  liQiu('立秋', 135, DiZhi.shen),
  chuShu('处暑', 150, null),
  baiLu('白露', 165, DiZhi.you),
  qiuFen('秋分', 180, null),
  hanLu('寒露', 195, DiZhi.xu),
  shuangJiang('霜降', 210, null),
  liDong('立冬', 225, DiZhi.hai),
  xiaoXue('小雪', 240, null),
  daXue('大雪', 255, DiZhi.zi),
  dongZhi('冬至', 270, null);

  const SolarTermId(this.label, this.longitude, this.monthBranch);

  /// 中文名，如「立春」。
  final String label;

  /// 太阳黄经（度）：春分 = 0、立春 = 315、冬至 = 270。
  final int longitude;

  /// 若本气节是「节」，则为其所开启的月建；「气」为 null。
  final DiZhi? monthBranch;

  /// 是否为「节」（月建分界）。
  bool get isMonthStart => monthBranch != null;

  /// 十二「节」，按公历年内顺序（小寒、立春、…、大雪）。
  static List<SolarTermId> get monthStartTerms =>
      SolarTermId.values.where((t) => t.isMonthStart).toList();
}
