import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';

void main() {
  group('R5-E FAST-TRACK: COMMON V1 Integration', () {
    test('Integration Smoke: Resolver -> Engine', () {
      final commonRules = CommonRuleCorpus.v1();
      final resolved = RuleResolver.resolve(commonRules);
      expect(resolved.activeRules.length, 36);

      final engine = RuleEngine();
      final snapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: const SemanticRef('line', '3'),
          predicateId: 'state',
          value: RuleValue.string('yue_po'),
          origin: FactOrigin.baseRelation,
        ),
      ], []);

      final run1 = engine.execute(resolved.activeRules, snapshot);
      final run2 = engine.execute(resolved.activeRules, snapshot);

      expect(run1.tags.length, run2.tags.length);
      expect(run1.ruleHits.length, run2.ruleHits.length);
      expect(run1.evidenceNodes.length, run2.evidenceNodes.length);

      bool hasTag = run1.tags.any(
        (t) => t.value.value == 'state.yue_po' && t.subject.key == '3',
      );
      expect(hasTag, true);
    });
  });
}
