import 'dart:convert';

import 'casting_snapshot.dart';
import 'rule_run.dart';

/// 一次真实生成的排盘事实档案。
class CaseRecord {
  const CaseRecord._({
    required this.id,
    required this.snapshot,
    required this.createdAt,
    required this.updatedAt,
    required this.subject,
    required this.note,
    required this.ruleRuns,
    this.isFavorite = false,
    this.deletedAt,
  });

  factory CaseRecord.create({
    required String id,
    required CastingSnapshot snapshot,
    required DateTime createdAt,
    required RuleRun originalRuleRun,
  }) => CaseRecord._(
    id: id,
    snapshot: snapshot,
    createdAt: createdAt,
    updatedAt: createdAt,
    subject: snapshot.subject,
    note: '',
    ruleRuns: List.unmodifiable([originalRuleRun]),
  );

  final String id;
  final CastingSnapshot snapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String subject;
  final String note;
  final List<RuleRun> ruleRuns;
  final bool isFavorite;
  final DateTime? deletedAt;

  String get subjectDisplay => subject.trim().isEmpty ? '未填写事项' : subject;

  CaseRecord copyWith({
    String? subject,
    String? note,
    DateTime? updatedAt,
    bool? isFavorite,
    DateTime? deletedAt,
    List<RuleRun>? ruleRuns,
  }) => CaseRecord._(
    id: id,
    snapshot: snapshot,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    subject: subject ?? this.subject,
    note: note ?? this.note,
    ruleRuns: ruleRuns ?? this.ruleRuns,
    isFavorite: isFavorite ?? this.isFavorite,
    deletedAt: deletedAt ?? this.deletedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'snapshot': snapshot.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'subject': subject,
    'note': note,
    'ruleRuns': ruleRuns.map((run) => run.toJson()).toList(),
    'isFavorite': isFavorite,
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory CaseRecord.fromJson(Map<String, Object?> json) => CaseRecord._(
    id: json['id'] as String,
    snapshot: CastingSnapshot.fromJson(json['snapshot'] as Map<String, Object?>),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    subject: json['subject'] as String? ?? '',
    note: json['note'] as String? ?? '',
    ruleRuns: [
      for (final run in (json['ruleRuns'] as List<Object?>? ?? const []))
        RuleRun.fromJson(run as Map<String, Object?>),
    ],
    isFavorite: json['isFavorite'] as bool? ?? false,
    deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
  );

  @override
  bool operator ==(Object other) => other is CaseRecord && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
