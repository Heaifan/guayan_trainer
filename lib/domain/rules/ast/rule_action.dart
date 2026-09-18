library;

import '../facts/rule_value.dart';

/// Rule AST 支持的四类动作：derive, tag, structure, record。
abstract class RuleAction {
  const RuleAction();
}

enum ActionTargetKind { object, relation, caseTarget }

class ActionTarget {
  const ActionTarget.object({required this.subjectBinding})
      : kind = ActionTargetKind.object,
        sourceBinding = null,
        targetBinding = null,
        relationId = null;

  const ActionTarget.relation({
    this.sourceBinding,
    this.targetBinding,
    required this.relationId,
  })  : kind = ActionTargetKind.relation,
        subjectBinding = null;

  const ActionTarget.conditionRelation({required this.relationId})
      : kind = ActionTargetKind.relation,
        subjectBinding = null,
        sourceBinding = null,
        targetBinding = null;

  const ActionTarget.caseTarget()
      : kind = ActionTargetKind.caseTarget,
        subjectBinding = null,
        sourceBinding = null,
        targetBinding = null,
        relationId = null;

  final ActionTargetKind kind;
  final String? subjectBinding;
  final String? sourceBinding;
  final String? targetBinding;
  final String? relationId;

  Map<String, Object?> toJson() => switch (kind) {
        ActionTargetKind.object => {
            'kind': 'object',
            'binding': subjectBinding,
          },
        ActionTargetKind.relation => {
            'kind': 'relation',
            if (sourceBinding != null) 'source': sourceBinding,
            if (targetBinding != null) 'target': targetBinding,
            'relationId': relationId,
          },
        ActionTargetKind.caseTarget => {'kind': 'case'},
      };

  factory ActionTarget.fromJson(Map<String, Object?> json) => switch (json['kind']) {
        'object' => ActionTarget.object(subjectBinding: json['binding'] as String),
        'relation' => ActionTarget.relation(
            sourceBinding: json['source'] as String?,
            targetBinding: json['target'] as String?,
            relationId: json['relationId'] as String,
          ),
        'case' => const ActionTarget.caseTarget(),
        _ => throw ArgumentError('Unknown action target kind'),
      };
}

class DeriveAction extends RuleAction {
  const DeriveAction({
    required this.targetBinding,
    required this.factKey,
  });

  final String targetBinding;
  final String factKey;
}

class TagAction extends RuleAction {
  const TagAction({
    required this.categoryId,
    required this.tagId,
    this.subjectBinding,
    this.target,
  });

  final String categoryId;
  final String tagId;
  final String? subjectBinding;
  final ActionTarget? target;
}

class StructureAction extends RuleAction {
  const StructureAction({
    required this.structureId,
    required this.memberBindings,
  });

  final String structureId;
  final List<String> memberBindings;
}

class RecordAction extends RuleAction {
  const RecordAction({
    required this.recordType,
    required this.content,
  });

  final String recordType;
  final Map<String, RuleValue> content;
}
