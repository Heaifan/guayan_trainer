/// 卦体属性旁证：六冲 / 六合 判定 + 八宫表独立性复核。
///
/// 六冲 / 六合 并非 R3 冻结范围，但 GA-1 要求案例覆盖它们，
/// 因此需要一处**可复核的判定**，而不是手感分类。
library;

import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/casting/najia.dart';
import 'package:guayan_trainer/domain/casting/palace.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

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

/// 八宫表完整性：64 组合一一对应、每宫 8 卦、世应相隔三位。
///
/// 这是对 R3-A「世应由本宫卦逐爻变化推导」算法的**独立**复核：
/// 推导规则若有误，必然出现重复或缺失。
List<String> verifyPalaceTable() {
  final problems = <String>[];
  final seen = <String, PalaceEntry>{};

  for (final entry in baGongTable) {
    final key = entry.lines.map((b) => b ? '1' : '0').join();
    final previous = seen[key];
    if (previous != null) {
      problems.add(
        '八宫表重复组合 $key：'
        '${previous.palace.label}宫 与 ${entry.palace.label}宫',
      );
    }
    seen[key] = entry;
  }
  if (seen.length != 64) {
    problems.add('八宫表覆盖 ${seen.length} 个组合，应为 64');
  }

  for (final palace in baGongOrder) {
    final members = baGongTable.where((e) => e.palace == palace).toList();
    if (members.length != 8) {
      problems.add('${palace.label}宫含 ${members.length} 卦，应为 8');
    }
    if (members.isNotEmpty && members.first.rank != PalaceRank.benGong) {
      problems.add('${palace.label}宫首位不是本宫卦');
    }
    for (final m in members) {
      final expectedYing = m.shiPosition <= 3
          ? m.shiPosition + 3
          : m.shiPosition - 3;
      if (m.yingPosition != expectedYing) {
        problems.add('${palace.label}宫世应不相隔三位');
      }
    }
  }
  return problems;
}

/// 纳甲组装顺序复核：本卦六爻支必须等于「下卦内三支 + 上卦外三支」。
List<String> verifyNajiaAssembly(Hexagram h, List<DiZhi> branches) {
  final expected = <DiZhi>[
    ...najiaByBagua[h.lower]!.sublist(0, 3),
    ...najiaByBagua[h.upper]!.sublist(3, 6),
  ];
  for (var i = 0; i < 6; i++) {
    if (expected[i] != branches[i]) {
      return [
        '纳甲组装顺序错误：第 ${i + 1} 爻 期望 ${expected[i].label} '
            '实际 ${branches[i].label}',
      ];
    }
  }
  return const <String>[];
}
