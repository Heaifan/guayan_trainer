library;

import '../core/rule_definition.dart';

enum DiagnosticSeverity { info, warning, error }

class RuleResolutionDiagnostic {
  const RuleResolutionDiagnostic({
    required this.severity,
    required this.message,
    this.rule,
  });

  final DiagnosticSeverity severity;
  final String message;
  final RuleDefinition? rule;
}
