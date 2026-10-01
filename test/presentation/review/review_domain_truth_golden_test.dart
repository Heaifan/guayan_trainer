import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';

void main() {
  test('大畜变谦：显示事实与关系事实使用同一 canonical 排盘', () {
    final state = ReviewCaseAdapter.adapt(_staleGoldenCase());
    final lines = [...state.lines]..sort((a, b) => a.position.compareTo(b.position));

    expect(
      lines.map((line) => line.identity!.ganZhi),
      ['甲子', '甲寅', '甲辰', '丙戌', '丙子', '丙寅'],
    );
    expect(
      lines.map((line) => line.changed!.identity!.ganZhi),
      ['丙辰', '丙午', '丙申', '癸丑', '癸亥', '癸酉'],
    );

    final ordinary = state.relationRecords.where(
      (record) =>
          record.relationType == RelationType.sheng ||
          record.relationType == RelationType.ke,
    );
    final signatures = ordinary.map(_signature).toList()..sort();
    expect(signatures, ['克:2>3', '克:2>4']);
  });

  test('同五行永不产生普通生克事实', () {
    const pairs = [
      ['子', '亥'],
      ['寅', '卯'],
      ['巳', '午'],
      ['申', '酉'],
      ['辰', '戌'],
    ];
    for (final pair in pairs) {
      final relations = calculateRelations(_twoLineCase(pair));
      expect(
        relations.where(
          (item) =>
              item.type == RelationType.sheng ||
              item.type == RelationType.ke,
        ),
        isEmpty,
        reason: '${pair[0]} / ${pair[1]}',
      );
    }
  });
}

String _signature(dynamic record) {
  final from = record.fromRef as YaoEndpoint;
  final to = record.toRef as YaoEndpoint;
  final type = record.relationType == RelationType.ke ? '克' : '生';
  return '$type:${from.position}>${to.position}';
}

HexagramCase _staleGoldenCase() => HexagramCase(
  id: 'golden-da-xu-qian',
  question: '排盘真值校验',
  createdAt: DateTime(2026, 9, 30, 10, 36),
  lines: [
    LineState(position: 1, movementType: MovementType.laoYang, branch: '子', changedBranch: '子'),
    LineState(position: 2, movementType: MovementType.laoYang, branch: '子', changedBranch: '子'),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: '子'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '子'),
    LineState(position: 5, movementType: MovementType.shaoYin, branch: '子'),
    LineState(position: 6, movementType: MovementType.laoYang, branch: '子', changedBranch: '子'),
  ],
);

HexagramCase _twoLineCase(List<String> branches) => HexagramCase(
  id: 'same-element-${branches.join('-')}',
  question: '同五行守门',
  createdAt: DateTime(2026, 9, 30),
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin),
    LineState(position: 2, movementType: MovementType.shaoYang),
    LineState(position: 3, movementType: MovementType.shaoYang, branch: branches[0]),
    LineState(position: 4, movementType: MovementType.shaoYin),
    LineState(position: 5, movementType: MovementType.shaoYang),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: branches[1]),
  ],
);
