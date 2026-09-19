import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/widgets/relation_overlay.dart';

void main() {
  test('first frame with missing RenderBox bounds produces no route plan', () {
    final record = RelationRecord.relation(
      id: 'ke',
      sourceKind: RelationSourceKind.fact,
      relationType: RelationType.ke,
      fromRef: YaoEndpoint(LineScope.original, 3),
      toRef: YaoEndpoint(LineScope.original, 6),
      title: '克',
    );

    final plan = RelationOverlay.planForBounds(
      records: [record],
      bounds: const {},
      anchorBounds: const {},
      viewportSize: const Size(400, 600),
    );

    expect(plan.routes, isEmpty);
    expect(plan.labels, isEmpty);
  });

  test('review projection excludes non-renderer records but preserves four labels', () {
    final records = [
      for (final type in [
        RelationType.sheng,
        RelationType.ke,
        RelationType.huiTouSheng,
        RelationType.huiTouKe,
        RelationType.liuHe,
        RelationType.flyingOvercomesHidden,
      ])
        RelationRecord.relation(
          id: type.machineName,
          sourceKind: RelationSourceKind.fact,
          relationType: type,
          fromRef: YaoEndpoint(LineScope.original, 3),
          toRef: YaoEndpoint(LineScope.original, 6),
          title: type.displayName,
        ),
    ];

    expect(RelationOverlay.drawableRecords(records).map((item) => item.id), [
      'hui_tou_ke',
      'hui_tou_sheng',
      'ke',
      'sheng',
    ]);
  });
}
