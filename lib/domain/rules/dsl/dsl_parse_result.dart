library;

import 'dsl_diagnostic.dart';

class ParseResult<T> {
  const ParseResult({this.value, this.diagnostics = const []});

  final T? value;
  final List<DslDiagnostic> diagnostics;

  bool get hasErrors =>
      diagnostics.any((d) => d.severity == DiagnosticSeverity.error);
  bool get isSuccess => value != null && !hasErrors;
}
