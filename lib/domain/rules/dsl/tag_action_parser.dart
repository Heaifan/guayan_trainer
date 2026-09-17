library;

import '../ast/rule_action.dart';
import 'dsl_token.dart';
import 'dsl_parse_result.dart';
import 'action_parser.dart';

class TagActionParser {
  TagActionParser(this.parser);
  final ActionParser parser;

  ParseResult<RuleAction> parse() {
    parser.consume(TokenType.keywordQuXiang, 'Expected "取象"');

    final first = parser.consume(
      TokenType.ident,
      'Expected binding or category ID',
    );
    if (first == null) return ParseResult(diagnostics: []);

    if (parser.peek().type == TokenType.operatorColon) {
      parser.advance();
      final tag = parser.consume(TokenType.ident, 'Expected tag ID');
      if (tag == null) return ParseResult(diagnostics: []);
      return ParseResult(
        value: TagAction(categoryId: first.lexeme, tagId: tag.lexeme),
        diagnostics: [],
      );
    } else {
      final subjectBinding = first.lexeme;
      final cat = parser.consume(TokenType.ident, 'Expected category ID');
      if (cat == null) return ParseResult(diagnostics: []);

      if (parser.consume(TokenType.operatorColon, 'Expected ":"') == null) {
        return ParseResult(diagnostics: []);
      }

      final tag = parser.consume(TokenType.ident, 'Expected tag ID');
      if (tag == null) return ParseResult(diagnostics: []);

      return ParseResult(
        value: TagAction(
          categoryId: cat.lexeme,
          tagId: tag.lexeme,
          subjectBinding: subjectBinding,
        ),
        diagnostics: [],
      );
    }
  }
}
