import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/return_relation_glyph.dart';

void main() {
  test('return generation uses a local green hook labelled 回生', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: const Rect.fromLTWH(0, 0, 360, 44),
      originalRect: const Rect.fromLTWH(60, 8, 72, 20),
      changedRect: const Rect.fromLTWH(228, 8, 72, 20),
      type: RelationType.huiTouSheng,
    );

    expect(geometry.label, '回生');
    expect(geometry.pathBounds.width, lessThan(260));
    expect(geometry.arrowTip.dx, lessThan(geometry.arrowBase.dx));
    expect(geometry.bounds, isNotEmpty);
  });

  test('return control mirrors the local hook and labels 回克', () {
    final geometry = ReturnRelationGlyph.layout(
      rowRect: const Rect.fromLTWH(0, 0, 360, 44),
      originalRect: const Rect.fromLTWH(228, 8, 72, 20),
      changedRect: const Rect.fromLTWH(60, 8, 72, 20),
      type: RelationType.huiTouKe,
    );

    expect(geometry.label, '回克');
    expect(geometry.pathBounds.width, lessThan(260));
    expect(geometry.arrowTip.dx, greaterThan(geometry.arrowBase.dx));
    expect(geometry.bounds, isNotEmpty);
  });
}
