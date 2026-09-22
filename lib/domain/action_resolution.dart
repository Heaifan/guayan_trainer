library;

import 'relation_endpoint.dart';
import 'relation_instance.dart';
import 'relation_type.dart';

/// 当前只裁决“原卦动爻能否继续普通向外生克”这一类行为。
enum ActionKind {
  ordinaryShengKeOutbound,
}

enum ActionResolutionDisposition {
  preserved,
  blocked,
}

abstract final class ActionResolutionReason {
  static const huiTouShengPreservesOutbound =
      'HUI_TOU_SHENG_PRESERVES_OUTBOUND';
  static const huiTouKeBlocksOutbound = 'HUI_TOU_KE_BLOCKS_OUTBOUND';
}

/// 一条行为裁决结果。
///
/// 注意：它不是状态标签，也不是关系事实。
/// [evidence] 必须指向已经存在的 RelationInstance。
class ActionResolutionEntry {
  const ActionResolutionEntry({
    required this.actor,
    required this.action,
    required this.disposition,
    required this.reason,
    required this.evidence,
  });

  final RelationEndpoint actor;
  final ActionKind action;
  final ActionResolutionDisposition disposition;
  final String reason;
  final List<RelationInstance> evidence;

  bool get allowed => disposition != ActionResolutionDisposition.blocked;
}

class ActionResolutionResult {
  const ActionResolutionResult(this.entries);

  final List<ActionResolutionEntry> entries;

  Set<int> get blockedOriginalPositions => {
    for (final entry in entries)
      if (entry.action == ActionKind.ordinaryShengKeOutbound &&
          entry.disposition == ActionResolutionDisposition.blocked &&
          entry.actor is YaoEndpoint &&
          (entry.actor as YaoEndpoint).scope == LineScope.original)
        (entry.actor as YaoEndpoint).position,
  };

  Set<int> get preservedOriginalPositions => {
    for (final entry in entries)
      if (entry.action == ActionKind.ordinaryShengKeOutbound &&
          entry.disposition == ActionResolutionDisposition.preserved &&
          entry.actor is YaoEndpoint &&
          (entry.actor as YaoEndpoint).scope == LineScope.original)
        (entry.actor as YaoEndpoint).position,
  };
}

/// 只根据“回头生 / 回头克”关系裁决原动爻的普通向外生克行为。
///
/// - 回头生：保留主动生克资格；
/// - 回头克：阻断主动生克资格；
/// - 空亡不参与此处判断，因为空亡不影响生克。
ActionResolutionResult resolveReturnActionResolution(
  Iterable<RelationInstance> relations,
) {
  final entries = <ActionResolutionEntry>[];

  for (final relation in relations) {
    if (relation.type != RelationType.huiTouSheng &&
        relation.type != RelationType.huiTouKe) {
      continue;
    }

    final source = relation.source;
    final target = relation.target;
    if (source is! YaoEndpoint ||
        target is! YaoEndpoint ||
        source.scope != LineScope.changed ||
        target.scope != LineScope.original ||
        source.position != target.position) {
      continue;
    }

    final isOvercome = relation.type == RelationType.huiTouKe;
    entries.add(
      ActionResolutionEntry(
        actor: target,
        action: ActionKind.ordinaryShengKeOutbound,
        disposition: isOvercome
            ? ActionResolutionDisposition.blocked
            : ActionResolutionDisposition.preserved,
        reason: isOvercome
            ? ActionResolutionReason.huiTouKeBlocksOutbound
            : ActionResolutionReason.huiTouShengPreservesOutbound,
        evidence: [relation],
      ),
    );
  }

  return ActionResolutionResult(List.unmodifiable(entries));
}
