import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';

void main() {
  group('R5-E FAST-TRACK: COMMON V1 Corpus', () {
    final commonRules = CommonRuleCorpus.v1();

    test('Metadata and 36 rules requirement', () {
      expect(commonRules.length, 36);
      for (final rule in commonRules) {
        expect(rule.namespace, 'common');
        expect(rule.version.version, '1.0.0');
        expect(rule.enabled, true);
        expect(rule.provenance, 'builtin.common.v1');
      }

      final pack = CommonRuleCorpus.packV1(commonRules);
      expect(pack.packId.id, 'common');
      expect(pack.version.version, '1.0.0');
      expect(pack.origin, RuleOrigin.SYSTEM);
      expect(pack.ruleIds.length, 36);
    });

    test('Smoke A: line/2 = xun_kong -> common:state.xun_kong', () {
      final engine = RuleEngine();
      final inputFacts = [
        FactRecord(
          factId: 'f1',
          subject: const SemanticRef('line', '2'),
          predicateId: 'state',
          value: RuleValue.string('xun_kong'),
          origin: FactOrigin.baseRelation,
        ),
      ];
      final snapshot = FactSnapshot.build(inputFacts, []);

      final run = engine.execute(commonRules, snapshot);

      bool hasTag = run.tags.any(
        (t) => t.value.value == 'state.xun_kong' && t.subject.key == '2',
      );
      expect(hasTag, true);

      bool hasHit = run.ruleHits.any(
        (hit) => hit.ruleId.id == 'common.line.2.xun_kong',
      );
      expect(hasHit, true);
    });

    test(
      'Smoke B: calendar/month generate line/2 -> common:relation.month_generate',
      () {
        final engine = RuleEngine();
        final snapshot = FactSnapshot.build([], [
          RuntimeRelation(
            relationId: 'generate',
            subjects: const ['calendar/month', 'line/2'],
            evidenceId: 'e1',
          ),
        ]);

        final run = engine.execute(commonRules, snapshot);

        bool hasTag = run.tags.any(
          (t) =>
              t.value.value == 'relation.month_generate' &&
              t.subject.key == '2',
        );
        expect(hasTag, true);

        bool hasHit = run.ruleHits.any(
          (hit) => hit.ruleId.id == 'common.line.2.month_generate',
        );
        expect(hasHit, true);
      },
    );
  });
}
