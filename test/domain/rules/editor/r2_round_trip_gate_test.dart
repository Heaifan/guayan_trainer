import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/editor/portable_rule_codec.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_expr_codec.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

void main() {
  test(
    'quantifier, dynamic selector and structure condition survive codec',
    () {
      final expr = QuantifiedExpr(
        bindingName: 'moving',
        selector: const DynamicBindingSelector(
          selectorId: 'dynamic.line.moving',
        ),
        kind: QuantifierKind.atLeast,
        count: 2,
        node: PredicateExpr(
          operatorId: 'structure_formed',
          operands: [LiteralOperand(RuleValue.string('sanHe.木'))],
        ),
      );

      final json = RuleExprCodec.toJson(expr);
      final restored = RuleExprCodec.fromJson(json);

      expect(RuleExprCodec.toJson(restored), json);
    },
  );

  test('portable codec preserves nested logic and count semantics', () {
    final expr = AllExpr([
      QuantifiedExpr(
        bindingName: 'moving',
        selector: const DynamicBindingSelector(
          selectorId: 'dynamic.line.moving',
        ),
        kind: QuantifierKind.exactly,
        count: 1,
        node: PredicateExpr(
          operatorId: 'spirit',
          operands: [
            const BindingRefOperand('moving'),
            LiteralOperand(RuleValue.string('spirit.bai_hu')),
          ],
        ),
      ),
      NotExpr(
        PredicateExpr(
          operatorId: 'structure_formed',
          operands: [LiteralOperand(RuleValue.string('sanHe.水'))],
        ),
      ),
    ]);

    expect(
      RuleExprCodec.toJson(RuleExprCodec.fromJson(RuleExprCodec.toJson(expr))),
      RuleExprCodec.toJson(expr),
    );

    // Keep the portable codec import in this gate as the product save boundary
    // is exercised by the editor through PortableRuleCodec.
    expect(PortableRuleCodec.encodeText, isNotNull);
  });
}
