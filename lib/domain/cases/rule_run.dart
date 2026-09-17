import 'dart:convert';

import '../rule_execution_context.dart';

/// 一次规则观察的冻结结果，不依赖未来仍存在的 RuleDefinition。
class RuleRun {
  const RuleRun({
    required this.id,
    required this.executedAt,
    required this.ruleContext,
    required this.result,
    required this.evidence,
  });

  factory RuleRun.original({
    required DateTime executedAt,
    required RuleExecutionContext ruleContext,
    required Map<String, Object?> result,
    required List<Map<String, Object?>> evidence,
  }) => RuleRun(
    id: 'original',
    executedAt: executedAt,
    ruleContext: ruleContext,
    result: Map<String, Object?>.unmodifiable(result),
    evidence: List.unmodifiable([
      for (final item in evidence) Map<String, Object?>.unmodifiable(item),
    ]),
  );

  final String id;
  final DateTime executedAt;
  final RuleExecutionContext ruleContext;
  final Map<String, Object?> result;
  final List<Map<String, Object?>> evidence;

  Map<String, Object?> toJson() => {
    'id': id,
    'executedAt': executedAt.toIso8601String(),
    'ruleContext': ruleContext.toJson(),
    'result': result,
    'evidence': evidence,
  };

  factory RuleRun.fromJson(Map<String, Object?> json) => RuleRun(
    id: json['id'] as String,
    executedAt: DateTime.parse(json['executedAt'] as String),
    ruleContext: RuleExecutionContext.fromJson(json['ruleContext'] as Map<String, Object?>),
    result: Map<String, Object?>.from(json['result'] as Map),
    evidence: [
      for (final item in (json['evidence'] as List<Object?>? ?? const []))
        Map<String, Object?>.from(item as Map),
    ],
  );

  @override
  bool operator ==(Object other) => other is RuleRun && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
