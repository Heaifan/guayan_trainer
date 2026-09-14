import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('SchemaValidator Core Tests', () {
    test('valid rule', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}],
        'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]},
        'actions': [{'type': 'derive', 'target': 'A'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);
    });

    test('SemVer exact validation', () {
      final rule = {'schemaVersion': 1, 'ruleId': 'r1', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}, 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.0.0'}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.2.3'}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': ''}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': 'abc'}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.0'}), throwsFormatException);
    });

    test('unsupported schemaVersion', () {
      expect(() => RuleSchemaValidator.validate({'schemaVersion': 2, 'ruleId': 'r1', 'version': '1.0.0'}), throwsFormatException);
    });

    test('empty RuleId or invalid RuleVersion', () {
      expect(() => RuleSchemaValidator.validate({'schemaVersion': 1, 'ruleId': '', 'version': '1.0.0'}), throwsFormatException);
    });

    test('executable payload rejected recursively', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}],
        'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]},
        'actions': [{'type': 'record', 'recordType': 'r', 'content': {'script': 'malicious'}}]
      };
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });
  });
}
