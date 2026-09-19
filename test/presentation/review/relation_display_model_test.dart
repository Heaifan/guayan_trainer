import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_projection.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/relation_display_model.dart';
import 'package:guayan_trainer/presentation/review/review_relation_filter.dart';

void main() {
  final records = [
    _record(RelationType.sheng),
    _record(RelationType.ke),
    _record(RelationType.huiTouSheng),
    _record(RelationType.huiTouKe),
    _record(RelationType.flyingGeneratesHidden),
    _record(RelationType.flyingOvercomesHidden),
    _record(RelationType.hiddenGeneratesFlying),
    _record(RelationType.hiddenOvercomesFlying),
  ];

  test('display model maps relation type to UI category and visual style', () {
    final models = buildRelationDisplayModels(records);

    expect(models.where((m) => m.isOrdinaryWuxing), hasLength(2));
    expect(models.where((m) => m.isSpecial), hasLength(6));
    expect(
      models.firstWhere((m) => m.type == RelationType.huiTouSheng).visualStyle,
      RelationVisualStyle.returnDashed,
    );
    expect(
      models
          .firstWhere((m) => m.type == RelationType.flyingOvercomesHidden)
          .visualStyle,
      RelationVisualStyle.flyingDotted,
    );
  });

  test(
    'filters only effective relation records and counts live categories',
    () {
      expect(
        filterReviewRelationRecords(records, category: '生克'),
        hasLength(2),
      );
      expect(
        filterReviewRelationRecords(records, category: '特殊'),
        hasLength(6),
      );

      final counts = relationFilterCounts(records);
      expect(counts['全部'], 8);
      expect(counts['生克'], 2);
      expect(counts['特殊'], 6);
    },
  );

  test('does not expose moving transform as a visible relation', () {
    final withMovingTransform = [...records, _record(RelationType.dongBian)];
    final models = buildRelationDisplayModels(withMovingTransform);

    expect(models.any((model) => model.type == RelationType.dongBian), isFalse);
    expect(relationFilterCounts(withMovingTransform)['全部'], 8);
  });
}

RelationRecord _record(RelationType type) =>
    RelationProjection.projectRelationInstances([
      RelationInstance.from(
        type: type,
        ruleId: 'test.${type.machineName}',
        source: YaoEndpoint(LineScope.original, 1),
        target: YaoEndpoint(LineScope.original, 2),
      ),
    ]).single;
