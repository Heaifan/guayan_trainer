import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';

void main() {
  test('catalog inspection does not alter common runtime outputs', () {
    final rulesBefore = CommonRuleCorpus.v1();
    final snapshot = FactSnapshot.build([
      FactRecord(
        factId: 'f1',
        subject: const SemanticRef('line', '2'),
        predicateId: 'state',
        value: RuleValue.string('xun_kong'),
        origin: FactOrigin.baseRelation,
      ),
    ], []);
    final before = RuleEngine().execute(rulesBefore, snapshot);

    final catalog = SystemKnowledgeRuleCatalog.rules;
    final after = RuleEngine().execute(CommonRuleCorpus.v1(), snapshot);

    expect(catalog, isNotEmpty);
    expect(
      after.ruleHits.map((hit) => hit.ruleId.id).toList(),
      before.ruleHits.map((hit) => hit.ruleId.id).toList(),
    );
    expect(
      after.tags.map((tag) => tag.value.value).toList(),
      before.tags.map((tag) => tag.value.value).toList(),
    );
  });
}
