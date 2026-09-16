import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/domain/rules/engine/runtime_rule_set_assembler.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/topics/exam/exam_rule_corpus.dart';

RuleDefinition _makeRule() => RuleDefinition(
  ruleId: RuleId('custom_1'),
  version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM,
  namespace: 'topic.exam',
  categoryId: 'exam',
  stage: RuleStage.tag,
  title: 'Custom',
  description: '',
  provenance: '',
  bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
  condition: PredicateExpr(
    operatorId: 'relative',
    operands: [
      BindingRefOperand('A'),
      LiteralOperand(RuleValue.string('fuMu')),
    ],
  ),
  actions: [
    TagAction(categoryId: 'exam', tagId: 'custom_parent', subjectBinding: 'A'),
  ],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'CUSTOM rule -> Engine -> exam:custom_parent (Selected & Unselected)',
    () async {
      final service = CustomRuleService(
        CustomRuleStore(),
        UserGovernanceState(),
      );
      await service.load();
      await service.store.addOrUpdate(_makeRule());

      final examRules = ExamRuleCorpus.v1();
      final examPack = ExamRuleCorpus.packV1(examRules);

      final assembler = RuntimeRuleSetAssembler(
        customRuleService: service,
        availableTopics: [examPack],
        topicRulesMap: {examPack.packId: examRules},
      );

      final snapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: const SemanticRef('line', '2'),
          predicateId: 'relative',
          value: RuleValue.string('fuMu'),
          origin: FactOrigin.baseRelation,
        ),
      ], []);

      // 1. Selected exam
      var resolved = assembler.assemble(['exam']);
      var result = RuleEngine().execute(resolved.activeRules, snapshot);
      var tagStrs = result.tags
          .map(
            (f) =>
                "${f.predicateId.replaceFirst('has_tag_', '')}:${f.value.value}",
          )
          .toList();
      expect(tagStrs, contains('exam:custom_parent'));
      expect(result.ruleHits.any((h) => h.ruleId.id == 'custom_1'), isTrue);

      // 2. Unselected exam
      resolved = assembler.assemble([]);
      result = RuleEngine().execute(resolved.activeRules, snapshot);
      tagStrs = result.tags
          .map(
            (f) =>
                "${f.predicateId.replaceFirst('has_tag_', '')}:${f.value.value}",
          )
          .toList();
      expect(tagStrs, isNot(contains('exam:custom_parent')));
      expect(result.ruleHits.any((h) => h.ruleId.id == 'custom_1'), isFalse);
    },
  );
}
