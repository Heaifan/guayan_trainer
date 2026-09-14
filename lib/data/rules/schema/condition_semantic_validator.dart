library;

import '../../../domain/rules/vocabulary/condition_registry.dart';
import '../../../domain/rules/vocabulary/condition_definition.dart';
import '../../../domain/rules/vocabulary/nayin_id.dart';
import '../../../domain/rules/vocabulary/tag_category_ids.dart';

class ConditionSemanticValidator {
  static void validatePredicate(Map<dynamic, dynamic> expr, Set<String> bindingNames) {
    final operatorId = expr['operatorId'];
    if (operatorId == null) throw FormatException('operatorId missing');
    final def = CanonicalConditionRegistry.getDefinition(operatorId as String);
    if (def == null) throw FormatException('unknown canonical operator: ');
    
    final operands = expr['operands'] as List?;
    if (operands == null) throw FormatException('operands missing');
    if (operands.length != def.operandCount) {
      throw FormatException('operand count mismatch: expected ${def.operandCount}, got ${operands.length}');
    }

    for (int i = 0; i < operands.length; i++) {
      final op = operands[i];
      if (op is! Map) throw FormatException('Operand must be object');
      final expectedKind = def.operandKinds[i];
      _validateOperandKind(op, expectedKind, bindingNames);
    }
  }

  static void _validateOperandKind(Map op, OperandKind expected, Set<String> bindingNames) {
    final opType = op['type'];
    if (expected == OperandKind.bindingRef) {
      if (opType != 'bindingRef') throw FormatException('expected bindingRef, got ');
      final name = op['name'];
      if (name == null || name is! String) throw FormatException('binding operand malformed');
      if (!bindingNames.contains(name)) throw FormatException('unbound BindingRef: ');
    } else {
      if (opType != 'literal') throw FormatException('expected literal, got ');
      final val = op['value'];
      if (expected == OperandKind.nayinIdLiteral) {
        if (val is! String || !NaYinId.isValid(val)) throw FormatException('invalid NaYinId: ');
      } else if (expected == OperandKind.tagCategoryLiteral) {
        if (val != CanonicalTagCategoryId.shensha) throw FormatException('invalid Tag category: ');
      } else if (expected == OperandKind.shenShaIdLiteral) {
        if (val is! String) throw FormatException('invalid ShenSha stable-id format');
        if (!RegExp(r'^shensha\.(sys|custom)\.[a-zA-Z0-9_]+$').hasMatch(val)) {
          throw FormatException('invalid ShenSha stable-id format: ');
        }
      }
    }
  }
}
