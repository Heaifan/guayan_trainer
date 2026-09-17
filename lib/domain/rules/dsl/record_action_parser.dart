library;

import 'dart:convert';
import '../ast/rule_action.dart';
import '../facts/rule_value.dart';
import 'dsl_token.dart';
import 'dsl_parse_result.dart';
import 'action_parser.dart';

class RecordActionParser {
  RecordActionParser(this.parser);
  final ActionParser parser;

  ParseResult<RuleAction> parse() {
    parser.consume(TokenType.keywordJi, 'Expected "记"');

    final cat = parser.consume(TokenType.ident, 'Expected record category');
    if (cat == null) return ParseResult(diagnostics: []);

    if (parser.consume(TokenType.operatorDot, 'Expected "."') == null) {
      return ParseResult(diagnostics: []);
    }

    final key = parser.consume(TokenType.ident, 'Expected record key');
    if (key == null) return ParseResult(diagnostics: []);

    final jsonToken = parser.consume(
      TokenType.literalString,
      'Expected JSON content',
    );
    if (jsonToken == null) return ParseResult(diagnostics: []);

    Map<String, RuleValue> content = {};
    try {
      final decoded = jsonDecode(jsonToken.lexeme);
      if (decoded is Map<String, dynamic>) {
        content = decoded.map((k, v) => MapEntry(k, _toRuleValue(v)));
      }
    } catch (e) {
      parser.fail('Invalid JSON: $e', jsonToken);
      return ParseResult(diagnostics: []);
    }

    return ParseResult(
      value: RecordAction(
        recordType: '${cat.lexeme}.${key.lexeme}',
        content: content,
      ),
      diagnostics: [],
    );
  }

  RuleValue _toRuleValue(dynamic value) {
    return RuleValue.fromJson(value);
  }
}
