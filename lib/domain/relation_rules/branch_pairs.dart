/// 六冲 / 六合（R4 基础关系，对称）。
///
/// 本卦六爻两两组合（C(6,2) = 15），只要两支相冲 / 相合即产出一条关系：
/// ```text
/// 六冲：子午 丑未 寅申 卯酉 辰戌 巳亥
/// 六合：子丑 寅亥 卯戌 辰酉 巳申 午未
/// ```
/// 判定**只使用** [DiZhi.chong] / [DiZhi.he] 这一处定义 ——
/// 旧实现自带字符串映射表，属重复定义（`domain/README.md` 明确禁止）。
library;

import '../hexagram_case.dart';
import '../relation_instance.dart';
import '../relation_type.dart';
import 'rule_support.dart';

/// 六冲 / 六合关系（对称，端点为本卦两支）。
List<RelationInstance> chongHeRelations(HexagramCase c) {
  final out = <RelationInstance>[];
  final lines = c.lines;
  for (var i = 0; i < lines.length; i++) {
    for (var j = i + 1; j < lines.length; j++) {
      final a = zhiOf(lines[i].branch);
      final b = zhiOf(lines[j].branch);
      if (a == null || b == null) continue;
      final source = originalYao(lines[i].position);
      final target = originalYao(lines[j].position);
      if (a.chong == b) {
        out.add(
          systemRelation(
            c: c,
            type: RelationType.liuChong,
            ruleId: SystemRuleIds.liuChong,
            source: source,
            target: target,
          ),
        );
      }
      if (a.he == b) {
        out.add(
          systemRelation(
            c: c,
            type: RelationType.liuHe,
            ruleId: SystemRuleIds.liuHe,
            source: source,
            target: target,
          ),
        );
      }
    }
  }
  return out;
}
