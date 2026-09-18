import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_rules/changed_lines.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  final elements = <String, String>{
    '木': '寅',
    '火': '午',
    '土': '丑',
    '金': '申',
    '水': '子',
  };
  final generate = <List<String>>[
    ['木', '火'],
    ['火', '土'],
    ['土', '金'],
    ['金', '水'],
    ['水', '木'],
  ];
  final overcome = <List<String>>[
    ['木', '土'],
    ['土', '水'],
    ['水', '火'],
    ['火', '金'],
    ['金', '木'],
  ];

  test('five back-generate directions × six Domain line numbers = 30', () {
    for (final pair in generate) {
      for (var position = 1; position <= 6; position++) {
        expect(
          classifyBackRelation(
            original: _line(position, elements[pair[1]]!),
            changedPosition: position,
            changedBranch: elements[pair[0]],
          ),
          RelationType.huiTouSheng,
          reason: '${pair[0]}→${pair[1]} at line $position',
        );
      }
    }
  });

  test('five back-overcome directions × six Domain line numbers = 30', () {
    for (final pair in overcome) {
      for (var position = 1; position <= 6; position++) {
        expect(
          classifyBackRelation(
            original: _line(position, elements[pair[1]]!),
            changedPosition: position,
            changedBranch: elements[pair[0]],
          ),
          RelationType.huiTouKe,
          reason: '${pair[0]}→${pair[1]} at line $position',
        );
      }
    }
  });

  test('non-moving, same-element, missing and cross-position inputs are none', () {
    expect(
      classifyBackRelation(
        original: _line(6, '子', moving: false),
        changedPosition: 6,
        changedBranch: '未',
      ),
      isNull,
    );
    expect(
      classifyBackRelation(
        original: _line(6, '丑'),
        changedPosition: 6,
        changedBranch: '未',
      ),
      isNull,
    );
    expect(
      classifyBackRelation(
        original: _line(6, '丑'),
        changedPosition: 5,
        changedBranch: '午',
      ),
      isNull,
    );
    expect(
      classifyBackRelation(
        original: _line(6, null),
        changedPosition: 6,
        changedBranch: '午',
      ),
      isNull,
    );
  });
}

LineState _line(int position, String? branch, {bool moving = true}) => LineState(
  position: position,
  movementType: moving ? MovementType.laoYang : MovementType.shaoYang,
  branch: branch,
);
