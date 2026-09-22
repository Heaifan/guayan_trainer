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
  test('builds independent original changed calendar and hidden objects', () {
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
      id: 'judgement-r1',
      question: '判定区测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '酉',
        dayGanZhi: '甲子',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);

    final original1 = snapshot.of(SemanticRef.line(1))!;
    expect(original1.kind, JudgementElementKind.originalLine);
    expect(original1.hasIdentity(JudgementTagIds.originalLine), isTrue);
    expect(original1.hasIdentity(JudgementTagIds.moving), isTrue);

    final original2 = snapshot.of(SemanticRef.line(2))!;
    expect(original2.hasIdentity(JudgementTagIds.still), isTrue);

    final changed1 = snapshot.of(SemanticRef.changedLine(1))!;
    expect(changed1.kind, JudgementElementKind.changedLine);
    expect(changed1.branch, '未');
    expect(changed1.ref, isNot(original1.ref));
    expect(snapshot.of(SemanticRef.changedLine(2)), isNull);

    expect(snapshot.of(SemanticRef.month)!.branch, '酉');
    expect(snapshot.of(SemanticRef.day)!.branch, '子');

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
      expect(element!.hasIdentity(JudgementTagIds.hiddenSpirit), isTrue);
      expect(element.hasState(JudgementTagIds.hidden), isTrue);
    }
  });

  test('identity and state areas remain separate', () {
    final element = ElementJudgement(
      ref: SemanticRef.line(3),
      kind: JudgementElementKind.originalLine,
      position: 3,
      identityTags: const {
        JudgementTagIds.originalLine,
        JudgementTagIds.moving,
      },
      stateTags: const {JudgementTagIds.hidden},
    );

    expect(element.hasIdentity(JudgementTagIds.moving), isTrue);
    expect(element.hasState(JudgementTagIds.hidden), isTrue);
    expect(element.hasIdentity(JudgementTagIds.hidden), isFalse);
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
      id: 'judgement-kong-wang-r4',
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
      snapshot.of(SemanticRef.line(1))!.hasState(JudgementTagIds.kongWang),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.changedLine(1))!
          .hasState(JudgementTagIds.kongWang),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.hiddenSpirit(3))!
          .hasState(JudgementTagIds.kongWang),
      isTrue,
    );

    // 月、日是历法基准对象，不进入空亡标签判定。
    expect(
      snapshot.of(SemanticRef.month)!.hasState(JudgementTagIds.kongWang),
      isFalse,
    );
    expect(
      snapshot.of(SemanticRef.day)!.hasState(JudgementTagIds.kongWang),
      isFalse,
    );
  });
  test('records month day and moving chong as independent state tags', () {
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
      id: 'judgement-chong-r3',
      question: '受冲判定区测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '午',
        dayGanZhi: '甲午',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);
    final target = snapshot.of(SemanticRef.line(1))!;

    expect(target.hasState(JudgementTagIds.monthChong), isTrue);
    expect(target.hasState(JudgementTagIds.dayChong), isTrue);
    expect(target.hasState(JudgementTagIds.movingChong), isTrue);
    expect(target.hasState(JudgementTagIds.chong), isTrue);

    // 动爻不以自己作为“动爻冲”的来源。
    final movingSource = snapshot.of(SemanticRef.line(2))!;
    expect(movingSource.hasState(JudgementTagIds.movingChong), isFalse);

    // 变爻当前只记录月冲/日冲，不扩展“动爻 -> 变爻”的未冻结语义。
    final changed = snapshot.of(SemanticRef.changedLine(2))!;
    expect(changed.hasState(JudgementTagIds.monthChong), isTrue);
    expect(changed.hasState(JudgementTagIds.dayChong), isTrue);
    expect(changed.hasState(JudgementTagIds.movingChong), isFalse);
    expect(changed.hasState(JudgementTagIds.chong), isTrue);

    // 月、日是冲的历法来源，不给自身打“受冲”状态。
    expect(
      snapshot.of(SemanticRef.month)!.hasState(JudgementTagIds.chong),
      isFalse,
    );
    expect(
      snapshot.of(SemanticRef.day)!.hasState(JudgementTagIds.chong),
      isFalse,
    );
  });

}
