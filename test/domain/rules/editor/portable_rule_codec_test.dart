import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';

void main() {
  test('portable JSON round-trip preserves runtime rule semantics', () {
    final original = CommonRuleCorpus.v1().first;
    final json = PortableRuleCodec.encode(original);
    final restored = PortableRuleCodec.decode(json);

    expect(json['schemaVersion'], '1.0.0');
    expect(
      RuleDefinitionCodec.toJson(restored),
      RuleDefinitionCodec.toJson(original),
    );
  });

  test('portable JSON rejects unknown schema', () {
    expect(
      () => PortableRuleCodec.fromJson({'schemaVersion': '9.0.0'}),
      throwsFormatException,
    );
  });
}
