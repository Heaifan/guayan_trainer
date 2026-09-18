import 'dart:convert';

import '../rule_execution_context.dart';
import '../rules/evidence/derived_evidence.dart';
import '../rules/engine/rule_trace.dart';
import '../rules/engine/engine_types.dart';

/// 一次规则观察的冻结结果，不依赖未来仍存在的 RuleDefinition。
class RuleRun {
  const RuleRun({
    required this.id,
    required this.executedAt,
    required this.ruleContext,
    required this.result,
    required this.evidence,
    this.derivedEvidence = const [],
    this.traces = const [],
  });

  factory RuleRun.original({
    required DateTime executedAt,
    required RuleExecutionContext ruleContext,
    required Map<String, Object?> result,
    required List<Map<String, Object?>> evidence,
    List<DerivedEvidence> derivedEvidence = const [],
    List<RuleTrace> traces = const [],
  }) => RuleRun(
    id: 'original',
    executedAt: executedAt,
    ruleContext: ruleContext,
    result: Map<String, Object?>.unmodifiable(result),
      evidence: List.unmodifiable([
      for (final item in evidence) Map<String, Object?>.unmodifiable(item),
      ]),
      derivedEvidence: List.unmodifiable(derivedEvidence),
      traces: List.unmodifiable(traces),
  );

  factory RuleRun.fromAnalysis({
    required String id,
    required DateTime executedAt,
    required RuleExecutionContext ruleContext,
    required AnalysisRun analysis,
  }) => RuleRun(
        id: id,
        executedAt: executedAt,
        ruleContext: ruleContext,
        result: {
          'matched': analysis.traces
              .where((trace) => trace.kind == RuleTraceKind.rule)
              .where((trace) => trace.status == RuleTraceStatus.matched)
              .length,
          'notMatched': analysis.traces
              .where((trace) => trace.kind == RuleTraceKind.rule)
              .where((trace) => trace.status == RuleTraceStatus.notMatched)
              .length,
          'skipped': analysis.traces
              .where((trace) => trace.status == RuleTraceStatus.skipped)
              .length,
          'errors': analysis.traces
              .where((trace) => trace.status == RuleTraceStatus.error)
              .length,
        },
        evidence: [
          for (final item in analysis.derivedEvidence) item.toJson(),
        ],
        derivedEvidence: analysis.derivedEvidence,
        traces: analysis.traces,
      );

  final String id;
  final DateTime executedAt;
  final RuleExecutionContext ruleContext;
  final Map<String, Object?> result;
  final List<Map<String, Object?>> evidence;
  final List<DerivedEvidence> derivedEvidence;
  final List<RuleTrace> traces;

  Map<String, Object?> toJson() => {
    'id': id,
    'executedAt': executedAt.toIso8601String(),
    'ruleContext': ruleContext.toJson(),
    'result': result,
    'evidence': evidence,
    'derivedEvidence': derivedEvidence.map((item) => item.toJson()).toList(),
    'traces': traces.map((trace) => trace.toJson()).toList(),
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
    derivedEvidence: [
      for (final item in (json['derivedEvidence'] as List<Object?>? ?? const []))
        DerivedEvidence.fromJson(Map<String, Object?>.from(item as Map)),
    ],
    traces: [
      for (final item in (json['traces'] as List<Object?>? ?? const []))
        RuleTrace.fromJson(Map<String, Object?>.from(item as Map)),
    ],
  );

  @override
  bool operator ==(Object other) => other is RuleRun && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
