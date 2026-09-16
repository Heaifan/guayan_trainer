import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/topics/exam/exam_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/topics/topic_pack_composer.dart';

void main() {
  group('R5-F Round 1: Composer & Boundary Validator', () {
    final commonRules = CommonRuleCorpus.v1();
    final commonPack = CommonRuleCorpus.packV1(commonRules);
    final examRules = ExamRuleCorpus.v1();
    final examPack = ExamRuleCorpus.packV1(examRules);

    test('Smoke A: Topic 未选择', () {
      final res = RulePackComposer.compose(
        commonPack: commonPack,
        commonRules: commonRules,
        availableTopics: [examPack],
        selectedTopicIds: [],
        topicRules: {examPack.packId: examRules},
      );
      expect(res.selectedPacks.length, 1);
      expect(res.selectedPacks.first.packId.id, 'common');
      expect(res.composedRules.length, 36);
    });

    test('Smoke B: Topic 已选择', () {
      final res = RulePackComposer.compose(
        commonPack: commonPack,
        commonRules: commonRules,
        availableTopics: [examPack],
        selectedTopicIds: ['exam'],
        topicRules: {examPack.packId: examRules},
      );
      expect(res.selectedPacks.length, 2);
      expect(res.composedRules.length, 36 + 24);
      expect(res.composedRules.where((r) => r.categoryId == 'exam').length, 24);
    });

    test('Smoke C: Namespace Isolation', () {
      final badRule = RuleDefinition(
        ruleId: RuleId('bad'),
        version: RuleVersion('1.0.0'),
        origin: RuleOrigin.SYSTEM,
        namespace: 'topic.exam',
        categoryId: 'exam',
        stage: RuleStage.tag,
        title: 'bad',
        description: 'bad',
        provenance: 'bad',
        bindings: [],
        condition: PredicateExpr(
          operatorId: 'has_tag',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('wealth')),
            LiteralOperand(RuleValue.string('tag')),
          ],
        ),
        actions: [
          TagAction(categoryId: 'exam', tagId: 'bad', subjectBinding: 'A'),
        ],
      );

      expect(
        () => RulePackComposer.compose(
          commonPack: commonPack,
          commonRules: commonRules,
          availableTopics: [examPack],
          selectedTopicIds: ['exam'],
          topicRules: {
            examPack.packId: [badRule],
          },
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
