library;

import 'rule_value.dart';
import 'semantic_ref.dart';

/// 规范化事实记录。
class FactRecord {
  const FactRecord({
    required this.factId,
    required this.subject,
    required this.predicateId,
    required this.value,
    required this.origin,
  });

  /// 事实唯一标识
  final String factId;

  /// 事实的主体对象
  final SemanticRef subject;

  /// 事实的谓词属性（如 "relative", "spirit", "branch" 等）
  final String predicateId;

  /// 事实的值
  final RuleValue value;

  /// 事实的来源阶段。
  /// R5-A 目前只区分 original 和 baseRelation。
  final FactOrigin origin;

  Map<String, Object?> toJson() => {
        'factId': factId,
        'subject': subject.toJson(),
        'predicateId': predicateId,
        'value': value.toJson(),
        'origin': origin.name,
      };

  factory FactRecord.fromJson(Map<String, Object?> json) => FactRecord(
        factId: json['factId'] as String,
        subject: SemanticRef.fromJson(json['subject'] as Map<String, Object?>),
        predicateId: json['predicateId'] as String,
        value: RuleValue.fromJson(json['value']),
        origin: FactOrigin.values.byName(json['origin'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactRecord &&
          other.factId == factId &&
          other.subject == subject &&
          other.predicateId == predicateId &&
          other.value == value &&
          other.origin == origin;

  @override
  int get hashCode =>
      Object.hash(factId, subject, predicateId, value, origin);
}

/// 事实的产生阶段（来源）
enum FactOrigin {
  original,
  baseRelation,
  derived,
}
