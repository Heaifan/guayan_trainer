library;

export 'relation_resolution_model.dart';

import 'hexagram_case.dart';
import 'relation_calculator.dart';
import 'relation_endpoint.dart';
import 'relation_resolution_model.dart';
import 'relation_type.dart';

RelationResolutionResult resolveRelationResult(HexagramCase hexagramCase) {
  final facts = calculateRelations(hexagramCase);
  return resolveRelationCandidates(
    [for (final fact in facts) RelationCandidate.fromInstance(fact)],
    activeOriginalPositions: {
      for (final line in hexagramCase.lines)
        if (line.movementType.isMoving) line.position,
    },
  );
}

RelationResolutionResult resolveRelationCandidates(
  Iterable<RelationCandidate> candidates, {
  Set<int>? activeOriginalPositions,
}) {
  final list = candidates.toList(growable: false);
  final returnOvercomePositions = {
    for (final candidate in list)
      if (candidate.relation.type == RelationType.huiTouKe &&
          candidate.relation.source is YaoEndpoint &&
          candidate.relation.target is YaoEndpoint)
        (candidate.relation.target as YaoEndpoint).position,
  };
  final movingPairCombinedPositions = <int>{};
  if (activeOriginalPositions != null) {
    for (final candidate in list) {
      if (candidate.relation.type != RelationType.liuHe) continue;
      final source = candidate.relation.source;
      final target = candidate.relation.target;
      if (source is! YaoEndpoint ||
          target is! YaoEndpoint ||
          source.scope != LineScope.original ||
          target.scope != LineScope.original) {
        continue;
      }
      if (activeOriginalPositions.contains(source.position) &&
          activeOriginalPositions.contains(target.position)) {
        movingPairCombinedPositions
          ..add(source.position)
          ..add(target.position);
      }
    }
  }
  final calendarCombinedPositions = <int>{};
  if (activeOriginalPositions != null) {
    for (final candidate in list) {
      if (candidate.relation.type != RelationType.liuHe) continue;
      final source = candidate.relation.source;
      final target = candidate.relation.target;
      if ((source is MonthEndpoint || source is DayEndpoint) &&
          target is YaoEndpoint &&
          target.scope == LineScope.original &&
          activeOriginalPositions.contains(target.position)) {
        calendarCombinedPositions.add(target.position);
      }
    }
  }
  // 关系与状态分层：空、破、墓、绝、合等状态不得反向删除
  // 已经成立的生克事实。状态只负责追加修正/解释；是否能主动发力，
  // 仍由来源自身的作用资格单独裁决。
  final entries = <RelationResolutionEntry>[];
  final states = <RelationDerivedState>[];

  for (final candidate in list) {
    final suppression = _suppressionFor(
      candidate,
      activeOriginalPositions,
      returnOvercomePositions,
      movingPairCombinedPositions,
      calendarCombinedPositions,
    );
    entries.add(
      RelationResolutionEntry(
        candidate: candidate,
        effective: suppression == null,
        reason: suppression ?? RelationResolutionReason.effective,
      ),
    );
    _appendState(states, candidate);
  }

  return RelationResolutionResult(
    entries: List.unmodifiable(entries),
    effectiveRelationSet: List.unmodifiable([
      for (final entry in entries)
        if (entry.effective) entry,
    ]),
    derivedStates: List.unmodifiable(states),
  );
}

String? _suppressionFor(
  RelationCandidate candidate,
  Set<int>? activeOriginalPositions,
  Set<int> returnOvercomePositions,
  Set<int> movingPairCombinedPositions,
  Set<int> calendarCombinedPositions,
) {
  if (activeOriginalPositions == null ||
      candidate.candidateSourcePosition == null ||
      candidate.sourceRole != RelationSourceRole.original) {
    return null;
  }
  final position = candidate.candidateSourcePosition!;
  // 普通五行事实可以完整保留在候选账本中，但静爻没有主动作用资格。
  // 因此这里只压制“实际作用”，不删除事实本身。
  if (!activeOriginalPositions.contains(position) &&
      (candidate.relation.type == RelationType.sheng ||
          candidate.relation.type == RelationType.ke)) {
    return RelationResolutionReason.staticSource;
  }
  // 两个原卦动爻六合时，双方都有主动资格，因此互相合住。
  // 六合事实本身仍保留，只压制双方继续向其他爻外放的普通生克。
  if (movingPairCombinedPositions.contains(position) &&
      (candidate.relation.type == RelationType.sheng ||
          candidate.relation.type == RelationType.ke)) {
    return RelationResolutionReason.movingPairCombinedSource;
  }
  // 已取得作用资格的月建/日辰与动爻六合时形成合绊。
  // 被合绊的动爻保留原有生克事实，但暂停主动向其他爻外放。
  if (calendarCombinedPositions.contains(position) &&
      (candidate.relation.type == RelationType.sheng ||
          candidate.relation.type == RelationType.ke)) {
    return RelationResolutionReason.calendarCombinedSource;
  }
  // 原动爻也必须先接受本位回头关系裁决：
  // - 被回头克：失去普通主动生克资格；
  // - 被回头生：不压制，仍可继续生克其他合法目标。
  if (returnOvercomePositions.contains(position) &&
      (candidate.relation.type == RelationType.sheng ||
          candidate.relation.type == RelationType.ke)) {
    return RelationResolutionReason.returnOvercomeSource;
  }
  return null;
}

void _appendState(
  List<RelationDerivedState> states,
  RelationCandidate candidate,
) {
  final type = candidate.relation.type;
  if (type == RelationType.huiTouSheng) {
    states.add(
      RelationDerivedState(name: '得助', evidence: [candidate.relation]),
    );
  } else if (type == RelationType.huiTouKe) {
    states.add(
      RelationDerivedState(name: '受制', evidence: [candidate.relation]),
    );
  } else if (type == RelationType.hiddenOvercomesFlying) {
    states.add(
      RelationDerivedState(
        name: '飞神压制解除证据',
        evidence: [candidate.relation],
        hiddenState: HiddenResolutionState.hidden,
      ),
    );
  } else if (type == RelationType.flyingOvercomesHidden) {
    states.add(
      RelationDerivedState(
        name: '飞神压制证据',
        evidence: [candidate.relation],
        hiddenState: HiddenResolutionState.hidden,
      ),
    );
  }
}

extension on RelationCandidate {
  int? get candidateSourcePosition => switch (relation.source) {
    YaoEndpoint(:final position) => position,
    _ => null,
  };
}
