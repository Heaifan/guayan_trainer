import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/dsl/dsl_parser.dart';
import 'package:guayan_trainer/domain/dsl/dsl_formatter.dart';
import 'package:guayan_trainer/domain/dsl/dsl_diagnostics.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';

void main() {
  group('C1 FAST-TRACK Smoke Tests', () {
    test('Case 1: 基础规则', () {
      final source = '''
取 A = @line/2
取 M = @calendar/month

若 A 六亲为父母
    且 M 生 A
则
    得 A state.parent_supported
'''.trim();

      final parsed = GuayanDslParser.parse(source);
      
      expect(parsed.bindings.length, 2);
      expect(parsed.bindings[0].name, 'A');
      expect(parsed.actions.length, 1);
      
      final formatted = GuayanDslFormatter.format(
        bindings: parsed.bindings,
        condition: parsed.condition,
        actions: parsed.actions,
      );
      
      expect(formatted, source);
    });

    test('Case 2: 复杂条件', () {
      final source = '''
若 A 六亲为父母
    且
        A 月破
        或 A 日破
    且 非 A 旬空
则
    取象 A exam:document
'''.trim();

      final parsed = GuayanDslParser.parse(source);
      
      final root = parsed.condition as AllExpr;
      expect(root.nodes.length, 3);
      
      // Node 0: relative
      expect((root.nodes[0] as PredicateExpr).operatorId, 'relative');
      
      // Node 1: ANY
      final anyNode = root.nodes[1] as AnyExpr;
      expect((anyNode.nodes[0] as PredicateExpr).operatorId, 'yue_po');
      expect((anyNode.nodes[1] as PredicateExpr).operatorId, 'ri_po');
      
      // Node 2: NOT -> xun_kong
      final notNode = root.nodes[2] as NotExpr;
      expect((notNode.node as PredicateExpr).operatorId, 'xun_kong');
      
      final formatted = GuayanDslFormatter.format(
        bindings: parsed.bindings,
        condition: parsed.condition,
        actions: parsed.actions,
      );
      
      expect(formatted, source);
    });

    test('Case 3: 错误输入', () {
      final source = '''
若 A 六亲为父母
    且且 A 月破
'''.trim();

      try {
        GuayanDslParser.parse(source);
        fail('Should throw DslException');
      } on DslException catch (e) {
        expect(e.diagnostic.line, 2);
        expect(e.diagnostic.message, contains('无法识别条件'));
      }
    });
  });
}
