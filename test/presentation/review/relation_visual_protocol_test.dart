import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/review/relation_visual_tokens.dart';
import 'package:guayan_trainer/presentation/review/widgets/relation_overlay.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';

void main() {
  test('visual tokens keep the frozen action palette and dimensions', () {
    expect(
      RelationVisualTokens.colorFor(RelationType.sheng),
      const Color(0xFF119E57),
    );
    expect(
      RelationVisualTokens.colorFor(RelationType.ke),
      const Color(0xFFD9342B),
    );
    expect(
      RelationVisualTokens.colorFor(RelationType.liuChong),
      const Color(0xFFF57C00),
    );
    expect(
      RelationVisualTokens.colorFor(RelationType.liuHe),
      const Color(0xFF1565C0),
    );
    expect(RelationVisualTokens.strokeNormal, 1.15);
    expect(RelationVisualTokens.strokeFocused, 1.40);
    expect(RelationVisualTokens.arrowSize, 4.20);
    expect(RelationVisualTokens.anchorRadius, 2.20);
    expect(RelationVisualTokens.opacityAll, 1.00);
    expect(RelationVisualTokens.opacityFocused, 1.00);
  });

  test('only symmetric actions use double arrow protocol', () {
    expect(RelationVisualTokens.isBidirectional(RelationType.sheng), isFalse);
    expect(RelationVisualTokens.isBidirectional(RelationType.ke), isFalse);
    expect(RelationVisualTokens.isBidirectional(RelationType.liuChong), isTrue);
    expect(RelationVisualTokens.isBidirectional(RelationType.liuHe), isTrue);
  });

  test('overlay excludes STATE records and focuses by participants', () {
    final line = YaoEndpoint(LineScope.original, 1);
    final state = RelationRecord.state(
      id: 'state',
      sourceKind: RelationSourceKind.fact,
      stateType: RelationStateType.xunKong,
      participants: [line],
      title: '旬空',
    );
    final relation = RelationRecord.relation(
      id: 'relation',
      sourceKind: RelationSourceKind.fact,
      relationType: RelationType.sheng,
      fromRef: line,
      toRef: YaoEndpoint(LineScope.original, 2),
      title: '初生二',
    );

    expect(RelationOverlay.visibleRecords([state, relation]), isEmpty);
    expect(RelationOverlay.visibleRecords([state, relation], focus: line), [
      relation,
    ]);
  });
}
