import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_resolution.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

import 'domain_test_utils.dart';

void main() {
  group('FIX7 · 作用资格结算', () {
    test('月日可以作用多个目标，并且可以作用静爻', () {
      final result = resolveRelationResult(buildR4Case(withMoving: false));
      final effective = result.effective.map((e) => e.relation).toList();

      expect(effective.where((r) => r.source is MonthEndpoint), isNotEmpty);
      expect(effective.where((r) => r.source is DayEndpoint), isNotEmpty);
      expect(
        effective.where((r) => r.source is MonthEndpoint).length,
        greaterThan(1),
      );
    });

    test('静爻不能主动作用动爻或静爻，但仍可作为 target', () {
      final result = resolveRelationResult(buildR4Case(withMoving: false));
      final suppressed = result.suppressed;

      expect(
        suppressed.where(
          (e) =>
              e.relation.type == RelationType.sheng ||
              e.relation.type == RelationType.ke,
        ),
        isNotEmpty,
      );
      expect(
        suppressed
            .where(
              (e) =>
                  e.relation.type == RelationType.sheng ||
                  e.relation.type == RelationType.ke,
            )
            .every((e) => e.reason == RelationResolutionReason.staticSource),
        isTrue,
      );
    });

    test('普通动爻可以同时作用多个目标，普通受克不剥夺资格', () {
      final result = resolveRelationResult(
        buildR4Case(withChangedBranch: false),
      );
      final fromMoving = result.effective
          .where((e) => e.relation.source == YaoEndpoint(LineScope.original, 3))
          .map((e) => e.relation.type)
          .toList();

      expect(fromMoving, contains(RelationType.sheng));
      expect(fromMoving, contains(RelationType.ke));
    });

    test('回头生保留原动爻主动资格，回头克抑制其主动生克', () {
      final result = resolveRelationResult(buildR4Case());

      expect(
        result.effective.any(
          (e) => e.relation.type == RelationType.huiTouSheng,
        ),
        isTrue,
      );
      expect(
        result.effective.any(
          (e) =>
              e.relation.source == YaoEndpoint(LineScope.original, 5) &&
              (e.relation.type == RelationType.sheng ||
                  e.relation.type == RelationType.ke),
        ),
        isTrue,
      );
      expect(
        result.suppressed.any(
          (e) =>
              e.relation.source == YaoEndpoint(LineScope.original, 3) &&
              e.reason == RelationResolutionReason.returnOvercomeSource,
        ),
        isTrue,
      );
      expect(
        result.effective.any(
          (e) =>
              e.relation.target == YaoEndpoint(LineScope.original, 3) &&
              e.relation.source != YaoEndpoint(LineScope.original, 3),
        ),
        isTrue,
      );
    });
  });

  group('FIX7 · 特殊关系身份与可解释性', () {
    test('Golden Case：Candidate → Effective / Suppressed 可逐条核对', () {
      final result = resolveRelationResult(buildR4Case());

      expect(result.entries, hasLength(25));
      expect(result.effective, hasLength(13));
      expect(result.suppressed, hasLength(12));
      expect(
        result.suppressed.where(
          (e) => e.reason == RelationResolutionReason.staticSource,
        ),
        hasLength(9),
      );
      expect(
        result.suppressed.where(
          (e) => e.reason == RelationResolutionReason.returnOvercomeSource,
        ),
        hasLength(3),
      );
    });

    test('四种飞伏关系保留特殊身份，不自动升级为出伏', () {
      final relations = [
        _special(RelationType.flyingGeneratesHidden),
        _special(RelationType.flyingOvercomesHidden),
        _special(RelationType.hiddenGeneratesFlying),
        _special(RelationType.hiddenOvercomesFlying),
      ];
      final result = resolveRelationCandidates([
        for (final relation in relations)
          RelationCandidate.fromInstance(relation),
      ]);

      expect(
        result.effective.map((e) => e.relation.type),
        containsAll([
          RelationType.flyingGeneratesHidden,
          RelationType.flyingOvercomesHidden,
          RelationType.hiddenGeneratesFlying,
          RelationType.hiddenOvercomesFlying,
        ]),
      );
      expect(
        result.derivedStates.map((s) => s.name),
        isNot(contains('revealed')),
      );
    });

    test('每条候选都能回答保留或过滤原因', () {
      final result = resolveRelationResult(buildR4Case());

      expect(result.entries, isNotEmpty);
      expect(result.entries.every((e) => e.reason.isNotEmpty), isTrue);
      expect(
        result.entries.where((e) => e.effective),
        hasLength(result.effective.length),
      );
      expect(
        result.entries.where((e) => !e.effective),
        hasLength(result.suppressed.length),
      );
    });
  });
}

RelationInstance _special(RelationType type) => RelationInstance.from(
  type: type,
  ruleId: 'test.$type',
  source: YaoEndpoint(LineScope.original, 1),
  target: YaoEndpoint(LineScope.original, 2),
);
