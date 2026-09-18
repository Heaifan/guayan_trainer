import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_projection.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/review_relation_filter.dart';

import 'domain_test_utils.dart';

void main() {
  test('month and day effects keep their source semantic category', () {
    final relations = calculateRelations(buildR4Case());
    final monthDay = relations.where(
      (relation) =>
          relation.key.ruleId == SystemRuleIds.monthBranch ||
          relation.key.ruleId == SystemRuleIds.dayBranch,
    );

    expect(monthDay, isNotEmpty);
    expect(
      monthDay,
      everyElement(
        isNot(
          predicate<RelationInstance>(
            (relation) =>
                relation.type == RelationType.sheng ||
                relation.type == RelationType.ke,
          ),
        ),
      ),
    );

    final projected = RelationProjection.projectRelationInstances(relations);
    final monthDayRecords = projected.where(
      (record) =>
          record.ruleId == SystemRuleIds.monthBranch ||
          record.ruleId == SystemRuleIds.dayBranch,
    );
    expect(
      monthDayRecords,
      everyElement(
        predicate<RelationRecord>((record) => record.category == '月日'),
      ),
    );
    expect(
      filterReviewRelationRecords(projected, category: '生克'),
      everyElement(
        isNot(
          predicate<RelationRecord>(
            (record) =>
                record.ruleId == SystemRuleIds.monthBranch ||
                record.ruleId == SystemRuleIds.dayBranch,
          ),
        ),
      ),
    );
  });
}
