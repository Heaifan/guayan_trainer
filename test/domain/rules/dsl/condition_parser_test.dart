import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/dsl/dsl_lexer.dart';
import 'package:guayan_trainer/domain/rules/dsl/condition_parser.dart';

void main() {
  group('ConditionParser', () {
    test('parses simple predicate', () {
      final tokens = DslLexer('若 A 六亲为父母').lex().value!;
      final parser = ConditionParser(tokens);
      final result = parser.parse();

      expect(result.isSuccess, isTrue);
      expect(result.value, isA<PredicateExpr>());
      final p = result.value as PredicateExpr;
      expect(p.operatorId, 'relative');
      expect(p.operands[0], isA<BindingRefOperand>());
      expect((p.operands[0] as BindingRefOperand).bindingName, 'A');
      expect(p.operands[1], isA<LiteralOperand>());
      expect((p.operands[1] as LiteralOperand).value.value, 'relative.parent');
    });

    test('parses nested structure with indent and logic ops', () {
      final source = '''若 A 六亲为父母
且 B 六神为青龙
或 非 C 为空''';
      final tokens = DslLexer(source).lex().value!;
      final parser = ConditionParser(tokens);
      final result = parser.parse();

      expect(result.isSuccess, isTrue);
      expect(result.value, isA<AnyExpr>());
      final any = result.value as AnyExpr;
      expect(any.nodes.length, 2);
      expect(any.nodes[0], isA<AllExpr>());
      final all = any.nodes[0] as AllExpr;
      expect(all.nodes.length, 2);
      expect(all.nodes[0], isA<PredicateExpr>());
      expect(all.nodes[1], isA<PredicateExpr>());
      expect(any.nodes[1], isA<NotExpr>());
    });

    test('parses multiple operands like chu_mu', () {
      final tokens = DslLexer('若 A 因 D 冲 T 而出墓').lex().value!;
      final parser = ConditionParser(tokens);
      final result = parser.parse();

      expect(result.isSuccess, isTrue);
      expect(result.value, isA<PredicateExpr>());
      final p = result.value as PredicateExpr;
      expect(p.operatorId, 'chu_mu');
      expect(p.operands.length, 3);
      expect((p.operands[0] as BindingRefOperand).bindingName, 'A');
      expect((p.operands[1] as BindingRefOperand).bindingName, 'D');
      expect((p.operands[2] as BindingRefOperand).bindingName, 'T');
    });
  });
}
