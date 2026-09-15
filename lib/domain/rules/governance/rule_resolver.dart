library;

import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import 'resolved_rule_set.dart';
import 'rule_override_resolver.dart';
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
      bool hasAmbiguity = false;
      for (int i = 0; i < rulesForId.length; i++) {
        for (int j = i + 1; j < rulesForId.length; j++) {
          if (rulesForId[i].version.compareTo(rulesForId[j].version) == 0) {
            diagnostics.add(
              RuleResolutionDiagnostic(
                severity: DiagnosticSeverity.error,
                message: 'Ambiguous equal precedence versions',
                rule: rulesForId[i],
              ),
            );
            hasAmbiguity = true;
          }
        }
      }
      if (hasAmbiguity) {
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
    RuleOverrideResolver.applyOverrides(
      versionResolved: versionResolved,
      activeCandidates: activeCandidates,
      suppressed: suppressed,
      diagnostics: diagnostics,
    );

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
