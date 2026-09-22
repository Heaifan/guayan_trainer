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

  test('xun kong tags original changed and hidden objects only', () {
    // 水雷屯的原卦阴阳结构；伏神为三爻妻财午火。
    // 甲申旬空午未，因此原1午、变1未、伏神3午都应标记旬空。
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
      id: 'judgement-empty-r2',
      question: '旬空判定区测试',
      lines: lines,
      createdAt: DateTime(2026, 9, 22),
      calendar: const CalendarSnapshot(
        monthBranch: '午',
        dayGanZhi: '甲申',
      ),
    );

    final snapshot = ElementJudgementBuilder.build(hexagramCase);

    expect(
      snapshot.of(SemanticRef.line(1))!.hasState(JudgementTagIds.empty),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.changedLine(1))!
          .hasState(JudgementTagIds.empty),
      isTrue,
    );
    expect(
      snapshot
          .of(SemanticRef.hiddenSpirit(3))!
          .hasState(JudgementTagIds.empty),
      isTrue,
    );

    // 月、日是历法基准对象，不进入旬空标签判定。
    expect(
      snapshot.of(SemanticRef.month)!.hasState(JudgementTagIds.empty),
      isFalse,
    );
    expect(
      snapshot.of(SemanticRef.day)!.hasState(JudgementTagIds.empty),
      isFalse,
    );
  });
}
