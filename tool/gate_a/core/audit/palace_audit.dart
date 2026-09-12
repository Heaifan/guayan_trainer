/// 八宫表完整性复核（自 `hexagram_audit.dart` 拆出）。
///
/// 这是对 R3-A「世应由本宫卦逐爻变化推导」算法的**独立**复核：
/// 推导规则若有误，必然出现重复或缺失。
library;

import 'package:guayan_trainer/domain/casting/palace.dart';

/// 八宫表完整性：64 组合一一对应、每宫 8 卦、世应相隔三位。
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
