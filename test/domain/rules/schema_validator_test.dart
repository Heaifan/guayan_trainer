import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('SchemaValidator Fail Closed (T3B)', () {
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

    test('SemVer exact validation (T1)', () {
      final rule = {'schemaVersion': 1, 'ruleId': 'r1', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]}, 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.0.0'}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.2.3'}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': ''}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': 'abc'}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1'}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...rule, 'version': '1.0'}), throwsFormatException);
    });

    test('Record scalar contract (T2)', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]}};
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': 1, 'b': 'str', 'c': true, 'd': 1.5, 'e': null}}]}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': {'nested': 1}}}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': [1, 2]}}]}), throwsFormatException);
    });

    test('Binding two-pass validation (T3)', () {
      final rule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [
          {'name': 'B', 'selector': {'type': 'relative', 'base': 'A', 'path': 'x'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
        ],
        'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]},
        'actions': [{'type': 'derive', 'target': 'B'}]
      };
      expect(() => RuleSchemaValidator.validate(rule), returnsNormally);

      final badRule = {
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [
          {'name': 'B', 'selector': {'type': 'relative', 'base': 'UNKNOWN', 'path': 'x'}},
          {'name': 'A', 'selector': {'type': 'direct', 'target': 't'}},
        ],
        'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]},
        'actions': [{'type': 'derive', 'target': 'B'}]
      };
      expect(() => RuleSchemaValidator.validate(badRule), throwsFormatException);
    });

    test('unsupported schemaVersion', () {
      final rule = {'schemaVersion': 'guayan-rule@0.1', 'ruleId': 'r1'};
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });

    test('empty RuleId or invalid RuleVersion', () {
      expect(() => RuleSchemaValidator.validate({'schemaVersion': 1, 'ruleId': ''}), throwsFormatException);
    });

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

    test('empty ALL, ANY, missing NOT, unknown AST', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'ALL', 'nodes': []}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'ANY', 'nodes': []}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'NOT'}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'UNKNOWN'}}), throwsFormatException);
    });

    test('unknown operand & unbound BindingRef', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operands': [{'type': 'unknown'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operands': [{'type': 'bindingRef', 'name': 'B'}]}}), throwsFormatException);
    });

    test('actions checks', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]}};
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
        'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0',
        'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}],
        'condition': {'type': 'ALL', 'nodes': [{'type': 'PREDICATE'}]},
        'actions': [
          {'type': 'record', 'recordType': 'r', 'content': {'nested': {'script': 'malicious'}}}
        ]
      };
      // 'nested' will actually be rejected first by the scalar check now, but let's make sure it doesn't get past executable check either.
      // Executable check runs first in validate().
      expect(() => RuleSchemaValidator.validate(rule), throwsFormatException);
    });
  });
}
