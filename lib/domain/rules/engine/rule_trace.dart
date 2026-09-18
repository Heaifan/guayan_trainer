library;

import 'dart:convert';

import '../facts/semantic_ref.dart';

enum RuleTraceStatus { matched, notMatched, skipped, error, success, failed }

enum RuleTraceKind { rule, all, any, not, predicate, quantified, binding, action }

/// Immutable, JSON-safe explanation of one rule execution step.
class RuleTrace {
  const RuleTrace({
    required this.kind,
    required this.label,
    required this.status,
    this.children = const [],
    this.expected,
    this.actual,
    this.reason,
    this.resolvedObjects = const [],
  });

  final RuleTraceKind kind;
  final String label;
  final RuleTraceStatus status;
  final List<RuleTrace> children;
  final Object? expected;
  final Object? actual;
  final String? reason;
  final List<SemanticRef> resolvedObjects;

  bool get matched => status == RuleTraceStatus.matched;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'label': label,
        'status': _statusName(status),
        if (children.isNotEmpty) 'children': children.map((e) => e.toJson()).toList(),
        if (expected != null) 'expected': expected,
        if (actual != null) 'actual': actual,
        if (reason != null) 'reason': reason,
        if (resolvedObjects.isNotEmpty)
          'resolvedObjects': resolvedObjects.map((e) => e.toJson()).toList(),
      };

  factory RuleTrace.fromJson(Map<String, Object?> json) => RuleTrace(
        kind: RuleTraceKind.values.byName(json['kind'] as String),
        label: json['label'] as String,
        status: _statusFromName(json['status'] as String),
        children: ((json['children'] as List?) ?? const [])
            .map((e) => RuleTrace.fromJson(Map<String, Object?>.from(e as Map)))
            .toList(),
        expected: json['expected'],
        actual: json['actual'],
        reason: json['reason'] as String?,
        resolvedObjects: ((json['resolvedObjects'] as List?) ?? const [])
            .map((e) => SemanticRef.fromJson(Map<String, Object?>.from(e as Map)))
            .toList(),
      );

  @override
  bool operator ==(Object other) =>
      other is RuleTrace && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

String _statusName(RuleTraceStatus status) => switch (status) {
      RuleTraceStatus.matched => 'MATCHED',
      RuleTraceStatus.notMatched => 'NOT_MATCHED',
      RuleTraceStatus.skipped => 'SKIPPED',
      RuleTraceStatus.error => 'ERROR',
      RuleTraceStatus.success => 'SUCCESS',
      RuleTraceStatus.failed => 'FAILED',
    };

RuleTraceStatus _statusFromName(String value) => switch (value) {
      'MATCHED' => RuleTraceStatus.matched,
      'NOT_MATCHED' => RuleTraceStatus.notMatched,
      'SKIPPED' => RuleTraceStatus.skipped,
      'ERROR' => RuleTraceStatus.error,
      'SUCCESS' => RuleTraceStatus.success,
      'FAILED' => RuleTraceStatus.failed,
      _ => throw ArgumentError('Unknown trace status: $value'),
    };
