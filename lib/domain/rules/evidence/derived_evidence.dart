import 'dart:convert';

import '../ast/rule_action.dart';
import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import '../core/rule_version.dart';
import '../facts/semantic_ref.dart';
import 'evidence_id.dart';

/// Action 产出的正式结果；与解释执行过程的 RuleTrace 分离保存。
class DerivedEvidence {
  const DerivedEvidence({
    required this.id,
    required this.caseId,
    required this.ruleId,
    required this.ruleVersion,
    required this.ruleOrigin,
    required this.actionType,
    required this.category,
    required this.value,
    required this.targetKind,
    this.targetRefs = const [],
    this.relationId,
    this.supports = const [],
    required this.ruleRunId,
    required this.traceRef,
  });

  final EvidenceId id;
  final String caseId;
  final RuleId ruleId;
  final RuleVersion ruleVersion;
  final RuleOrigin ruleOrigin;
  final String actionType;
  final String category;
  final String value;
  final ActionTargetKind targetKind;
  final List<SemanticRef> targetRefs;
  final String? relationId;
  final List<EvidenceId> supports;
  final String ruleRunId;
  final String traceRef;

  Map<String, Object?> toJson() => {
        'id': id.toJson(),
        'caseId': caseId,
        'ruleId': ruleId.toJson(),
        'ruleVersion': ruleVersion.toJson(),
        'ruleOrigin': ruleOrigin.name,
        'actionType': actionType,
        'category': category,
        'value': value,
        'targetKind': targetKind.name,
        'targetRefs': targetRefs.map((ref) => ref.toJson()).toList(),
        if (relationId != null) 'relationId': relationId,
        'supports': supports.map((support) => support.toJson()).toList(),
        'ruleRunId': ruleRunId,
        'traceRef': traceRef,
      };

  factory DerivedEvidence.fromJson(Map<String, Object?> json) => DerivedEvidence(
        id: EvidenceId.fromJson(json['id'] as String),
        caseId: json['caseId'] as String,
        ruleId: RuleId.fromJson(json['ruleId'] as String),
        ruleVersion: RuleVersion.fromJson(json['ruleVersion'] as String),
        ruleOrigin: RuleOrigin.values.byName(json['ruleOrigin'] as String),
        actionType: json['actionType'] as String,
        category: json['category'] as String,
        value: json['value'] as String,
        targetKind: ActionTargetKind.values.byName(json['targetKind'] as String),
        targetRefs: [
          for (final item in (json['targetRefs'] as List? ?? const []))
            SemanticRef.fromJson(Map<String, Object?>.from(item as Map)),
        ],
        relationId: json['relationId'] as String?,
        supports: [
          for (final item in (json['supports'] as List? ?? const []))
            EvidenceId.fromJson(item as String),
        ],
        ruleRunId: json['ruleRunId'] as String,
        traceRef: json['traceRef'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is DerivedEvidence && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
