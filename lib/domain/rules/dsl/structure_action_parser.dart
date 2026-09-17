library;

import '../ast/rule_action.dart';
import 'dsl_token.dart';
import 'dsl_parse_result.dart';
import 'action_parser.dart';

class StructureActionParser {
  StructureActionParser(this.parser);
  final ActionParser parser;

  ParseResult<RuleAction> parse() {
    parser.consume(TokenType.keywordChengJu, 'Expected "成局"');

    final cat = parser.consume(TokenType.ident, 'Expected structure category');
    if (cat == null) return ParseResult(diagnostics: []);

    if (parser.consume(TokenType.operatorDot, 'Expected "."') == null) {
      return ParseResult(diagnostics: []);
    }

    final key = parser.consume(TokenType.ident, 'Expected structure key');
    if (key == null) return ParseResult(diagnostics: []);

    if (parser.consume(TokenType.operatorColon, 'Expected ":"') == null) {
      return ParseResult(diagnostics: []);
    }

    List<String> bindings = [];
    while (parser.pos < parser.tokens.length) {
      final bind = parser.consume(TokenType.ident, 'Expected binding');
      if (bind == null) return ParseResult(diagnostics: []);
      bindings.add(bind.lexeme);

      if (parser.peek().type == TokenType.operatorComma) {
        parser.advance();
      } else {
        break;
      }
    }

    return ParseResult(
      value: StructureAction(
        structureId: '${cat.lexeme}.${key.lexeme}',
        memberBindings: bindings,
      ),
      diagnostics: [],
    );
  }
}
