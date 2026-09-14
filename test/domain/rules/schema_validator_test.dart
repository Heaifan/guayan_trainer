import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('F1.10 Structural Validator', () {
    final validJson = {
      'ruleId': 'r1', 'version': '1', 'origin': 'SYSTEM', 'namespace': 'ns',
      'categoryId': 'cat', 'stage': 'baseRelation', 'title': 't', 'description': 'd',
      'provenance': 'p', 'bindings': [{'name': 'A', 'selector': {'type':'direct', 'target':'1'}}],
      'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE', 'operatorId': 'op', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}]},
      'actions': [{'type': 'tag', 'categoryId': 'cat', 'tagId': 'tag'}],
      'enabled': true, 'reviewState': 'APPROVED', 'schemaVersion': 1,
    };

    test('Valid rule passes', () {
      expect(() => RuleSchemaValidator.validate(validJson), returnsNormally);
    });

    test('Rejects executable fields', () {
      final j = Map<String, dynamic>.from(validJson)..['script'] = 'var x = 1;';
      expect(() => RuleSchemaValidator.validate(j), throwsFormatException);
    });

    test('Rejects duplicate binding', () {
      final j = Map<String, dynamic>.from(validJson);
      j['bindings'] = [
        {'name': 'A', 'selector': {'type':'direct', 'target':'1'}},
        {'name': 'A', 'selector': {'type':'direct', 'target':'2'}},
      ];
      expect(() => RuleSchemaValidator.validate(j), throwsFormatException);
    });

    test('Rejects unbound bindingRef', () {
      final j = Map<String, dynamic>.from(validJson);
      j['condition'] = {'type': 'PREDICATE', 'operatorId': 'op', 'operands': [{'type': 'bindingRef', 'name': 'B'}]}; // B is unbound
      expect(() => RuleSchemaValidator.validate(j), throwsFormatException);
    });

    test('Rejects empty ALL/ANY', () {
      final j = Map<String, dynamic>.from(validJson);
      j['condition'] = {'type': 'ALL', 'nodes': []};
      expect(() => RuleSchemaValidator.validate(j), throwsFormatException);
    });
  });
}
