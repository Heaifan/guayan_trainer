import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('SchemaValidator Binding Tests', () {
    test('duplicate binding', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't2'}}
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });

    test('Binding two-pass validation (Forward reference)', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [
          {'name': 'B', 'selector': {'type': 'relative', 'base': 'A', 'path': 'x'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
        ],
        'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]},
        'actions': [{'type': 'derive', 'target': 'B'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);

      final badRule = {...rule, 'bindings': [
          {'name': 'B', 'selector': {'type': 'relative', 'base': 'UNKNOWN', 'path': 'x'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
      ]};
      expect(() => RuleSchemaValidator.validate(badRule), throwsFormatException);
    });
  });
}
