library;

class DslDiagnostic {
  const DslDiagnostic({
    required this.line,
    required this.column,
    required this.message,
  });

  final int line;
  final int column;
  final String message;

  @override
  String toString() => '第 $line 行，第 $column 列：\n$message';
}

class DslException implements Exception {
  const DslException(this.diagnostic);
  final DslDiagnostic diagnostic;

  @override
  String toString() => diagnostic.toString();
}
