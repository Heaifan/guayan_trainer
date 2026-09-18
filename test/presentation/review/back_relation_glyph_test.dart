import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/back_relation_glyph.dart';
import 'package:guayan_trainer/presentation/review/relation_visual_tokens.dart';

void main() {
  final row = Rect.fromLTWH(0, 0, 360, 32);
  final main = Rect.fromLTWH(60, 6, 72, 20);
  final changed = Rect.fromLTWH(228, 6, 72, 20);

  test('back glyph is an open left-facing U-turn with a filled triangle', () {
    final geometry = BackRelationGlyph.layout(
      rowRect: row,
      mainLineRect: main,
      changedLineRect: changed,
    );
    final metric = geometry.path.computeMetrics().single;
    final start = metric.getTangentForOffset(0)!.position;
    final end = metric.getTangentForOffset(metric.length)!.position;

    expect(start, isNot(end));
    expect(geometry.arrowTip.dx, lessThan(geometry.arrowBaseCenter.dx));
    expect(geometry.arrow.contains(geometry.arrowTip), isTrue);
    expect(geometry.bounds.left, greaterThanOrEqualTo(row.left));
    expect(geometry.bounds.right, lessThanOrEqualTo(row.right));
    expect(geometry.bounds.top, greaterThanOrEqualTo(row.top));
    expect(geometry.bounds.bottom, lessThanOrEqualTo(row.bottom));
  });

  test('each Domain position owns its reversed visual row without coordinate guessing', () {
    final rowRects = <int, Rect>{
      for (var position = 1; position <= 6; position++)
        position: Rect.fromLTWH(0, 500 + (6 - position) * 44, 360, 44),
    };
    for (var position = 1; position <= 6; position++) {
      final geometry = BackRelationGlyph.layout(
        rowRect: rowRects[position]!,
        mainLineRect: main,
        changedLineRect: changed,
      );
      expect(geometry.bounds.top, greaterThanOrEqualTo(rowRects[position]!.top));
      expect(geometry.bounds.bottom, lessThanOrEqualTo(rowRects[position]!.bottom));
      expect(geometry.labelCenter.dy, greaterThan(rowRects[position]!.top));
      expect(geometry.labelCenter.dy, lessThan(rowRects[position]!.bottom));
    }
    expect(rowRects[6]!.top, 500);
    expect(rowRects[1]!.top, 720);
  });

  test('back glyph keeps relation-specific color and label semantics', () {
    expect(
      RelationVisualTokens.colorFor(RelationType.huiTouSheng),
      const Color(0xFF2864C7),
    );
    expect(
      RelationVisualTokens.colorFor(RelationType.huiTouKe),
      RelationVisualTokens.colorFor(RelationType.ke),
    );
    expect(RelationVisualTokens.backHookLabel(RelationType.huiTouSheng), '回生');
    expect(RelationVisualTokens.backHookLabel(RelationType.huiTouKe), '回克');
    expect(RelationVisualTokens.backHookLabel(RelationType.dongBian), '动变');
  });
}
