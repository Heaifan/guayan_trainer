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
  final entries = <RelationResolutionEntry>[];
  final states = <RelationDerivedState>[];

  for (final candidate in list) {
    final suppression = _suppressionFor(
      candidate,
      activeOriginalPositions,
      returnOvercomePositions,
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
) {
  if (activeOriginalPositions == null ||
      candidate.candidateSourcePosition == null ||
      candidate.sourceRole != RelationSourceRole.original) {
    return null;
  }
  final position = candidate.candidateSourcePosition!;
  if (!activeOriginalPositions.contains(position) &&
      (candidate.relation.type == RelationType.sheng ||
          candidate.relation.type == RelationType.ke)) {
    return RelationResolutionReason.staticSource;
  }
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
