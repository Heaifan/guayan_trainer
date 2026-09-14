library;

import '../core/rule_definition.dart';
import '../evidence/evidence_id.dart';
import '../evidence/rule_hit.dart';
import 'binding_resolver.dart';

class EvidenceEmitter {
  const EvidenceEmitter();

  RuleHit emitHit({
    required RuleDefinition rule,
    required BindingContext context,
    required String conclusion,
    required List<EvidenceId> supports,
  }) {
    final evidenceId = EvidenceId.canonical(
      ruleId: rule.ruleId.id,
      version: rule.version.version,
      bindings: context.allBindings,
      conclusion: conclusion,
      supports: supports,
    );

    return RuleHit(
      hitId: evidenceId,
      ruleId: rule.ruleId,
      ruleVersion: rule.version,
      bindings: context.allBindings,
      conclusions: [conclusion],
      supports: supports,
    );
  }
}
