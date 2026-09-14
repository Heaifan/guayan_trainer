import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('SchemaValidator Action Tests', () {
    test('Record scalar contract', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}};
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': 1, 'b': 'str', 'c': true, 'd': 1.5, 'e': null}}]}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': {'nested': 1}}}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r', 'content': {'a': [1, 2]}}]}), throwsFormatException);
    });

    test('actions checks', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'condition': {'type': 'PREDICATE', 'operatorId': 'empty', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}};
      expect(() => RuleSchemaValidator.validate({...base, 'actions': []}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'unknown'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'derive', 'target': 'B'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'tag', 'categoryId': '', 'tagId': 'x'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'tag', 'categoryId': 'c', 'tagId': 't', 'subject': 'B'}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'structure', 'structureId': '', 'members': ['A']}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'structure', 'structureId': 's', 'members': ['B']}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': '', 'content': {}}]}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'actions': [{'type': 'record', 'recordType': 'r'}]}), throwsFormatException);
    });
  });
}
