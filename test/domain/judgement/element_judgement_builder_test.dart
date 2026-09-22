import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/fushen_engine.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/judgement/element_judgement.dart';
import 'package:guayan_trainer/domain/judgement/element_judgement_builder.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  test('身份使用结构字段，不再使用身份标签', () {
    final lines = [
      LineState(
        position: 1,
        movementType: MovementType.laoYang,
        branch: '子',
        changedBranch: '未',
      ),
      LineState(position: 2, movementType: MovementType.shaoYin, branch: '丑'),
      LineState(position: 3, movementType: MovementType.shaoYang, branch: '寅'),
      LineState(position: 4, movementType: MovementType.shaoYin, branch: '卯'),
      LineState(position: 5, movementType: MovementType.shaoYang, branch: '辰'),
      LineState(position: 6, movementType: MovementType.shaoYin, branch: '巳'),
    ];
    final hexagramCase = HexagramCase(
      id: 'judgement-identity-r5',
      question: '身份结构测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '酉',
        dayGanZhi: '甲子',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);

    final original1 = snapshot.of(SemanticRef.line(1))!;
    expect(original1.identity.kind, JudgementElementKind.originalLine);
    expect(original1.identity.position, 1);
    expect(original1.identity.movementType, MovementType.laoYang);
    expect(original1.identity.isMovingOriginal, isTrue);
    expect(original1.states.where((state) => state.startsWith('identity.')), isEmpty);

    final original2 = snapshot.of(SemanticRef.line(2))!;
    expect(original2.identity.movementType, MovementType.shaoYin);
    expect(original2.identity.isStillOriginal, isTrue);

    final changed1 = snapshot.of(SemanticRef.changedLine(1))!;
    expect(changed1.identity.kind, JudgementElementKind.changedLine);
    expect(changed1.identity.position, 1);
    expect(changed1.identity.movementType, isNull);
    expect(changed1.branch, '未');
    expect(changed1.ref, isNot(original1.ref));
    expect(snapshot.of(SemanticRef.changedLine(2)), isNull);

    expect(snapshot.of(SemanticRef.month)!.kind, JudgementElementKind.month);
    expect(snapshot.of(SemanticRef.day)!.kind, JudgementElementKind.day);

    final chart = CastingEngine.cast([
      for (final line in lines) line.movementType,
    ]);
    final expectedHidden = FushenEngine.calculate(chart);
    expect(
      snapshot.byKind(JudgementElementKind.hiddenSpirit).length,
      expectedHidden.length,
    );
    for (final hidden in expectedHidden) {
      final element = snapshot.of(SemanticRef.hiddenSpirit(hidden.lineIndex));
      expect(element, isNotNull);
      expect(element!.kind, JudgementElementKind.hiddenSpirit);
      expect(element.hasState(JudgementStateIds.hidden), isTrue);
    }
  });

  test('状态集合只承载状态判断结果', () {
    final element = ElementJudgement(
      identity: ElementIdentity(
        ref: SemanticRef.line(3),
        kind: JudgementElementKind.originalLine,
        position: 3,
        movementType: MovementType.laoYang,
      ),
      states: const {
        JudgementStateIds.kongWang,
        JudgementStateIds.dayChong,
        JudgementStateIds.chong,
      },
    );

    expect(element.identity.isMovingOriginal, isTrue);
    expect(element.hasState(JudgementStateIds.kongWang), isTrue);
    expect(element.hasState(JudgementStateIds.dayChong), isTrue);
    expect(element.states.every((state) => state.startsWith('state.')), isTrue);
  });

  test('空亡标记原爻、变爻与伏神，不标记月日基准对象', () {
    // 水雷屯的原卦阴阳结构；伏神为三爻妻财午火。
    // 甲申日所属旬的空亡为午未，因此原1午、变1未、伏神3午都应标记空亡。
    final lines = [
      LineState(
        position: 1,
        movementType: MovementType.laoYang,
        branch: '午',
        changedBranch: '未',
      ),
      LineState(position: 2, movementType: MovementType.shaoYin, branch: '丑'),
      LineState(position: 3, movementType: MovementType.shaoYin, branch: '寅'),
      LineState(position: 4, movementType: MovementType.shaoYin, branch: '卯'),
      LineState(position: 5, movementType: MovementType.shaoYang, branch: '辰'),
      LineState(position: 6, movementType: MovementType.shaoYin, branch: '巳'),
    ];
    final hexagramCase = HexagramCase(
      id: 'judgement-kong-wang-r5',
      question: '空亡判定区测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '午',
        dayGanZhi: '甲申',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);

    expect(
      snapshot.of(SemanticRef.line(1))!.hasState(JudgementStateIds.kongWang),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.changedLine(1))!
          .hasState(JudgementStateIds.kongWang),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.hiddenSpirit(3))!
          .hasState(JudgementStateIds.kongWang),
      isTrue,
    );

    expect(
      snapshot.of(SemanticRef.month)!.hasState(JudgementStateIds.kongWang),
      isFalse,
    );
    expect(
      snapshot.of(SemanticRef.day)!.hasState(JudgementStateIds.kongWang),
      isFalse,
    );
  });

  test('月冲日冲动爻冲只作为状态判断结果记录', () {
    final lines = [
      LineState(position: 1, movementType: MovementType.shaoYang, branch: '子'),
      LineState(
        position: 2,
        movementType: MovementType.laoYang,
        branch: '午',
        changedBranch: '子',
      ),
      LineState(position: 3, movementType: MovementType.shaoYin, branch: '丑'),
      LineState(position: 4, movementType: MovementType.shaoYang, branch: '寅'),
      LineState(position: 5, movementType: MovementType.shaoYin, branch: '卯'),
      LineState(position: 6, movementType: MovementType.shaoYang, branch: '辰'),
    ];
    final hexagramCase = HexagramCase(
      id: 'judgement-chong-r5',
      question: '受冲状态测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '午',
        dayGanZhi: '甲午',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);
    final target = snapshot.of(SemanticRef.line(1))!;

    expect(target.hasState(JudgementStateIds.monthChong), isTrue);
    expect(target.hasState(JudgementStateIds.dayChong), isTrue);
    expect(target.hasState(JudgementStateIds.movingChong), isTrue);
    expect(target.hasState(JudgementStateIds.chong), isTrue);

    final movingSource = snapshot.of(SemanticRef.line(2))!;
    expect(movingSource.hasState(JudgementStateIds.movingChong), isFalse);

    final changed = snapshot.of(SemanticRef.changedLine(2))!;
    expect(changed.hasState(JudgementStateIds.monthChong), isTrue);
    expect(changed.hasState(JudgementStateIds.dayChong), isTrue);
    expect(changed.hasState(JudgementStateIds.movingChong), isFalse);
    expect(changed.hasState(JudgementStateIds.chong), isTrue);

    expect(
      snapshot.of(SemanticRef.month)!.hasState(JudgementStateIds.chong),
      isFalse,
    );
    expect(
      snapshot.of(SemanticRef.day)!.hasState(JudgementStateIds.chong),
      isFalse,
    );
  });
}
