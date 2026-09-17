/// 五行唯一真源（R6 排盘底盘）。
///
/// 生克方向契约：[generates] = 我生、[overcomes] = 我克、
/// [generatedBy] = 生我、[overcomeBy] = 克我。
/// 生序：木→火→土→金→水→木；克序：木克土、土克水、水克火、火克金、金克木。
/// 禁止其他模块自建五行生克表。
library;

/// 五行。
enum FiveElement {
  wood('木'),
  fire('火'),
  earth('土'),
  metal('金'),
  water('水');

  const FiveElement(this.label);

  final String label;

  /// 我生者（木生火、火生土、土生金、金生水、水生木）。
  FiveElement get generates => FiveElement.values[(index + 1) % 5];

  /// 我克者（木克土、土克水、水克火、火克金、金克木）。
  FiveElement get overcomes => FiveElement.values[(index + 2) % 5];

  /// 生我者。
  FiveElement get generatedBy => FiveElement.values[(index + 4) % 5];

  /// 克我者。
  FiveElement get overcomeBy => FiveElement.values[(index + 3) % 5];
}
