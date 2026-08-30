/// 最小确定性关系计算：从 HexagramCase 推导 RelationInstance 列表。
///
/// 本阶段只覆盖 Stable Relation Identity 演示所需的最小关系子集：
/// - 动变（有向）：动爻 original-p → changed-p
/// - 六冲 / 六合（对称）：本卦任意两爻地支相冲 / 相合
///
/// 完整六爻关系引擎（纳甲 / 六亲 / 回头生克 / 月日 / 墓库等）属于
/// 后续 R3 / R4 阶段；本计算器输出按 RelationKey canonical 稳定排序，
/// 保证同输入永远得到同序列（Test A）。
library;

import 'hexagram_case.dart';
import 'line_endpoint.dart';
import 'relation_instance.dart';
import 'relation_type.dart';

/// 地支六冲映射（与旧训练层 RelationData 同源，域内自包含）。
const _sixChong = {
  '子': '午',
  '丑': '未',
  '寅': '申',
  '卯': '酉',
  '辰': '戌',
  '巳': '亥',
};

/// 地支六合映射。
const _sixHe = {
  '子': '丑',
  '寅': '亥',
  '卯': '戌',
  '辰': '酉',
  '巳': '申',
  '午': '未',
};

/// 计算 [hexagramCase] 的全部关系实例，按 RelationKey 稳定排序。
///
/// 规则版本来源：优先使用 [HexagramCase.ruleContext] 中保存的版本
/// （replay 契约——历史卦例复现历史 key），无记录时回退 v1。
List<RelationInstance> calculateRelations(HexagramCase hexagramCase) {
  final result = <RelationInstance>[];

  for (final line in hexagramCase.lines) {
    if (!line.movementType.isMoving) continue;
    result.add(RelationInstance.from(
      type: RelationType.dongBian,
      ruleId: SystemRuleIds.dongBian,
      ruleVersion: hexagramCase.ruleContext
          .versionForOrDefault(SystemRuleIds.dongBian),
      source: LineEndpoint(LineScope.original, line.position),
      target: LineEndpoint(LineScope.changed, line.position),
    ));
  }

  final lines = hexagramCase.lines;
  for (var i = 0; i < lines.length; i++) {
    for (var j = i + 1; j < lines.length; j++) {
      final a = lines[i];
      final b = lines[j];
      final brA = a.branch;
      final brB = b.branch;
      if (brA == null || brB == null) continue;
      final source = LineEndpoint(LineScope.original, a.position);
      final target = LineEndpoint(LineScope.original, b.position);
      if (_isChong(brA, brB)) {
        result.add(RelationInstance.from(
          type: RelationType.liuChong,
          ruleId: SystemRuleIds.liuChong,
          ruleVersion: hexagramCase.ruleContext
              .versionForOrDefault(SystemRuleIds.liuChong),
          source: source,
          target: target,
        ));
      }
      if (_isHe(brA, brB)) {
        result.add(RelationInstance.from(
          type: RelationType.liuHe,
          ruleId: SystemRuleIds.liuHe,
          ruleVersion: hexagramCase.ruleContext
              .versionForOrDefault(SystemRuleIds.liuHe),
          source: source,
          target: target,
        ));
      }
    }
  }

  result.sort((x, y) => x.key.canonical.compareTo(y.key.canonical));
  return result;
}

bool _isChong(String a, String b) => _sixChong[a] == b || _sixChong[b] == a;

bool _isHe(String a, String b) => _sixHe[a] == b || _sixHe[b] == a;
