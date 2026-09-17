library;

import '../ast/rule_binding.dart';
import '../ast/binding_selector.dart';
import 'dsl_token.dart';
import 'dsl_diagnostic.dart';
import 'dsl_parse_result.dart';

class BindingParser {
  BindingParser(this.tokens);

  final List<Token> tokens;
  int _pos = 0;
  final List<DslDiagnostic> _diagnostics = [];

  ParseResult<RuleBinding> parse() {
    if (_peek().type != TokenType.keywordQu) {
      return _fail('Expected "取"', _peek());
    }
    _advance();

    final nameToken = _consume(
      TokenType.ident,
      'Expected binding name (e.g. A)',
    );
    if (nameToken == null) return _failResult();

    if (_consume(TokenType.operatorAssign, 'Expected "="') == null) {
      return _failResult();
    }

    final selector = _parseSelector();
    if (selector == null) return _failResult();

    return ParseResult(
      value: RuleBinding(name: nameToken.lexeme, selector: selector),
      diagnostics: _diagnostics,
    );
  }

  BindingSelector? _parseSelector() {
    if (_match(TokenType.operatorAt)) {
      final textToken = _consume(
        TokenType.ident,
        'Expected target name after @',
      );
      final slash = _match(TokenType.operatorSlash);
      String text = textToken?.lexeme ?? '';
      if (slash) {
        final numToken = _match(TokenType.literalNumber)
            ? tokens[_pos - 1]
            : _consume(TokenType.ident, 'Expected ident or number after /');
        if (numToken != null) text += '/${numToken.lexeme}';
      }
      return DirectSelector(text);
    } else if (_peek().type == TokenType.ident) {
      final baseToken = _advance();
      if (_match(TokenType.operatorDot)) {
        final pathToken = _consume(TokenType.ident, 'Expected relative path');
        if (pathToken != null) {
          return RelativeSelector(
            baseBinding: baseToken.lexeme,
            path: pathToken.lexeme,
          );
        }
      } else {
        return DirectSelector(baseToken.lexeme);
      }
    }
    _diagnostics.add(
      DslDiagnostic(
        code: 'invalid_selector',
        message: 'Invalid binding selector',
        line: _peek().line,
        column: _peek().column,
        length: _peek().lexeme.length,
      ),
    );
    return null;
  }

  Token _peek() => _pos < tokens.length ? tokens[_pos] : tokens.last;
  Token _advance() => _pos < tokens.length ? tokens[_pos++] : tokens.last;
  bool _match(TokenType type) {
    if (_peek().type == type) {
      _advance();
      return true;
    }
    return false;
  }

  Token? _consume(TokenType type, String msg) {
    if (_peek().type == type) return _advance();
    _diagnostics.add(
      DslDiagnostic(
        code: 'unexpected_token',
        message: msg,
        line: _peek().line,
        column: _peek().column,
        length: _peek().lexeme.length,
      ),
    );
    return null;
  }

  ParseResult<RuleBinding> _fail(String msg, Token t) {
    _diagnostics.add(
      DslDiagnostic(
        code: 'parse_error',
        message: msg,
        line: t.line,
        column: t.column,
        length: t.lexeme.length,
      ),
    );
    return ParseResult(diagnostics: _diagnostics);
  }

  ParseResult<RuleBinding> _failResult() =>
      ParseResult(diagnostics: _diagnostics);
}
