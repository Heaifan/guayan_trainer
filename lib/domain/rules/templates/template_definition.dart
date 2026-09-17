library;

import 'rule_slot_definition.dart';

enum RuleTemplateCategory { property, state, wuxingRelation, branchRelation }

class TemplateDefinition {
  const TemplateDefinition({
    required this.id,
    required this.displayName,
    required this.category,
    required this.slots,
    required this.operatorId,
    required this.previewPattern,
    required this.dslPattern,
  });

  final String id;
  final String displayName;
  final RuleTemplateCategory category;
  final List<RuleSlotDefinition> slots;
  final String? operatorId;
  final String previewPattern;
  final String dslPattern;
}
