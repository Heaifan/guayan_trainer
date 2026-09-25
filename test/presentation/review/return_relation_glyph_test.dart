import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/return_relation_glyph.dart';

void main() {
  const originalRect = Rect.fromLTWH(212, 12, 24, 20);
  const changedRect = Rect.fromLTWH(278, 12, 24, 20);

  test('回头生固定从变爻向下回折并进入原爻', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: const Rect.fromLTWH(0, 0, 402, 44),
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouSheng,
    );

    expect(geometry.label, '回头生');
    expect(geometry.arrowTip.dx, originalRect.center.dx);
    expect(geometry.arrowTip.dy, originalRect.bottom);
    expect(geometry.pathBounds.bottom, greaterThan(originalRect.bottom));
    expect(geometry.pathBounds.left, originalRect.center.dx);
    expect(geometry.pathBounds.right, changedRect.center.dx);
  });

  test('回头克与回头生使用同一局部U形方向', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: const Rect.fromLTWH(0, 0, 402, 44),
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouKe,
    );

    expect(geometry.label, '回头克');
    expect(geometry.arrowTip.dx, originalRect.center.dx);
    expect(geometry.arrowTip.dy, originalRect.bottom);
    expect(geometry.arrowBase.dy, greaterThan(geometry.arrowTip.dy));
    expect(geometry.bounds, isNotEmpty);
  });
}
