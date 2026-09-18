import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  test('back relation direction is changed line to original moving line', () {
    final relations = calculateRelationResult(
      _case(original: '卯', changed: '申'),
    ).instances.where((r) => r.type == RelationType.huiTouKe);

    final relation = relations.single;
    expect(relation.source, YaoEndpoint(LineScope.changed, 3));
    expect(relation.target, YaoEndpoint(LineScope.original, 3));
  });

  test('back generation and control use the five wuxing directions', () {
    final cases = <String, RelationType>{
      '卯|申': RelationType.huiTouKe,
      '午|子': RelationType.huiTouKe,
      '辰|寅': RelationType.huiTouKe,
      '卯|子': RelationType.huiTouSheng,
      '午|寅': RelationType.huiTouSheng,
      '申|辰': RelationType.huiTouSheng,
    };

    for (final entry in cases.entries) {
      final parts = entry.key.split('|');
      final relations = calculateRelationResult(
        _case(original: parts[0], changed: parts[1]),
      ).instances;
      expect(
        relations.where((r) => r.type == entry.value),
        hasLength(1),
        reason: entry.key,
      );
    }
  });

  test('back relation is same-position and never emitted for static lines', () {
    final static = _case(original: '卯', changed: '申', moving: false);

    final relation = calculateRelationResult(
      _case(original: '卯', changed: '申'),
    ).instances.firstWhere(_isBack);
    expect(
      (relation.source as YaoEndpoint).position,
      (relation.target as YaoEndpoint).position,
    );
    expect(calculateRelationResult(static).instances.where(_isBack), isEmpty);
  });

  test('reverse wuxing direction is not mislabeled as back control', () {
    final relations = calculateRelationResult(
      _case(original: '申', changed: '卯'),
    ).instances;

    expect(
      relations.where(
        (r) =>
            r.type == RelationType.huiTouKe ||
            r.type == RelationType.huiTouSheng,
      ),
      isEmpty,
    );
  });

  test('two moving lines produce two independent back relations', () {
    final hexagram = HexagramCase(
      id: 'back-two',
      question: 'two back relations',
      createdAt: DateTime.utc(2026, 9, 18),
      lines: [
        LineState(position: 1, movementType: MovementType.shaoYin, branch: '亥'),
        LineState(
          position: 2,
          movementType: MovementType.shaoYang,
          branch: '丑',
        ),
        LineState(
          position: 3,
          movementType: MovementType.laoYang,
          branch: '卯',
          changedBranch: '申',
        ),
        LineState(
          position: 4,
          movementType: MovementType.laoYin,
          branch: '午',
          changedBranch: '子',
        ),
        LineState(
          position: 5,
          movementType: MovementType.shaoYang,
          branch: '申',
        ),
        LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
      ],
    );

    final back = calculateRelationResult(
      hexagram,
    ).instances.where((r) => r.type == RelationType.huiTouKe);
    expect(back, hasLength(2));
    expect(back.map((r) => (r.source as YaoEndpoint).position), {3, 4});
  });
}

HexagramCase _case({
  required String original,
  required String changed,
  int position = 3,
  bool moving = true,
}) => HexagramCase(
  id: 'back-$original-$changed-$position-$moving',
  question: 'back relation test',
  createdAt: DateTime.utc(2026, 9, 18),
  lines: [
    for (var i = 1; i <= 6; i++)
      LineState(
        position: i,
        movementType: i == position && moving
            ? MovementType.laoYang
            : MovementType.shaoYang,
        branch: i == position ? original : '亥',
        changedBranch: i == position ? changed : null,
      ),
  ],
);

bool _isBack(dynamic relation) =>
    relation.type == RelationType.huiTouSheng ||
    relation.type == RelationType.huiTouKe;
