import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/governance/rule_resolver.dart';
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
      'Smoke B: month generate line/2 -> common:relation.month_generate',
      () {
        final engine = RuleEngine();
        final snapshot = FactSnapshot.build([], [
          RuntimeRelation(
            relationId: 'generate',
            subjects: const ['month/M', 'line/2'],
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

    test('Integration Smoke: Resolver -> Engine', () {
      // 36 rules -> Resolver
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

      // Determinism check
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
