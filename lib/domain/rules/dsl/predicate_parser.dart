library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/rule_value.dart';
import 'dsl_token.dart';
import 'dsl_vocabulary.dart';
import '../vocabulary/condition_id.dart';

class PredicateParser {
  static PredicateExpr? parse(
    Token bindingToken,
    List<Token> body,
    void Function(String msg, Token t) fail,
  ) {
    String bodyStr = body.map((t) => t.lexeme).join('');
    String? matchedOp;
    String? matchedOpText;

    for (final op in DslVocabulary.operatorMap.keys) {
      if (bodyStr.startsWith(op)) {
        matchedOp = DslVocabulary.operatorMap[op];
        matchedOpText = op;
        break;
      }
    }

    if (matchedOp == null) {
      if (bodyStr.startsWith('生') &&
          body.length == 2 &&
          body[1].type == TokenType.ident) {
        return PredicateExpr(
          operatorId: ConditionId.generate,
          operands: [
            BindingRefOperand(bindingToken.lexeme),
            BindingRefOperand(body[1].lexeme),
          ],
        );
      } else if (bodyStr.startsWith('入') &&
          bodyStr.endsWith('墓') &&
          body.length >= 3) {
        return PredicateExpr(
          operatorId: ConditionId.ruMu,
          operands: [
            BindingRefOperand(bindingToken.lexeme),
            BindingRefOperand(body[1].lexeme),
          ],
        );
      } else if (bodyStr.startsWith('冲') &&
          bodyStr.endsWith('墓') &&
          body.length >= 3) {
        return PredicateExpr(
          operatorId: ConditionId.chongMu,
          operands: [
            BindingRefOperand(bindingToken.lexeme),
            BindingRefOperand(body[1].lexeme),
          ],
        );
      } else if (bodyStr.startsWith('因') &&
          bodyStr.contains('冲') &&
          bodyStr.endsWith('而出墓') &&
          body.length >= 4) {
        return PredicateExpr(
          operatorId: ConditionId.chuMu,
          operands: [
            BindingRefOperand(bindingToken.lexeme),
            BindingRefOperand(body[1].lexeme),
            BindingRefOperand(body[3].lexeme),
          ],
        );
      }
      fail('Unknown operator in "$bodyStr"', bindingToken);
      return null;
    }

    List<RuleOperand> operands = [BindingRefOperand(bindingToken.lexeme)];
    String remainder = bodyStr.substring(matchedOpText!.length).trim();
    if (remainder.isNotEmpty) {
      if (RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(remainder)) {
        operands.add(BindingRefOperand(remainder));
      } else if (remainder.startsWith('shensha:')) {
        operands.add(LiteralOperand(RuleValue.string(remainder)));
      } else {
        operands.add(
          LiteralOperand(RuleValue.string(DslVocabulary.mapValue(remainder))),
        );
      }
    }

    return PredicateExpr(operatorId: matchedOp, operands: operands);
  }
}
