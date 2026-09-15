import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('Golden Rules Validator Tests', () {
    test('Golden NaYin Rule (nayin_is + relative)', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}],
        'condition': {
          'type': 'ALL',
          'nodes': [
            {'type': 'PREDICATE', 'operatorId': 'nayin_is', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'nayin.tian_he_shui'}]},
            {'type': 'PREDICATE', 'operatorId': 'relative', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'relative.parent'}]},
          ]
        },
        'actions': [{'type': 'tag', 'categoryId': 'exam', 'tagId': 'document', 'subject': 'A'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);
    });

    test('Golden Original Rule (compatibility)', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
          {'name': 'M', 'selector': {'type': 'direct', 'target': 't2'}}
        ],
        'condition': {
          'type': 'ALL',
          'nodes': [
            {'type': 'PREDICATE', 'operatorId': 'relative', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'fuMu'}]},
            {'type': 'PREDICATE', 'operatorId': 'spirit', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'azureDragon'}]},
            {'type': 'PREDICATE', 'operatorId': 'generate', 'operands': [{'type': 'bindingRef', 'name': 'M'}, {'type': 'bindingRef', 'name': 'A'}]},
            {'type': 'NOT', 'node': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}},
          ]
        },
        'actions': [{'type': 'derive', 'target': 'A'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);
    });

    test('Tomb Golden', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r3', 'version': '1.0.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
          {'name': 'M', 'selector': {'type': 'direct', 'target': 't2'}},
          {'name': 'D', 'selector': {'type': 'direct', 'target': 't3'}},
        ],
        'condition': {
          'type': 'ALL',
          'nodes': [
            {'type': 'PREDICATE', 'operatorId': 'ru_mu', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'bindingRef', 'name': 'M'}]},
            {'type': 'PREDICATE', 'operatorId': 'chong_mu', 'operands': [{'type': 'bindingRef', 'name': 'D'}, {'type': 'bindingRef', 'name': 'M'}]},
            {'type': 'PREDICATE', 'operatorId': 'chu_mu', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'bindingRef', 'name': 'M'}, {'type': 'bindingRef', 'name': 'D'}]},
          ]
        },
        'actions': [{'type': 'derive', 'target': 'A'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);
    });
  });
}
