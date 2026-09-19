import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_resolution.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';

import 'domain_test_utils.dart';

void main() {
  group('FIX7 · 作用资格结算', () {
    test('变爻先判本位回头生克；无回头关系时才可外放到原卦动静爻', () {
      final result = resolveRelationResult(_changedMetalCase());
      final effective = result.effective.map((entry) => entry.relation);

      expect(
        effective,
        contains(
          predicate<RelationInstance>(
            (relation) =>
                relation.type == RelationType.ke &&
                relation.source == YaoEndpoint(LineScope.changed, 1) &&
                relation.target == YaoEndpoint(LineScope.original, 2),
          ),
        ),
      );
      expect(
        effective,
        contains(
          predicate<RelationInstance>(
            (relation) =>
                relation.type == RelationType.sheng &&
                relation.source == YaoEndpoint(LineScope.changed, 1) &&
                relation.target == YaoEndpoint(LineScope.original, 3),
          ),
        ),
      );
      expect(
        effective.where(
          (relation) =>
              relation.source == YaoEndpoint(LineScope.changed, 1) &&
              relation.target is YaoEndpoint &&
              (relation.target as YaoEndpoint).scope == LineScope.changed,
        ),
        isEmpty,
      );
    });

    test('一旦构成回头生或回头克，变爻不得再外放生克其他原卦爻', () {
      final result = resolveRelationResult(buildR4Case());
      final effective = result.effective.map((entry) => entry.relation).toList();

      for (final returnRelation in effective.where(
        (relation) =>
            relation.type == RelationType.huiTouSheng ||
            relation.type == RelationType.huiTouKe,
      )) {
        final source = returnRelation.source;
        expect(
          effective.where(
            (relation) =>
                relation.source == source &&
                (relation.type == RelationType.sheng ||
                    relation.type == RelationType.ke),
          ),
          isEmpty,
        );
      }
    });

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

    test('静爻之间保留五行事实，但不得升级为实际作用', () {
      final result = resolveRelationResult(buildR4Case(withMoving: false));

      final ordinaryFacts = result.entries.where(
        (e) =>
            e.relation.type == RelationType.sheng ||
            e.relation.type == RelationType.ke,
      );

      // 乙口径：静爻之间的五行生克仍属于事实账本，供学习、解释和规则匹配。
      expect(ordinaryFacts, isNotEmpty);

      // 但静爻没有主动作用资格，因此这些事实不能进入有效作用集合，
      // 更不能成为审卦页关系曲线的数据源。
      expect(
        ordinaryFacts.every(
          (e) =>
              !e.effective &&
              e.reason == RelationResolutionReason.staticSource,
        ),
        isTrue,
      );
      expect(
        result.effective.where(
          (e) =>
              e.relation.type == RelationType.sheng ||
              e.relation.type == RelationType.ke,
        ),
        isEmpty,
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
      // 回头克只取消“这个动爻主动向外作用”的资格，
      // 绝不让它失去作为目标被月、日或其他合法来源作用的资格。
      expect(
        result.effective.any(
          (e) =>
              e.relation.target == YaoEndpoint(LineScope.original, 3) &&
              e.relation.source != YaoEndpoint(LineScope.original, 3),
        ),
        isTrue,
      );
      expect(
        result.effective.any(
          (e) =>
              e.relation.target == YaoEndpoint(LineScope.original, 3) &&
              (e.relation.source is MonthEndpoint ||
                  e.relation.source is DayEndpoint),
        ),
        isTrue,
      );
    });
  });

  group('FIX7 · 特殊关系身份与可解释性', () {
    test('Golden Case：Candidate → Effective / Suppressed 可逐条核对', () {
      final result = resolveRelationResult(buildR4Case());
      expect(result.entries, hasLength(27));
      expect(result.effective, hasLength(15));
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

HexagramCase _changedMetalCase() => HexagramCase(
  id: 'changed-metal-multi-target',
  question: 'changed metal multi target',
  createdAt: DateTime(2026, 9, 19),
  lines: [
    LineState(
      position: 1,
      movementType: MovementType.laoYang,
      branch: '午',
      changedBranch: '申',
    ),
    LineState(
      position: 2,
      movementType: MovementType.shaoYang,
      branch: '寅',
    ),
    LineState(
      position: 3,
      movementType: MovementType.shaoYang,
      branch: '子',
    ),
    for (var position = 4; position <= 6; position++)
      LineState(
        position: position,
        movementType: MovementType.shaoYang,
        branch: '辰',
      ),
  ],
);
