/// 天干地支唯一真源（R6 排盘底盘）。
///
/// 地支 → 五行映射为本项目唯一真源（纳甲/六亲/关系引擎统一引用，禁止各自复制）：
/// 亥子水、寅卯木、巳午火、申酉金、辰戌丑未土。
library;

import 'wuxing.dart';

/// 十天干。
enum HeavenlyStem {
  jia('甲'),
  yi('乙'),
  bing('丙'),
  ding('丁'),
  wu('戊'),
  ji('己'),
  geng('庚'),
  xin('辛'),
  ren('壬'),
  gui('癸');

  const HeavenlyStem(this.label);

  final String label;

  static HeavenlyStem fromLabel(String label) => values.firstWhere(
        (s) => s.label == label,
        orElse: () => throw ArgumentError.value(label, 'label', '非法天干'),
      );
}

/// 十二地支（携带五行唯一映射）。
enum EarthlyBranch {
  zi('子', FiveElement.water),
  chou('丑', FiveElement.earth),
  yin('寅', FiveElement.wood),
  mao('卯', FiveElement.wood),
  chen('辰', FiveElement.earth),
  si('巳', FiveElement.fire),
  wu('午', FiveElement.fire),
  wei('未', FiveElement.earth),
  shen('申', FiveElement.metal),
  you('酉', FiveElement.metal),
  xu('戌', FiveElement.earth),
  hai('亥', FiveElement.water);

  const EarthlyBranch(this.label, this.element);

  final String label;

  /// 地支五行（唯一真源，禁止在别处重建映射）。
  final FiveElement element;

  static EarthlyBranch fromLabel(String label) => values.firstWhere(
        (b) => b.label == label,
        orElse: () => throw ArgumentError.value(label, 'label', '非法地支'),
      );
}
