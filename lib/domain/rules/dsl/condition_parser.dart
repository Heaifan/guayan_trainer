library;

import '../ast/rule_expr.dart';
import 'dsl_token.dart';
import 'dsl_diagnostic.dart';
import 'dsl_parse_result.dart';
import 'predicate_parser.dart';

class ConditionParser {
  ConditionParser(this.tokens);
  final List<Token> tokens;
  int _pos = 0;
  final List<DslDiagnostic> _diagnostics = [];

  ParseResult<RuleExpr> parse() {
    if (_peek().type != TokenType.keywordRuo) {
      return _fail('Expected "若"', _peek());
    }
    _advance();
    final expr = _parseBlock(0);
    if (expr == null) return ParseResult(diagnostics: _diagnostics);
    return ParseResult(value: expr, diagnostics: _diagnostics);
  }

  RuleExpr? _parseBlock(int indentLevel) {
    List<RuleExpr> allExprs = [];
    List<RuleExpr> anyExprs = [];

    while (_pos < tokens.length) {
      if (_peek().type == TokenType.dedent || _peek().type == TokenType.eof)
        break;

      String logicOp = '且';
      if (_peek().type == TokenType.keywordQie) {
        logicOp = '且';
        _advance();
      } else if (_peek().type == TokenType.keywordHuo) {
        logicOp = '或';
        _advance();
      }

      bool isNot = _match(TokenType.keywordFei);

      RuleExpr? currentExpr;
      if (_peek().type == TokenType.ident) {
        currentExpr = _parsePredicate();
      } else if (_peek().type == TokenType.indent) {
        _advance();
        currentExpr = _parseBlock(indentLevel + 4);
        _match(TokenType.dedent);
      } else {
        _fail('Expected predicate or indent block', _peek());
        return null;
      }

      if (currentExpr != null) {
        if (isNot) currentExpr = NotExpr(currentExpr);
        if (logicOp == '或') {
          anyExprs.add(currentExpr);
        } else {
          allExprs.add(currentExpr);
        }
      }
      if (_peek().type == TokenType.eof) break;
    }

    if (allExprs.length == 1 && anyExprs.isEmpty) return allExprs.first;
    if (anyExprs.isNotEmpty) {
      if (allExprs.isNotEmpty) anyExprs.insert(0, AllExpr(allExprs));
      return AnyExpr(anyExprs);
    }
    return AllExpr(allExprs);
  }

  RuleExpr? _parsePredicate() {
    final bindingToken = _consume(TokenType.ident, 'Expected binding');
    if (bindingToken == null) return null;

    List<Token> body = [];
    while (_pos < tokens.length &&
        _peek().type != TokenType.keywordQie &&
        _peek().type != TokenType.keywordHuo &&
        _peek().type != TokenType.keywordFei &&
        _peek().type != TokenType.indent &&
        _peek().type != TokenType.dedent &&
        _peek().type != TokenType.eof) {
      body.add(_advance());
    }

    return PredicateParser.parse(bindingToken, body, _failCb);
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
    _fail(msg, _peek());
    return null;
  }

  ParseResult<RuleExpr> _fail(String msg, Token t) {
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

  void _failCb(String msg, Token t) => _fail(msg, t);
}
