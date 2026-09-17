/// 审卦卦盘表头与爻行共用的设计坐标。
class BoardColumnLayout {
  BoardColumnLayout._();

  static const width = 402.0;
  static const sixSpiritLeft = 18.0;
  static const sixSpiritWidth = 26.0;
  static const primaryHiddenLeft = 44.0;
  static const primaryHiddenWidth = 42.0;
  static const oppositeHiddenLeft = 88.0;
  static const oppositeHiddenWidth = 42.0;
  static const mainTextLeft = 136.0;
  static const mainTextWidth = 64.0;
  static const mainYaoLeft = 226.0;
  static const mainShiYingLeft = 208.0;
  static const changedYaoLeft = 278.0;
  static const changedShiYingLeft = 306.0;
  static const changedValueLeft = 396.0;
  static const changedTextLeft = 278.0;
  static const changedTextWidth = 64.0;
  static const centralHeaderLeft = mainShiYingLeft;
  static const centralHeaderWidth = changedShiYingLeft + 14 - mainShiYingLeft;
  static const yaoGap = 8.0;
}
