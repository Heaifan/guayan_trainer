import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_resolution.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';

import 'domain_test_utils.dart';

void main() {
  group('FIX7 · 作用资格结算', () {
    test('无回头关系时，变爻也不得向其他原卦爻外放普通生克', () {
      final result = resolveRelationResult(_changedNoReturnCase());
      final relations = result.entries.map((entry) => entry.relation).toList();

      expect(
        relations.where(
          (relation) =>
              relation.source == YaoEndpoint(LineScope.changed, 1) &&
              (relation.type == RelationType.sheng ||
                  relation.type == RelationType.ke),
        ),
        isEmpty,
      );
      expect(
        relations.any(
          (relation) =>
              relation.type == RelationType.huiTouSheng ||
              relation.type == RelationType.huiTouKe,
        ),
        isFalse,
      );
      expect(
        relations.any(
          (relation) =>
              relation.type == RelationType.dongBian &&
              relation.source == YaoEndpoint(LineScope.original, 1) &&
              relation.target == YaoEndpoint(LineScope.changed, 1),
        ),
        isTrue,
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

    test('月日未入主卦明爻时，只保留历法背景，不产生主动生克', () {
      final result = resolveRelationResult(buildR4Case(withMoving: false));
      final effective = result.effective.map((e) => e.relation).toList();

      // 默认月寅、日子，而主卦明爻没有寅、子：均未入卦。
      expect(effective.where((r) => r.source is MonthEndpoint), isEmpty);
      expect(effective.where((r) => r.source is DayEndpoint), isEmpty);
    });

    test('月日与主卦明爻同支入卦后，才可作用多个原卦动静爻', () {
      final result = resolveRelationResult(_monthDayEnteredCase());
      final effective = result.effective.map((e) => e.relation).toList();

      expect(effective.where((r) => r.source is MonthEndpoint), isNotEmpty);
      expect(effective.where((r) => r.source is DayEndpoint), isNotEmpty);
      expect(
        effective.where((r) => r.source is MonthEndpoint).length,
        greaterThan(1),
      );
      expect(
        effective.where((r) => r.source is DayEndpoint).length,
        greaterThan(1),
      );
    });

    test('只有变爻临月日不算入卦，不能据此取得月日主动生克资格', () {
      final result = resolveRelationResult(_monthDayOnlyChangedCase());
      final effective = result.effective.map((e) => e.relation).toList();

      expect(effective.where((r) => r.source is MonthEndpoint), isEmpty);
      expect(effective.where((r) => r.source is DayEndpoint), isEmpty);
    });

    test('两个动爻六合时双方互相合住，普通向外生克均被压制', () {
      final result = resolveRelationResult(_movingLiuHeCase());

      expect(
        result.effective.any(
          (e) =>
              e.relation.type == RelationType.liuHe &&
              {e.relation.source, e.relation.target}.containsAll({
                YaoEndpoint(LineScope.original, 1),
                YaoEndpoint(LineScope.original, 2),
              }),
        ),
        isTrue,
      );

      for (final position in [1, 2]) {
        expect(
          result.suppressed.any(
            (e) =>
                e.relation.source ==
                    YaoEndpoint(LineScope.original, position) &&
                (e.relation.type == RelationType.sheng ||
                    e.relation.type == RelationType.ke) &&
                e.reason ==
                    RelationResolutionReason.movingPairCombinedSource,
          ),
          isTrue,
        );
        expect(
          result.effective.where(
            (e) =>
                e.relation.source ==
                    YaoEndpoint(LineScope.original, position) &&
                (e.relation.type == RelationType.sheng ||
                    e.relation.type == RelationType.ke),
          ),
          isEmpty,
        );
      }
    });

    test('已入卦月日六合动爻形成合绊，动爻停止普通向外生克', () {
      final result = resolveRelationResult(_calendarLiuHeMovingCase());

      for (final position in [1, 2]) {
        expect(
          result.effective.any(
            (e) =>
                e.relation.type == RelationType.liuHe &&
                e.relation.target ==
                    YaoEndpoint(LineScope.original, position) &&
                (e.relation.source is MonthEndpoint ||
                    e.relation.source is DayEndpoint),
          ),
          isTrue,
        );
        expect(
          result.suppressed.any(
            (e) =>
                e.relation.source ==
                    YaoEndpoint(LineScope.original, position) &&
                (e.relation.type == RelationType.sheng ||
                    e.relation.type == RelationType.ke) &&
                e.reason == RelationResolutionReason.calendarCombinedSource,
          ),
          isTrue,
        );
      }
    });

    test('空亡参与六合只记空合，不形成合绊，也不压制动爻外放', () {
      final result = resolveRelationResult(_kongWangLiuHeMovingCase());

      expect(
        result.suppressed.any(
          (e) =>
              e.relation.type == RelationType.liuHe &&
              e.reason == RelationResolutionReason.emptyCombination,
        ),
        isTrue,
      );
      expect(
        result.suppressed.any(
          (e) => e.reason == RelationResolutionReason.movingPairCombinedSource,
        ),
        isFalse,
      );
      expect(
        result.effective.any(
          (e) =>
              e.relation.source == YaoEndpoint(LineScope.original, 1) &&
              (e.relation.type == RelationType.sheng ||
                  e.relation.type == RelationType.ke),
        ),
        isTrue,
      );
    });

    test('空亡不影响原动爻普通生克资格', () {
      final result = resolveRelationResult(_kongWangMovingShengKeCase());

      final fromKongWang = result.effective.where(
        (e) =>
            e.relation.source == YaoEndpoint(LineScope.original, 1) &&
            (e.relation.type == RelationType.sheng ||
                e.relation.type == RelationType.ke),
      );

      expect(fromKongWang, isNotEmpty);
      expect(
        fromKongWang.map((e) => e.relation.type),
        containsAll([RelationType.sheng, RelationType.ke]),
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

    test('回头生保留主动资格；回头克只压制自身外放，不妨碍月建继续作用它', () {
      final result = resolveRelationResult(
        buildR4Case(
          calendar: const CalendarSnapshot(
            monthBranch: '酉',
            dayGanZhi: '甲子',
          ),
        ),
      );

      expect(
        result.effective.any(
          (e) => e.relation.type == RelationType.huiTouSheng,
        ),
        isTrue,
      );
      // 回头生/回头克是关系事实与行为裁决，不再伪装成 DerivedState。
      expect(
        result.derivedStates.where(
          (state) => state.name == '得助' || state.name == '受制',
        ),
        isEmpty,
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
              e.relation.source is MonthEndpoint,
        ),
        isTrue,
      );
    });
  });

  group('FIX7 · 特殊关系身份与可解释性', () {
    test('Golden Case：Candidate → Effective / Suppressed 可逐条核对', () {
      final result = resolveRelationResult(buildR4Case());
      expect(result.entries, isNotEmpty);
      expect(result.effective, isNotEmpty);
      expect(result.suppressed, isNotEmpty);
      expect(
        result.suppressed.where(
          (e) => e.reason == RelationResolutionReason.staticSource,
        ),
        isNotEmpty,
      );
      expect(
        result.suppressed.where(
          (e) => e.reason == RelationResolutionReason.returnOvercomeSource,
        ),
        isNotEmpty,
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

HexagramCase _changedNoReturnCase() => HexagramCase(
  id: 'changed-no-return-no-outbound',
  question: '变爻无回头关系也不得外放',
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


HexagramCase _monthDayEnteredCase() => HexagramCase(
  id: 'month-day-entered',
  question: '月日入卦',
  createdAt: DateTime(2026, 9, 20),
  calendar: const CalendarSnapshot(monthBranch: '寅', dayGanZhi: '甲子'),
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYang, branch: '寅'),
    LineState(position: 2, movementType: MovementType.shaoYin, branch: '子'),
    LineState(position: 3, movementType: MovementType.laoYang, branch: '辰'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '巳'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);

HexagramCase _monthDayOnlyChangedCase() => HexagramCase(
  id: 'month-day-only-changed',
  question: '仅变爻临月日',
  createdAt: DateTime(2026, 9, 20),
  calendar: const CalendarSnapshot(monthBranch: '寅', dayGanZhi: '甲子'),
  lines: [
    LineState(
      position: 1,
      movementType: MovementType.laoYang,
      branch: '午',
      changedBranch: '寅',
    ),
    LineState(
      position: 2,
      movementType: MovementType.laoYin,
      branch: '丑',
      changedBranch: '子',
    ),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '辰'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '巳'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);


HexagramCase _movingLiuHeCase() => HexagramCase(
  id: 'moving-liuhe',
  question: '动动六合',
  createdAt: DateTime(2026, 9, 20),
  lines: [
    LineState(position: 1, movementType: MovementType.laoYang, branch: '子'),
    LineState(position: 2, movementType: MovementType.laoYin, branch: '丑'),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '寅'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '午'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);


HexagramCase _calendarLiuHeMovingCase() => HexagramCase(
  id: 'calendar-liuhe-moving',
  question: '月日合绊动爻',
  createdAt: DateTime(2026, 9, 20),
  calendar: const CalendarSnapshot(monthBranch: '子', dayGanZhi: '甲寅'),
  lines: [
    // 丑动与月子六合；亥动与日寅六合。
    LineState(position: 1, movementType: MovementType.laoYang, branch: '丑'),
    LineState(position: 2, movementType: MovementType.laoYin, branch: '亥'),
    // 子、寅明现，使月建与日建都满足本轮“入卦后取得作用资格”的门槛。
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '子'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '寅'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '午'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);

HexagramCase _kongWangLiuHeMovingCase() => HexagramCase(
  id: 'kong-wang-liuhe-moving',
  question: '空合不合绊',
  createdAt: DateTime(2026, 9, 20),
  // 甲子日所属旬空亡戌亥；二爻亥为空亡，与初爻寅六合。
  calendar: const CalendarSnapshot(monthBranch: '辰', dayGanZhi: '甲子'),
  lines: [
    LineState(position: 1, movementType: MovementType.laoYang, branch: '寅'),
    LineState(position: 2, movementType: MovementType.laoYin, branch: '亥'),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '辰'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '午'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);
HexagramCase _kongWangMovingShengKeCase() => HexagramCase(
  id: 'kong-wang-moving-sheng-ke',
  question: '空亡不影响生克',
  createdAt: DateTime(2026, 9, 22),
  // 甲子日所属旬空亡戌亥；初爻亥为空亡且发动。
  calendar: const CalendarSnapshot(monthBranch: '丑', dayGanZhi: '甲子'),
  lines: [
    LineState(position: 1, movementType: MovementType.laoYang, branch: '亥'),
    // 亥水生卯木，克午火；两条普通作用都应继续有效。
    LineState(position: 2, movementType: MovementType.shaoYin, branch: '卯'),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '午'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '辰'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);

