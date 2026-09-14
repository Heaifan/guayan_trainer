import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/data/rules/schema/rule_schema_validator.dart';

void main() {
  group('Condition Semantic Validator Tests', () {
    test('operator semantics validation', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};
      
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'unknown_op', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'xun_kong', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 1}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'xun_kong', 'operands': [{'type': 'bindingRef'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'xun_kong', 'operands': [{'type': 'literal', 'value': 'A'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'xun_kong', 'operands': [{'type': 'bindingRef', 'name': 'A'}]}}), returnsNormally);

      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'nayin_is', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'nayin.invalid'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'nayin_is', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'nayin.tian_he_shui'}]}}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'nayin_is', 'operands': [{'type': 'literal', 'value': 'nayin.tian_he_shui'}, {'type': 'bindingRef', 'name': 'A'}]}}), throwsFormatException);
    });

    test('ShenSha format validation', () {
      final base = {'schemaVersion': 1, 'ruleId': 'r1', 'version': '1.0.0', 'bindings': [{'name': 'A', 'selector': {'type': 'direct', 'target': 't'}}], 'actions': [{'type': 'derive', 'target': 'A'}]};
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'has_tag', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'invalid_cat'}, {'type': 'literal', 'value': 'shensha.sys.yi_ma'}]}}), throwsFormatException);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'has_tag', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'shensha'}, {'type': 'literal', 'value': 'shensha.sys.yi_ma'}]}}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'has_tag', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'shensha'}, {'type': 'literal', 'value': 'shensha.custom.my_rule'}]}}), returnsNormally);
      expect(() => RuleSchemaValidator.validate({...base, 'condition': {'type': 'PREDICATE', 'operatorId': 'has_tag', 'operands': [{'type': 'bindingRef', 'name': 'A'}, {'type': 'literal', 'value': 'shensha'}, {'type': 'literal', 'value': 'invalid'}]}}), throwsFormatException);
    });
  });
}
