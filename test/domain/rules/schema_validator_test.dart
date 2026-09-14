import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('SchemaValidator Fail Closed (T3)', () {
    test('valid rule', () {
      final rule = {
        'schemaVersion': 1,
        'ruleId': 'r1',
        'version': '1.0.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'direct', 'target': 'line/2'}}
        ],
        'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE', 'operatorId': 'x', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}]},
        'actions': [
          {'type': 'derive', 'target': 'A', 'factKey': 'key'}
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);
    });

    test('unsupported schemaVersion', () {
      final rule = {'schemaVersion': 'guayan-rule@0.1', 'ruleId': 'r1'};
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });

    test('empty RuleId or invalid RuleVersion', () {
      expect(() => RuleSchemaValidator.validate({'schemaVersion': 1, 'ruleId': ''}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({'schemaVersion': 1, 'ruleId': 'r1', 'version': ''}), throwsFormatException);
    });

    test('duplicate binding', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't2'}}
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });

    test('invalid selector & relative unknown base', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0',
        'bindings': [
          {'name': 'A', 'selector': {'type': 'unknown'}},
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);

      final rule2 = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0',
        'bindings': [
          {'name': 'B', 'selector': {'type': 'relative', 'base': 'A', 'path': 'x'}},
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule2), throwsFormatException);
    });

    test('empty ALL, ANY, missing NOT, unknown AST', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};

      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'ALL', 'nodes': []}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'ANY', 'nodes': []}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'NOT'}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'UNKNOWN'}}), throwsFormatException);
    });

    test('unknown operand & unbound BindingRef', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operands': [{'type': 'unknown'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operands': [{'type': 'bindingRef', 'name': 'B'}]}}), throwsFormatException);
    });

    test('actions checks', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]}};
      expect(() => RuleSchemaValidator.validate({...base, 'actions': []}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'unknown'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'derive', 'target': 'B'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'tag', 'categoryId': '', 'tagId': 'x'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'tag', 'categoryId': 'c', 'tagId': ''}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'tag', 'categoryId': 'c', 'tagId': 't', 'subject': 'B'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'structure', 'structureId': '', 'members': ['A']}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'structure', 'structureId': 's', 'members': ['B']}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': '', 'content': {}}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r'}]}), throwsFormatException);
    });

    test('executable payload rejected recursively', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0',
        'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}],
        'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]},
        'actions': [
          {'type': 'record', 'recordType': 'r', 'content': {'nested': {'script': 'malicious'}}}
        ]
      };
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });
  });
}
