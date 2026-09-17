import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/dsl/dsl_lexer.dart';
import 'package:guayan_trainer/domain/rules/dsl/binding_parser.dart';

void main() {
  group('BindingParser', () {
    test('parses DirectSelector with @line/2', () {
      final tokens = DslLexer('取 A = @line/2').lex().value!;
      final parser = BindingParser(tokens);
      final result = parser.parse();

      expect(result.isSuccess, isTrue);
      expect(result.value!.name, 'A');
      expect(result.value!.selector, isA<DirectSelector>());
      expect((result.value!.selector as DirectSelector).target, 'line/2');
    });

    test('parses RelativeSelector A.changedLine', () {
      final tokens = DslLexer('取 B = A.changedLine').lex().value!;
      final parser = BindingParser(tokens);
      final result = parser.parse();

      expect(result.isSuccess, isTrue);
      expect(result.value!.name, 'B');
      expect(result.value!.selector, isA<RelativeSelector>());
      final rel = result.value!.selector as RelativeSelector;
      expect(rel.baseBinding, 'A');
      expect(rel.path, 'changedLine');
    });

    test('fails closed on unknown tokens', () {
      final tokens = DslLexer('取 A ++').lex().value!;
      final parser = BindingParser(tokens);
      final result = parser.parse();

      expect(result.hasErrors, isTrue);
    });
  });
}
