library;

import '../ast/rule_action.dart';
import 'dsl_token.dart';
import 'dsl_parse_result.dart';
import 'action_parser.dart';

class DeriveActionParser {
  DeriveActionParser(this.parser);
  final ActionParser parser;

  ParseResult<RuleAction> parse() {
    parser.consume(TokenType.keywordDe, 'Expected "得"');

    final target = parser.consume(TokenType.ident, 'Expected target binding');
    if (target == null) return ParseResult(diagnostics: []);

    final cat = parser.consume(TokenType.ident, 'Expected fact category');
    if (cat == null) return ParseResult(diagnostics: []);

    if (parser.consume(TokenType.operatorDot, 'Expected "."') == null) {
      return ParseResult(diagnostics: []);
    }

    final key = parser.consume(TokenType.ident, 'Expected fact key');
    if (key == null) return ParseResult(diagnostics: []);

    return ParseResult(
      value: DeriveAction(
        targetBinding: target.lexeme,
        factKey: '${cat.lexeme}.${key.lexeme}',
      ),
      diagnostics: [],
    );
  }
}
