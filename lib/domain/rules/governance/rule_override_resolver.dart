library;

import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import 'rule_resolution_diagnostic.dart';

class RuleOverrideResolver {
  static void applyOverrides({
    required Map<RuleId, RuleDefinition> versionResolved,
    required Map<RuleId, RuleDefinition> activeCandidates,
    required List<RuleDefinition> suppressed,
    required List<RuleResolutionDiagnostic> diagnostics,
  }) {
    for (var rule in versionResolved.values) {
      if (rule.overrideTarget == null) continue;

      final targetId = rule.overrideTarget!;
      if (rule.origin != RuleOrigin.CUSTOM) {
        _failClosed(
          rule,
          'Only CUSTOM rules can override',
          activeCandidates,
          suppressed,
          diagnostics,
        );
        continue;
      }

      final targetRule = versionResolved[targetId];
      if (targetRule == null) {
        _failClosed(
          rule,
          'Invalid overrideTarget',
          activeCandidates,
          suppressed,
          diagnostics,
        );
        continue;
      }

      if (targetRule.origin == RuleOrigin.CUSTOM) {
        _failClosed(
          rule,
          'CUSTOM override CUSTOM disallowed',
          activeCandidates,
          suppressed,
          diagnostics,
        );
        continue;
      }

      if (targetRule.overrideTarget != null) {
        _failClosed(
          rule,
          'Override chain detected',
          activeCandidates,
          suppressed,
          diagnostics,
        );
        continue;
      }

      // Valid override
      activeCandidates.remove(targetId);
      if (!suppressed.contains(targetRule)) suppressed.add(targetRule);
    }
  }

  static void _failClosed(
    RuleDefinition rule,
    String message,
    Map<RuleId, RuleDefinition> activeCandidates,
    List<RuleDefinition> suppressed,
    List<RuleResolutionDiagnostic> diagnostics,
  ) {
    diagnostics.add(
      RuleResolutionDiagnostic(
        severity: DiagnosticSeverity.error,
        message: message,
        rule: rule,
      ),
    );
    activeCandidates.remove(rule.ruleId);
    suppressed.add(rule);
  }
}
