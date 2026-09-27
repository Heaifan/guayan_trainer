import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/return_relation_glyph.dart';

void main() {
  const rowRect = Rect.fromLTWH(0, 0, 402, 44);
  const originalRect = Rect.fromLTWH(226, 19, 24, 6);
  const changedRect = Rect.fromLTWH(278, 19, 24, 6);

  test('回头生使用真实爻槽并限制在本行中央走廊', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: rowRect,
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouSheng,
    );

    expect(geometry.label, '回头生');
    expect(geometry.arrowTip.dx, originalRect.center.dx);
    expect(geometry.arrowTip.dy, originalRect.bottom);
    expect(geometry.pathBounds.left, originalRect.center.dx);
    expect(geometry.pathBounds.right, changedRect.center.dx);
    expect(geometry.pathBounds.bottom, lessThanOrEqualTo(rowRect.bottom - 9));
    expect(geometry.pathBounds.width, lessThan(60));
    expect(geometry.labelCenter.dy, lessThan(rowRect.bottom - 8));
  });

  test('回头克与回头生使用同一局部U形方向且不跨行', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: rowRect,
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouKe,
    );

    expect(geometry.label, '回头克');
    expect(geometry.arrowTip.dx, originalRect.center.dx);
    expect(geometry.arrowTip.dy, originalRect.bottom);
    expect(geometry.arrowBase.dy, greaterThan(geometry.arrowTip.dy));
    expect(geometry.pathBounds.bottom, lessThan(rowRect.bottom));
    expect(geometry.bounds, isNotEmpty);
  });
}
