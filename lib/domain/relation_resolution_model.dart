import 'relation_endpoint.dart';
import 'relation_instance.dart';
import 'relation_type.dart';

enum RelationSourceRole { month, day, original, changed, hidden }

enum HiddenResolutionState { hidden, eligible, revealed }

abstract final class RelationResolutionReason {
  static const effective = 'EFFECTIVE';
  static const staticSource = 'STATIC_SOURCE_CANNOT_ACT';
  static const returnOvercomeSource = 'RETURN_OVERCOME_SUPPRESSED_SOURCE';
  static const movingPairCombinedSource = 'MOVING_PAIR_COMBINED_SOURCE';
}

class RelationCandidate {
  const RelationCandidate({
    required this.relation,
    required this.sourceRole,
    required this.targetRole,
  });

  factory RelationCandidate.fromInstance(RelationInstance relation) {
    return RelationCandidate(
      relation: relation,
      sourceRole: _roleOf(relation.source),
      targetRole: _roleOf(relation.target),
    );
  }

  final RelationInstance relation;
  final RelationSourceRole sourceRole;
  final RelationSourceRole targetRole;

  bool get isSpecial => switch (relation.type) {
    RelationType.sheng || RelationType.ke => false,
    _ => true,
  };

  static RelationSourceRole _roleOf(RelationEndpoint endpoint) =>
      switch (endpoint) {
        MonthEndpoint() => RelationSourceRole.month,
        DayEndpoint() => RelationSourceRole.day,
        YaoEndpoint(:final scope) => switch (scope) {
          LineScope.original => RelationSourceRole.original,
          LineScope.changed => RelationSourceRole.changed,
        },
      };
}

class RelationResolutionEntry {
  const RelationResolutionEntry({
    required this.candidate,
    required this.effective,
    required this.reason,
  });

  final RelationCandidate candidate;
  final bool effective;
  final String reason;

  RelationInstance get relation => candidate.relation;
}

class RelationDerivedState {
  const RelationDerivedState({
    required this.name,
    required this.evidence,
    this.hiddenState,
  });

  final String name;
  final List<RelationInstance> evidence;
  final HiddenResolutionState? hiddenState;
}

class RelationResolutionResult {
  const RelationResolutionResult({
    required this.entries,
    required this.effectiveRelationSet,
    required this.derivedStates,
  });

  final List<RelationResolutionEntry> entries;
  final List<RelationResolutionEntry> effectiveRelationSet;
  final List<RelationDerivedState> derivedStates;

  List<RelationResolutionEntry> get effective => effectiveRelationSet;

  List<RelationResolutionEntry> get suppressed => [
    for (final entry in entries)
      if (!entry.effective) entry,
  ];
}
