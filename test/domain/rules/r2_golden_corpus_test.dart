import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/topics/exam/exam_rule_corpus.dart';

void main() {
  test('R2 golden corpus contains the complete 60-rule SYSTEM corpus', () {
    final rules = [...CommonRuleCorpus.v1(), ...ExamRuleCorpus.v1()];
    expect(rules, hasLength(60));
    expect(rules.map((rule) => rule.ruleId.id).toSet(), hasLength(60));

    for (final rule in rules) {
      final portable = PortableRuleCodec.encode(rule);
      final restored = PortableRuleCodec.decode(portable);
      expect(
        PortableRuleCodec.encode(restored),
        portable,
        reason: 'portable semantic drift: ${rule.ruleId.id}',
      );
    }
  });
}
