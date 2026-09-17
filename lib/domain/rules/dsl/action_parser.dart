library;

import '../ast/rule_action.dart';
import 'dsl_token.dart';
import 'dsl_diagnostic.dart';
import 'dsl_parse_result.dart';
import 'derive_action_parser.dart';
import 'tag_action_parser.dart';
import 'structure_action_parser.dart';
import 'record_action_parser.dart';

class ActionParser {
  ActionParser(this.tokens);
  final List<Token> tokens;
  int pos = 0;
  final List<DslDiagnostic> diagnostics = [];

  ParseResult<List<RuleAction>> parse() {
    List<RuleAction> actions = [];
    if (peek().type != TokenType.keywordZe) {
      fail('Expected "则"', peek());
      return ParseResult(diagnostics: diagnostics);
    }
    advance();

    bool hasIndent = match(TokenType.indent);

    while (pos < tokens.length) {
      if (peek().type == TokenType.eof) break;
      if (hasIndent && peek().type == TokenType.dedent) {
        advance();
        break;
      }

      final type = peek().type;
      ParseResult<RuleAction>? result;
      if (type == TokenType.keywordDe) {
        result = DeriveActionParser(this).parse();
      } else if (type == TokenType.keywordQuXiang) {
        result = TagActionParser(this).parse();
      } else if (type == TokenType.keywordChengJu) {
        result = StructureActionParser(this).parse();
      } else if (type == TokenType.keywordJi) {
        result = RecordActionParser(this).parse();
      } else {
        fail('Expected action keyword (得, 取象, 成局, 记)', peek());
        break;
      }

      if (result.value != null) actions.add(result.value!);
      diagnostics.addAll(result.diagnostics);
      if (result.value == null) break;
    }

    return ParseResult(value: actions, diagnostics: diagnostics);
  }

  Token peek() => pos < tokens.length ? tokens[pos] : tokens.last;
  Token advance() => pos < tokens.length ? tokens[pos++] : tokens.last;
  bool match(TokenType type) {
    if (peek().type == type) {
      advance();
      return true;
    }
    return false;
  }

  Token? consume(TokenType type, String msg) {
    if (peek().type == type) return advance();
    fail(msg, peek());
    return null;
  }

  void fail(String msg, Token t) {
    diagnostics.add(
      DslDiagnostic(
        code: 'parse_error',
        message: msg,
        line: t.line,
        column: t.column,
        length: t.lexeme.length,
      ),
    );
  }
}
