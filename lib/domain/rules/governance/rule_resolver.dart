library;

import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import 'resolved_rule_set.dart';
import 'rule_resolution_diagnostic.dart';

class RuleResolver {
  static ResolvedRuleSet resolve(List<RuleDefinition> rules) {
    final diagnostics = <RuleResolutionDiagnostic>[];
    final suppressed = <RuleDefinition>[];

    // 1. enabled / review filter
    final candidates = rules.where((r) {
      if (!r.enabled || r.reviewState != ReviewState.APPROVED) {
        suppressed.add(r);
        return false;
      }
      return true;
    }).toList();

    // 2. group by ruleId
    final grouped = <RuleId, List<RuleDefinition>>{};
    for (var r in candidates) {
      grouped.putIfAbsent(r.ruleId, () => []).add(r);
    }

    // 3. select active version
    final versionResolved = <RuleId, RuleDefinition>{};
    for (var entry in grouped.entries) {
      final rulesForId = entry.value;
      final versions = <String>{};
      bool hasDuplicates = false;
      for (var r in rulesForId) {
        if (!versions.add(r.version.version)) {
          diagnostics.add(
            RuleResolutionDiagnostic(
              severity: DiagnosticSeverity.error,
              message: 'Duplicate ruleId and version',
              rule: r,
            ),
          );
          hasDuplicates = true;
        }
      }
      if (hasDuplicates) {
        suppressed.addAll(rulesForId);
        continue;
      }
      rulesForId.sort((a, b) => a.version.compareTo(b.version));
      final highest = rulesForId.last;
      versionResolved[highest.ruleId] = highest;
      suppressed.addAll(rulesForId.take(rulesForId.length - 1));
    }

    // 4. apply CUSTOM override
    final activeCandidates = Map.of(versionResolved);
    for (var rule in versionResolved.values) {
      if (rule.overrideTarget != null) {
        final targetId = rule.overrideTarget!;
        if (rule.origin != RuleOrigin.CUSTOM) {
          diagnostics.add(
            RuleResolutionDiagnostic(
              severity: DiagnosticSeverity.error,
              message: 'Only CUSTOM rules can override',
              rule: rule,
            ),
          );
          activeCandidates.remove(rule.ruleId);
          suppressed.add(rule);
          continue;
        }
        final targetRule = versionResolved[targetId];
        if (targetRule == null) {
          diagnostics.add(
            RuleResolutionDiagnostic(
              severity: DiagnosticSeverity.error,
              message: 'Invalid overrideTarget',
              rule: rule,
            ),
          );
          activeCandidates.remove(rule.ruleId);
          suppressed.add(rule);
          continue;
        }
        if (targetRule.origin == RuleOrigin.CUSTOM) {
          diagnostics.add(
            RuleResolutionDiagnostic(
              severity: DiagnosticSeverity.error,
              message: 'CUSTOM override CUSTOM disallowed',
              rule: rule,
            ),
          );
          activeCandidates.remove(rule.ruleId);
          suppressed.add(rule);
          continue;
        }
        if (targetRule.overrideTarget != null) {
          diagnostics.add(
            RuleResolutionDiagnostic(
              severity: DiagnosticSeverity.error,
              message: 'Override chain detected',
              rule: rule,
            ),
          );
          activeCandidates.remove(rule.ruleId);
          suppressed.add(rule);
          continue;
        }
        activeCandidates.remove(targetId);
        if (!suppressed.contains(targetRule)) suppressed.add(targetRule);
      }
    }

    // 5. stable deterministic sort
    final finalRules = activeCandidates.values.toList();
    _sortRules(finalRules);
    _sortRules(suppressed);

    return ResolvedRuleSet(
      activeRules: finalRules,
      suppressedRules: suppressed,
      diagnostics: diagnostics,
    );
  }

  static void _sortRules(List<RuleDefinition> list) {
    list.sort((a, b) {
      int cmp = a.namespace.compareTo(b.namespace);
      if (cmp != 0) return cmp;
      cmp = a.ruleId.id.compareTo(b.ruleId.id);
      if (cmp != 0) return cmp;
      return a.version.compareTo(b.version);
    });
  }
}
