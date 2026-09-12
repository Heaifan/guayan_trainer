/// 五行领域模型（纯 Dart，零 Flutter / 零外部依赖）。
///
/// R3 排盘引擎的基础：六亲、纳音、旺衰全部以五行为唯一坐标，
/// 因此生克关系必须只有一处定义，禁止各模块自行硬编码。
library;

/// 五行。
enum WuXing {
  mu('木'),
  huo('火'),
  tu('土'),
  jin('金'),
  shui('水');

  const WuXing(this.label);

  /// 中文名，如「木」。
  final String label;

  /// 我生者（相生：木→火→土→金→水→木）。
  WuXing get generates => switch (this) {
    WuXing.mu => WuXing.huo,
    WuXing.huo => WuXing.tu,
    WuXing.tu => WuXing.jin,
    WuXing.jin => WuXing.shui,
    WuXing.shui => WuXing.mu,
  };

  /// 我克者（相克：木克土、土克水、水克火、火克金、金克木）。
  WuXing get controls => switch (this) {
    WuXing.mu => WuXing.tu,
    WuXing.tu => WuXing.shui,
    WuXing.shui => WuXing.huo,
    WuXing.huo => WuXing.jin,
    WuXing.jin => WuXing.mu,
  };

  /// 生我者。
  WuXing get generatedBy =>
      WuXing.values.firstWhere((e) => e.generates == this);

  /// 克我者。
  WuXing get controlledBy =>
      WuXing.values.firstWhere((e) => e.controls == this);

  /// 与我（[self]）的关系分类 —— 六亲判定唯一入口。
  ///
  /// 调用形如 `other.relationTo(self)`：`this` 是待判五行（爻支五行），
  /// `self` 是「我」（卦宫五行）。返回的是**从「我」的视角**看的类别，
  /// 因此「我生」与「生我」不可对调（对调即六亲子孙/父母颠倒）。
  WuXingRelation relationTo(WuXing self) {
    if (self == this) return WuXingRelation.same;
    // 我（self）生 this → 我生。
    if (self.generates == this) return WuXingRelation.iGenerate;
    // this 生我（self）→ 生我。
    if (generates == self) return WuXingRelation.generatesMe;
    // 我（self）克 this → 我克。
    if (self.controls == this) return WuXingRelation.iControl;
    // this 克我（self）→ 克我。
    if (controls == self) return WuXingRelation.controlsMe;
    throw StateError('五行关系无法分类：$self vs $this');
  }
}

/// 五行之间的五种关系（六亲映射的中间表示）。
enum WuXingRelation {
  /// 同我（比和）。
  same,

  /// 生我。
  generatesMe,

  /// 我生。
  iGenerate,

  /// 克我。
  controlsMe,

  /// 我克。
  iControl,
}
