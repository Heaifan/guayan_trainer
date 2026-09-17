library;

enum TokenType {
  keywordQu, // 取
  keywordRuo, // 若
  keywordQie, // 且
  keywordHuo, // 或
  keywordFei, // 非
  keywordZe, // 则
  keywordDe, // 得
  keywordQuXiang, // 取象
  keywordChengJu, // 成局
  keywordJi, // 记

  ident,
  literalString,
  literalNumber,

  operatorAssign, // =
  operatorDot, // .
  operatorAt, // @
  operatorSlash, // /
  operatorColon, // :
  operatorComma, // ,

  textSegment, // Chinese texts serving as operators or identifiers

  indent,
  dedent,
  eof,
}

class Token {
  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
    required this.offset,
  });

  final TokenType type;
  final String lexeme;
  final int line;
  final int column;
  final int offset;

  @override
  String toString() => '$type("$lexeme" at $line:$column)';
}
