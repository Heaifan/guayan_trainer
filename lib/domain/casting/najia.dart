/// 纳甲（京房纳甲）：八卦 → 六爻所值地支。
///
/// 装卦时，下卦（内卦）取该卦内三爻支，上卦（外卦）取该卦外三爻支。
/// 本表是爻支的唯一来源，禁止排盘引擎或 UI 自行推算地支。
library;

import '../di_zhi.dart';
import '../tian_gan.dart';
import 'bagua.dart';

/// 八卦纳甲表：每卦六爻地支，**自初爻至上爻**。
///
/// 前三位是该卦作内卦（下卦）时的初二三爻，
/// 后三位是该卦作外卦（上卦）时的四五六爻。
///
/// 例：乾纳甲壬 —— 内 子寅辰，外 午申戌。
const Map<Bagua, List<DiZhi>> najiaByBagua = {
  Bagua.qian: [DiZhi.zi, DiZhi.yin, DiZhi.chen, DiZhi.wu, DiZhi.shen, DiZhi.xu],
  Bagua.kun: [DiZhi.wei, DiZhi.si, DiZhi.mao, DiZhi.chou, DiZhi.hai, DiZhi.you],
  Bagua.zhen: [DiZhi.zi, DiZhi.yin, DiZhi.chen, DiZhi.wu, DiZhi.shen, DiZhi.xu],
  Bagua.xun: [DiZhi.chou, DiZhi.hai, DiZhi.you, DiZhi.wei, DiZhi.si, DiZhi.mao],
  Bagua.kan: [DiZhi.yin, DiZhi.chen, DiZhi.wu, DiZhi.shen, DiZhi.xu, DiZhi.zi],
  Bagua.li: [DiZhi.mao, DiZhi.chou, DiZhi.hai, DiZhi.you, DiZhi.wei, DiZhi.si],
  Bagua.gen: [DiZhi.chen, DiZhi.wu, DiZhi.shen, DiZhi.xu, DiZhi.zi, DiZhi.yin],
  Bagua.dui: [DiZhi.si, DiZhi.mao, DiZhi.chou, DiZhi.hai, DiZhi.you, DiZhi.wei],
};

/// 该卦作内卦（下卦，初二三爻）时的三支。
List<DiZhi> innerBranches(Bagua bagua) =>
    najiaByBagua[bagua]!.sublist(0, 3);

/// 该卦作外卦（上卦，四五六爻）时的三支。
List<DiZhi> outerBranches(Bagua bagua) =>
    najiaByBagua[bagua]!.sublist(3, 6);

/// 装卦：由下卦 + 上卦得到六爻地支（自初爻至上爻）。
List<DiZhi> najiaLines(Bagua lower, Bagua upper) => [
      ...innerBranches(lower),
      ...outerBranches(upper),
    ];

/// 纳甲天干：内卦干 / 外卦干。
///
/// 乾纳甲（内）壬（外）、坤纳乙（内）癸（外）；其余六卦内外同干。
const Map<Bagua, (TianGan, TianGan)> najiaGanByBagua = {
  Bagua.qian: (TianGan.jia, TianGan.ren),
  Bagua.kun: (TianGan.yi, TianGan.gui),
  Bagua.zhen: (TianGan.geng, TianGan.geng),
  Bagua.xun: (TianGan.xin, TianGan.xin),
  Bagua.kan: (TianGan.wu, TianGan.wu),
  Bagua.li: (TianGan.ji, TianGan.ji),
  Bagua.gen: (TianGan.bing, TianGan.bing),
  Bagua.dui: (TianGan.ding, TianGan.ding),
};

/// 装卦天干（自初爻至上爻）：内卦三爻用内干，外卦三爻用外干。
List<TianGan> najiaGans(Bagua lower, Bagua upper) {
  final inner = najiaGanByBagua[lower]!.$1;
  final outer = najiaGanByBagua[upper]!.$2;
  return [inner, inner, inner, outer, outer, outer];
}
