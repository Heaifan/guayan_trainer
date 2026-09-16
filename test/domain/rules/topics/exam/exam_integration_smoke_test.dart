import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';
import 'package:guayan_trainer/domain/rules/topics/exam/exam_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/topics/topic_pack_composer.dart';

void main() {
  group('R5-F Round 2: Integration Smoke', () {
    test('line/2 fuMu + xun_kong yields common and exam tags deterministically', () {
      final commonRules = CommonRuleCorpus.v1();
      final commonPack = CommonRuleCorpus.packV1(commonRules);
      final examRules = ExamRuleCorpus.v1();
      final examPack = ExamRuleCorpus.packV1(examRules);

      final composed = RulePackComposer.compose(
        commonPack: commonPack,
        commonRules: commonRules,
        availableTopics: [examPack],
        selectedTopicIds: ['exam'],
        topicRules: {examPack.packId: examRules},
      );

      final resolved = RuleResolver.resolve(composed.composedRules);

      final snapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: const SemanticRef('line', '2'),
          predicateId: 'relative',
          value: RuleValue.string('fuMu'),
          origin: FactOrigin.baseRelation,
        ),
        FactRecord(
          factId: 'f2',
          subject: const SemanticRef('line', '2'),
          predicateId: 'state',
          value: RuleValue.string('xun_kong'),
          origin: FactOrigin.baseRelation,
        ),
      ], []);

      final engine = RuleEngine();
      final result1 = engine.execute(resolved.activeRules, snapshot);
      
      final tagStrs = result1.tags.map((f) => "${f.predicateId.replaceFirst('has_tag_', '')}:${f.value.value}").toList();

      expect(tagStrs, contains('common:state.xun_kong'));
      expect(tagStrs, contains('exam:role.fu_mu'));
      expect(tagStrs, contains('exam:state.fu_mu_xun_kong'));

      final hitXunKong = result1.ruleHits.any((h) => h.ruleId.id == 'exam.line.2.state.fu_mu_xun_kong');
      expect(hitXunKong, isTrue);
      
      final examEvidence = result1.ruleHits.firstWhere((h) => h.ruleId.id == 'exam.line.2.state.fu_mu_xun_kong').supports;
      expect(examEvidence.isNotEmpty, isTrue);

      final result2 = engine.execute(resolved.activeRules, snapshot);
      expect(result2.ruleHits.length, result1.ruleHits.length);
      expect(result2.tags.length, result1.tags.length);
    });
  });
}
