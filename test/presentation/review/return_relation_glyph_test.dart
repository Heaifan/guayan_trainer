import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/return_relation_glyph.dart';

void main() {
  const rowRect = Rect.fromLTWH(0, 0, 402, 44);
  const originalRect = Rect.fromLTWH(226, 19, 24, 6);
  const changedRect = Rect.fromLTWH(278, 19, 24, 6);

  test('回头生固定为变爻到原爻且最后一段水平指向原爻', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: rowRect,
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouSheng,
    );

    expect(geometry.label, '回头生');
    // 原爻在左，因此箭头落在原爻右侧边缘，并从右向左进入。
    expect(geometry.arrowTip, Offset(originalRect.right, originalRect.center.dy));
    expect(geometry.arrowBase.dy, geometry.arrowTip.dy);
    expect(geometry.arrowBase.dx, greaterThan(geometry.arrowTip.dx));
    expect(geometry.pathBounds.left, originalRect.right);
    expect(geometry.pathBounds.right, changedRect.left);
    expect(geometry.pathBounds.bottom, lessThan(rowRect.bottom));
  });

  test('回头克与回头生共用同一变到原方向且不跨行', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: rowRect,
      originalRect: originalRect,
      changedRect: changedRect,
      type: RelationType.huiTouKe,
    );

    expect(geometry.label, '回头克');
    expect(geometry.arrowTip.dx, originalRect.right);
    expect(geometry.arrowBase.dx, greaterThan(geometry.arrowTip.dx));
    expect(geometry.arrowBase.dy, geometry.arrowTip.dy);
    expect(geometry.pathBounds.bottom, lessThan(rowRect.bottom));
    expect(geometry.bounds, isNotEmpty);
  });

  test('镜像布局时仍然是变爻指向原爻', () {
    const mirroredOriginal = Rect.fromLTWH(300, 19, 24, 6);
    const mirroredChanged = Rect.fromLTWH(240, 19, 24, 6);
    final geometry = ReturnRelationGlyph.layout(
      rowRect: rowRect,
      originalRect: mirroredOriginal,
      changedRect: mirroredChanged,
      type: RelationType.huiTouSheng,
    );

    expect(
      geometry.arrowTip,
      Offset(mirroredOriginal.left, mirroredOriginal.center.dy),
    );
    expect(geometry.arrowBase.dx, lessThan(geometry.arrowTip.dx));
  });
}
