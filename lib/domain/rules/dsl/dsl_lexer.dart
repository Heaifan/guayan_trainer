library;

import 'dsl_diagnostic.dart';
import 'dsl_token.dart';
import 'dsl_parse_result.dart';

class DslLexer {
  DslLexer(this.s);
  final String s;
  int p = 0, l = 1, c = 1;
  final List<Token> t = [];
  final List<DslDiagnostic> d = [];
  final List<int> ind = [0];
  bool atLineStart = true;
  static const k = {
    '取': TokenType.keywordQu,
    '若': TokenType.keywordRuo,
    '且': TokenType.keywordQie,
    '或': TokenType.keywordHuo,
    '非': TokenType.keywordFei,
    '则': TokenType.keywordZe,
    '得': TokenType.keywordDe,
    '取象': TokenType.keywordQuXiang,
    '成局': TokenType.keywordChengJu,
    '记': TokenType.keywordJi,
  };

  ParseResult<List<Token>> lex() {
    while (!end()) {
      if (atLineStart) handleIndent();
      if (!end()) lexToken();
    }
    while (ind.last > 0) {
      ind.removeLast();
      add(TokenType.dedent, '');
    }
    add(TokenType.eof, '');
    return ParseResult(value: t, diagnostics: d);
  }

  void handleIndent() {
    int sp = 0;
    while (!end() && (s[p] == ' ' || s[p] == '\t')) {
      if (s[p] == '\t') {
        err('Tabs are not allowed', 1);
      } else {
        sp++;
      }
      adv();
    }
    if (end() || s[p] == '\n' || s[p] == '\r') return;
    if (sp % 4 != 0) err('Indentation must be multiple of 4', sp);
    if (sp > ind.last) {
      ind.add(sp);
      add(TokenType.indent, '');
    } else {
      while (ind.last > sp) {
        ind.removeLast();
        add(TokenType.dedent, '');
      }
    }
    atLineStart = false;
  }

  void lexToken() {
    final ch = adv();
    if (ch == '\r' || ch == '\n') {
      if (ch == '\r' && !end() && s[p] == '\n') adv();
      l++;
      c = 1;
      atLineStart = true;
    } else if (ch == ' ') {
    } else if (ch == '=') {
      add(TokenType.operatorAssign, ch);
    } else if (ch == '.') {
      add(TokenType.operatorDot, ch);
    } else if (ch == '@') {
      add(TokenType.operatorAt, ch);
    } else if (ch == '/') {
      add(TokenType.operatorSlash, ch);
    } else if (ch == ':') {
      add(TokenType.operatorColon, ch);
    } else if (ch == ',') {
      add(TokenType.operatorComma, ch);
    } else if (ch == '{') {
      int st = p - 1;
      int braceCount = 1;
      while (!end() && braceCount > 0) {
        if (s[p] == '{') {
          braceCount++;
        } else if (s[p] == '}') {
          braceCount--;
        }
        adv();
      }
      add(TokenType.literalString, s.substring(st, p));
    } else if (RegExp(r'[a-zA-Z_]').hasMatch(ch)) {
      lexRgx(r'[a-zA-Z0-9_]', TokenType.ident);
    } else if (RegExp(r'[0-9]').hasMatch(ch)) {
      lexRgx(r'[0-9]', TokenType.literalNumber);
    } else if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(ch)) {
      int st = p - 1;
      while (!end() && RegExp(r'[\u4e00-\u9fa5]').hasMatch(s[p])) {
        adv();
      }
      final txt = s.substring(st, p);
      add(k[txt] ?? TokenType.textSegment, txt);
    } else {
      err('Unexpected character', 1);
    }
  }

  void lexRgx(String pt, TokenType type) {
    int st = p - 1;
    while (!end() && RegExp(pt).hasMatch(s[p])) {
      adv();
    }
    add(type, s.substring(st, p));
  }

  bool end() => p >= s.length;
  String adv() {
    c++;
    return s[p++];
  }

  void err(String msg, int len) => d.add(
    DslDiagnostic(
      code: 'err',
      message: msg,
      line: l,
      column: c - 1,
      length: len,
    ),
  );
  void add(TokenType type, String lx) => t.add(
    Token(
      type: type,
      lexeme: lx,
      line: l,
      column: c - lx.length,
      offset: p - lx.length,
    ),
  );
}
