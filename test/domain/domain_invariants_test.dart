/// T3 · Domain runtime 不变量：不依赖 assert，坏数据（含坏 JSON）
/// 必须在进入关系计算器之前被拒绝，防止生成重复 RelationKey。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_endpoint.dart';
import 'package:guayan_trainer/domain/line_state.dart';

void main() {
  LineState line(int position, {MovementType movement = MovementType.shaoYin}) =>
      LineState(position: position, movementType: movement);

  List<LineState> sixLines({int replaceIndex = -1, int? replacePosition}) {
    final lines = [1, 2, 3, 4, 5, 6].map(line).toList();
    if (replaceIndex >= 0 && replacePosition != null) {
      lines[replaceIndex] = line(replacePosition);
    }
    return lines;
  }

  group('T3 · LineEndpoint 爻位校验', () {
    test('position 1..6 合法', () {
      for (var p = 1; p <= 6; p++) {
        expect(LineEndpoint(LineScope.original, p).position, p);
      }
    });

    test('position 0 与 7 抛 ArgumentError', () {
      expect(() => LineEndpoint(LineScope.original, 0), throwsArgumentError);
      expect(() => LineEndpoint(LineScope.changed, 7), throwsArgumentError);
    });

    test('坏 position 的 JSON 反序列化同样被拒绝', () {
      expect(
        () => LineEndpoint.fromJson({'scope': 'original', 'position': 0}),
        throwsArgumentError,
      );
      expect(
        () => LineEndpoint.fromJson({'scope': 'changed', 'position': 9}),
        throwsArgumentError,
      );
    });
  });

  group('T3 · LineState 爻位校验', () {
    test('position 0 与 7 抛 ArgumentError', () {
      expect(() => line(0), throwsArgumentError);
      expect(() => line(7), throwsArgumentError);
    });

    test('坏 position 的 JSON 反序列化同样被拒绝', () {
      expect(
        () => LineState.fromJson({
              'position': 0,
              'movementType': 'shaoYin',
            }),
        throwsArgumentError,
      );
    });
  });

  group('T3 · HexagramCase 六爻不变量', () {
    test('恰好 6 爻、position 恰为 1..6 时正常构造', () {
      final c = HexagramCase(
        id: 'ok',
        question: '',
        createdAt: DateTime.utc(2026, 8, 27),
        lines: sixLines(),
      );
      expect(c.lines, hasLength(6));
    });

    test('5 爻或 7 爻抛 ArgumentError', () {
      expect(
        () => HexagramCase(
          id: 'bad',
          question: '',
          createdAt: DateTime.utc(2026, 8, 27),
          lines: sixLines().sublist(0, 5),
        ),
        throwsArgumentError,
      );
      expect(
        () => HexagramCase(
          id: 'bad',
          question: '',
          createdAt: DateTime.utc(2026, 8, 27),
          lines: [...sixLines(), line(6)],
        ),
        throwsArgumentError,
      );
    });

    test('position 重复（两个三爻）抛 ArgumentError', () {
      expect(
        () => HexagramCase(
          id: 'dup',
          question: '',
          createdAt: DateTime.utc(2026, 8, 27),
          lines: sixLines(replaceIndex: 5, replacePosition: 3),
        ),
        throwsArgumentError,
      );
    });

    test('position 缺失（无上爻）抛 ArgumentError', () {
      expect(
        () => HexagramCase(
          id: 'missing',
          question: '',
          createdAt: DateTime.utc(2026, 8, 27),
          lines: sixLines(replaceIndex: 5, replacePosition: 5),
        ),
        throwsArgumentError,
      );
    });

    test('坏 JSON：爻数不对 / position 重复 / position 越界 全部被拒绝', () {
      final validLines = [
        for (var p = 1; p <= 6; p++)
          {'position': p, 'movementType': 'shaoYin'},
      ];

      // 5 爻。
      expect(
        () => HexagramCase.fromJson({
              'id': 'c',
              'question': '',
              'createdAt': '2026-08-27T00:00:00.000Z',
              'lines': validLines.sublist(0, 5),
            }),
        throwsArgumentError,
      );

      // position 重复（3 出现两次）。
      final dupLines = [
        ...validLines.sublist(0, 2),
        {'position': 3, 'movementType': 'shaoYin'},
        {'position': 3, 'movementType': 'shaoYin'},
        {'position': 5, 'movementType': 'shaoYin'},
        {'position': 6, 'movementType': 'shaoYin'},
      ];
      expect(
        () => HexagramCase.fromJson({
              'id': 'c',
              'question': '',
              'createdAt': '2026-08-27T00:00:00.000Z',
              'lines': dupLines,
            }),
        throwsArgumentError,
      );

      // position 越界（7）。
      final outOfRange = [
        for (var p = 1; p <= 5; p++)
          {'position': p, 'movementType': 'shaoYin'},
        {'position': 7, 'movementType': 'shaoYin'},
      ];
      expect(
        () => HexagramCase.fromJson({
              'id': 'c',
              'question': '',
              'createdAt': '2026-08-27T00:00:00.000Z',
              'lines': outOfRange,
            }),
        throwsArgumentError,
      );
    });
  });
}
