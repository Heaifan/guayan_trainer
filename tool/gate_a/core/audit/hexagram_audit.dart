/// 卦体属性旁证：六冲 / 六合 判定 + 卦体标签。
///
/// 六冲 / 六合 并非 R3 冻结范围，但 GA-1 要求案例覆盖它们，
/// 因此需要一处**可复核的判定**，而不是手感分类。
///
/// 结构自检的两项独立复核已各自成文件，仍由本文件统一转出：
/// `palace_audit.dart`（八宫表完整性）、`najia_audit.dart`（纳甲组装顺序）。
library;

import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

export 'najia_audit.dart';
export 'palace_audit.dart';

/// 六爻地支自初爻至上爻。
List<DiZhi> branchesOf(CastChart chart) => [
  for (final line in chart.lines) line.branch,
];

/// 六冲卦：六爻地支两两相冲（3 对互不相交的冲对）。
bool isLiuChongBranches(List<DiZhi> branches) {
  if (branches.length != 6) return false;
  final seen = <DiZhi>{};
  var pairs = 0;
  for (final z in branches) {
    if (!seen.add(z)) return false;
    if (seen.contains(z.chong)) pairs++;
  }
  return pairs == 3;
}

/// 六合卦：六爻地支两两相合（3 对互不相交的合对）。
bool isLiuHeBranches(List<DiZhi> branches) {
  if (branches.length != 6) return false;
  final seen = <DiZhi>{};
  var pairs = 0;
  for (final z in branches) {
    if (!seen.add(z)) return false;
    if (seen.contains(z.he)) pairs++;
  }
  return pairs == 3;
}

/// 卦体标签（卦名 + 宫位 + 八宫位次 + 六冲/六合）。
String bodyLabel(Hexagram h, List<DiZhi> branches) {
  final tags = <String>[
    if (isLiuChongBranches(branches)) '六冲',
    if (isLiuHeBranches(branches)) '六合',
  ];
  final tagText = tags.isEmpty ? '—' : tags.join('+');
  return '${h.name}｜${h.palace.label}宫·${h.rank.label}｜$tagText';
}
