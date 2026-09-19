import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_resolution.dart';
import 'package:guayan_trainer/domain/relation_resolution_model.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  test('five wuxing generation directions are recorded from source to target', () {
    const cases = <String, List<String>>{
      '木生火': ['寅', '午'],
      '火生土': ['午', '辰'],
      '土生金': ['辰', '申'],
      '金生水': ['申', '子'],
      '水生木': ['子', '寅'],
    };

    for (final entry in cases.entries) {
      final relations = calculateRelations(_twoLineCase(entry.value));
      final matches = relations.where((item) => item.type == RelationType.sheng);
      expect(matches, hasLength(1), reason: entry.key);
      final relation = matches.single;
      expect(relation.source, _yao(LineScope.original, 3));
      expect(relation.target, _yao(LineScope.original, 6));
    }
  });

  test('five wuxing overcoming directions are recorded from source to target', () {
    const cases = <String, List<String>>{
      '木克土': ['寅', '辰'],
      '土克水': ['辰', '子'],
      '水克火': ['子', '午'],
      '火克金': ['午', '申'],
      '金克木': ['申', '寅'],
    };

    for (final entry in cases.entries) {
      final relations = calculateRelations(_twoLineCase(entry.value));
      final matches = relations.where((item) => item.type == RelationType.ke);
      expect(matches, hasLength(1), reason: entry.key);
      final relation = matches.single;
      expect(relation.source, _yao(LineScope.original, 3));
      expect(relation.target, _yao(LineScope.original, 6));
    }
  });

  test('Golden Case: three-line earth overcomes six-line water effectively', () {
    final result = resolveRelationResult(_goldenCase());
    final entries = result.entries.where(
      (entry) => entry.relation.type == RelationType.ke,
    );
    final entry = entries.singleWhere(
      (item) =>
          item.relation.source == _yao(LineScope.original, 3) &&
          item.relation.target == _yao(LineScope.original, 6),
    );

    expect(entry.effective, isTrue);
    expect(entry.reason, RelationResolutionReason.effective);
    expect(result.effectiveRelationSet, contains(entry));
  });

  test('a same-position moving line without wuxing relation creates no return relation', () {
    final relations = calculateRelations(
      _caseWithMovement(original: '辰', changed: '丑'),
    );

    expect(
      relations.where(
        (item) =>
            item.type == RelationType.huiTouSheng ||
            item.type == RelationType.huiTouKe,
      ),
      isEmpty,
    );
  });
}

HexagramCase _twoLineCase(List<String> branches) => HexagramCase(
  id: 'wuxing-${branches.join('-')}',
  question: 'wuxing direction',
  createdAt: DateTime.utc(2026, 9, 19),
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin),
    LineState(position: 2, movementType: MovementType.shaoYang),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: branches[0]),
    LineState(position: 4, movementType: MovementType.shaoYin),
    LineState(position: 5, movementType: MovementType.shaoYang),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: branches[1]),
  ],
);

HexagramCase _goldenCase() => HexagramCase(
  id: 'golden-earth-water',
  question: 'three earth overcomes six water',
  createdAt: DateTime.utc(2026, 9, 19),
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin),
    LineState(position: 2, movementType: MovementType.shaoYang),
    LineState(position: 3, movementType: MovementType.laoYang, branch: '辰'),
    LineState(position: 4, movementType: MovementType.shaoYin),
    LineState(position: 5, movementType: MovementType.shaoYang),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '子'),
  ],
);

HexagramCase _caseWithMovement({
  required String original,
  required String changed,
}) => HexagramCase(
  id: 'no-return',
  question: 'no return',
  createdAt: DateTime.utc(2026, 9, 19),
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin),
    LineState(position: 2, movementType: MovementType.shaoYang),
    LineState(
      position: 3,
      movementType: MovementType.laoYang,
      branch: original,
      changedBranch: changed,
    ),
    LineState(position: 4, movementType: MovementType.shaoYin),
    LineState(position: 5, movementType: MovementType.shaoYang),
    LineState(position: 6, movementType: MovementType.shaoYin),
  ],
);

YaoEndpoint _yao(LineScope scope, int position) => YaoEndpoint(scope, position);
