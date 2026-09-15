library;

import '../core/rule_definition.dart';
import 'rule_resolution_diagnostic.dart';

class ResolvedRuleSet {
  const ResolvedRuleSet({
    required this.activeRules,
    required this.suppressedRules,
    required this.diagnostics,
  });

  final List<RuleDefinition> activeRules;
  final List<RuleDefinition> suppressedRules;
  final List<RuleResolutionDiagnostic> diagnostics;
}
