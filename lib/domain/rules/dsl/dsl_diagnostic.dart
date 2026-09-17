library;

enum DiagnosticSeverity { error, warning, info }

class DslDiagnostic {
  const DslDiagnostic({
    required this.code,
    required this.message,
    required this.line,
    required this.column,
    required this.length,
    this.expected,
    this.severity = DiagnosticSeverity.error,
  });

  final String code;
  final String message;
  final int line;
  final int column;
  final int length;
  final String? expected;
  final DiagnosticSeverity severity;

  @override
  String toString() {
    return '[$code] $message at $line:$column';
  }
}
