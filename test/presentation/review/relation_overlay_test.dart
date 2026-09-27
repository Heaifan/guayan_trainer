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

  test('ordinary route can leave endpoint cells after endpoint obstacles are excluded', () {
    final record = RelationRecord.relation(
      id: 'sheng-endpoint-cells',
      sourceKind: RelationSourceKind.fact,
      relationType: RelationType.sheng,
      fromRef: YaoEndpoint(LineScope.original, 3),
      toRef: YaoEndpoint(LineScope.original, 6),
      title: '生',
    );

    final plan = RelationOverlay.planForBounds(
      records: [record],
      bounds: const {
        'yao:original:3': Rect.fromLTWH(226, 119, 24, 6),
        'yao:original:6': Rect.fromLTWH(226, 19, 24, 6),
        'main_line_cell_3': Rect.fromLTWH(136, 100, 114, 44),
        'main_line_cell_6': Rect.fromLTWH(136, 0, 114, 44),
      },
      anchorBounds: const {
        'yao:original:3': Rect.fromLTWH(226, 119, 24, 6),
        'yao:original:6': Rect.fromLTWH(226, 19, 24, 6),
      },
      viewportSize: const Size(402, 264),
    );

    expect(plan.routes, hasLength(1));
    expect(plan.records.single.id, record.id);
  });

  test('null focus renders whole-hexagram relations', () {
    final records = [
      RelationRecord.relation(
        id: 'sheng-global',
        sourceKind: RelationSourceKind.fact,
        relationType: RelationType.sheng,
        fromRef: YaoEndpoint(LineScope.original, 2),
        toRef: YaoEndpoint(LineScope.original, 5),
        title: '生',
      ),
      RelationRecord.relation(
        id: 'ke-global',
        sourceKind: RelationSourceKind.fact,
        relationType: RelationType.ke,
        fromRef: YaoEndpoint(LineScope.original, 4),
        toRef: YaoEndpoint(LineScope.original, 1),
        title: '克',
      ),
    ];

    expect(
      RelationOverlay.visibleRecords(records, focus: null, category: '全部')
          .map((record) => record.id),
      ['ke-global', 'sheng-global'],
    );
  });

  test('real board text anchors keep five ordinary relations paintable', () {
    final records = [
      for (final pair in const [(1, 4), (2, 5), (3, 6), (6, 2), (5, 1)])
        RelationRecord.relation(
          id: 'sheng-${pair.$1}-${pair.$2}',
          sourceKind: RelationSourceKind.fact,
          relationType: RelationType.sheng,
          fromRef: YaoEndpoint(LineScope.original, pair.$1),
          toRef: YaoEndpoint(LineScope.original, pair.$2),
          title: '生',
        ),
    ];

    final anchors = <String, Rect>{
      for (var p = 1; p <= 6; p++)
        'yao:original:$p': Rect.fromLTWH(136, (6 - p) * 45.0 + 8, 64, 16),
    };
    final bounds = <String, Rect>{
      ...anchors,
      for (var p = 1; p <= 6; p++)
        'yao_glyph:yao:original:$p':
            Rect.fromLTWH(226, (6 - p) * 45.0 + 19, 24, 6),
      for (final p in const [1, 3, 5])
        'moving_marker_$p':
            Rect.fromLTWH(254, (6 - p) * 45.0 + 16, 12, 12),
    };

    final plan = RelationOverlay.planForBounds(
      records: records,
      bounds: bounds,
      anchorBounds: anchors,
      viewportSize: const Size(402, 270),
    );

    expect(plan.routes, hasLength(5));
    expect(plan.records, hasLength(5));
    expect(plan.labels, hasLength(5));
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
