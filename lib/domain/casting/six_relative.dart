/// 六亲：以**宫位五行**为「我」，判定每爻地支与我的生克类别。
///
/// 注意「我」取的是卦所属宫的五行，不是爻所在卦（本卦/变卦）本体的五行。
/// 变卦六亲同样以**本卦**之宫为「我」，这是传统排盘的固定规则。
library;

import '../di_zhi.dart';
import '../wu_xing.dart';
import 'bagua.dart';

/// 六亲。
enum SixRelative {
  fuMu('父母'),
  xiongDi('兄弟'),
  ziSun('子孙'),
  guanGui('官鬼'),
  qiCai('妻财');

  const SixRelative(this.label);

  /// 中文名，如「父母」。
  final String label;

  /// 由「我」与「所判者」的五行关系映射六亲（唯一入口）。
  ///
  /// [self] = 我（宫位五行），[other] = 待判五行（爻支五行）。
  static SixRelative of(WuXing self, WuXing other) =>
      switch (other.relationTo(self)) {
        WuXingRelation.generatesMe => SixRelative.fuMu,
        WuXingRelation.same => SixRelative.xiongDi,
        WuXingRelation.iGenerate => SixRelative.ziSun,
        WuXingRelation.controlsMe => SixRelative.guanGui,
        WuXingRelation.iControl => SixRelative.qiCai,
      };
}

/// 由宫位与地支判定六亲。
SixRelative sixRelativeOf(Bagua palace, DiZhi branch) =>
    SixRelative.of(palace.wuXing, branch.wuXing);
