import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/dsl/dsl_lexer.dart';
import 'package:guayan_trainer/domain/rules/dsl/dsl_token.dart';

void main() {
  group('DslLexer', () {
    test('lexes keywords and identifiers correctly', () {
      final lexer = DslLexer('取 A = @line/2');
      final result = lexer.lex();

      expect(result.isSuccess, isTrue);
      expect(result.value!.map((t) => t.type), [
        TokenType.keywordQu,
        TokenType.ident,
        TokenType.operatorAssign,
        TokenType.operatorAt,
        TokenType.ident,
        TokenType.operatorSlash,
        TokenType.literalNumber,
        TokenType.eof,
      ]);
    });

    test('handles indentation as multiples of 4 spaces', () {
      final source = '若 A 为空\n    且 B 六亲为父母';
      final lexer = DslLexer(source);
      final result = lexer.lex();

      expect(result.isSuccess, isTrue);
      final types = result.value!.map((t) => t.type).toList();

      expect(types.contains(TokenType.indent), isTrue);
      expect(types.contains(TokenType.dedent), isTrue);
    });

    test('fails on bad indentation', () {
      final lexer = DslLexer('若 A 为空\n  且 B');
      final result = lexer.lex();

      expect(result.hasErrors, isTrue);
      expect(result.diagnostics.first.code, 'err'); // bad_indent / err
    });
  });
}
