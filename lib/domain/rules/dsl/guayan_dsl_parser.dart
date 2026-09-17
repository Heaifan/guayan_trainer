library;

import '../ast/rule_binding.dart';
import 'dsl_token.dart';
import 'dsl_lexer.dart';
import 'dsl_parse_result.dart';
import 'dsl_diagnostic.dart';
import 'binding_parser.dart';
import 'condition_parser.dart';
import 'action_parser.dart';
import 'guayan_rule_body.dart';

class GuayanDslParser {
  const GuayanDslParser();

  ParseResult<GuayanRuleBody> parse(String source) {
    final lexerResult = DslLexer(source).lex();
    if (lexerResult.hasErrors) {
      return ParseResult(diagnostics: lexerResult.diagnostics);
    }

    final tokens = lexerResult.value ?? [];
    int pos = 0;

    List<RuleBinding> bindings = [];
    while (pos < tokens.length && tokens[pos].type == TokenType.keywordQu) {
      // Find the end of this binding statement
      int endPos = pos + 1;
      while (endPos < tokens.length &&
          tokens[endPos].type != TokenType.keywordQu &&
          tokens[endPos].type != TokenType.keywordRuo) {
        endPos++;
      }
      final bindingResult = BindingParser(tokens.sublist(pos, endPos)).parse();
      if (bindingResult.hasErrors)
        return ParseResult(diagnostics: bindingResult.diagnostics);
      if (bindingResult.value != null) bindings.add(bindingResult.value!);
      pos = endPos;
    }

    int ruoPos = pos;
    while (pos < tokens.length && tokens[pos].type != TokenType.keywordZe) {
      pos++;
    }

    if (ruoPos >= tokens.length ||
        tokens[ruoPos].type != TokenType.keywordRuo) {
      return ParseResult(
        diagnostics: [
          DslDiagnostic(
            code: 'err',
            message: 'Expected "若"',
            line: 1,
            column: 1,
            length: 1,
          ),
        ],
      );
    }

    final conditionResult = ConditionParser(
      tokens.sublist(ruoPos, pos),
    ).parse();
    if (conditionResult.hasErrors)
      return ParseResult(diagnostics: conditionResult.diagnostics);
    final condition = conditionResult.value;
    if (condition == null)
      return ParseResult(diagnostics: conditionResult.diagnostics);

    final actionResult = ActionParser(tokens.sublist(pos)).parse();
    if (actionResult.hasErrors)
      return ParseResult(diagnostics: actionResult.diagnostics);
    final actions = actionResult.value ?? [];

    return ParseResult(
      value: GuayanRuleBody(
        bindings: bindings,
        condition: condition,
        actions: actions,
      ),
      diagnostics: [],
    );
  }
}
