import '../line_state.dart';

/// 一次生成时冻结的排盘事实。`castingTime` 是唯一事实源。
class CastingSnapshot {
  CastingSnapshot({
    required this.castingTime,
    required this.subject,
    required List<LineState> lines,
    required this.originalHexagramName,
    this.changedHexagramName,
    required List<int> movingPositions,
  })  : lines = List.unmodifiable(lines),
        movingPositions = List.unmodifiable(movingPositions);

  final DateTime castingTime;
  final String subject;
  final List<LineState> lines;
  final String originalHexagramName;
  final String? changedHexagramName;
  final List<int> movingPositions;

  CastingSnapshot copyWith({String? subject}) => CastingSnapshot(
    castingTime: castingTime,
    subject: subject ?? this.subject,
    lines: lines,
    originalHexagramName: originalHexagramName,
    changedHexagramName: changedHexagramName,
    movingPositions: movingPositions,
  );

  Map<String, Object?> toJson() => {
    'castingTime': castingTime.toIso8601String(),
    'subject': subject,
    'lines': lines.map((line) => line.toJson()).toList(),
    'originalHexagramName': originalHexagramName,
    if (changedHexagramName != null) 'changedHexagramName': changedHexagramName,
    'movingPositions': movingPositions,
  };

  factory CastingSnapshot.fromJson(Map<String, Object?> json) => CastingSnapshot(
    castingTime: DateTime.parse(json['castingTime'] as String),
    subject: json['subject'] as String? ?? '',
    lines: (json['lines'] as List<Object?>)
        .map((line) => LineState.fromJson(line as Map<String, Object?>))
        .toList(),
    originalHexagramName: json['originalHexagramName'] as String,
    changedHexagramName: json['changedHexagramName'] as String?,
    movingPositions: [
      for (final position in (json['movingPositions'] as List<Object?>? ?? const []))
        position as int,
    ],
  );

  @override
  bool operator ==(Object other) => other is CastingSnapshot &&
      other.castingTime == castingTime &&
      other.subject == subject &&
      _sameLines(other.lines, lines) &&
      other.originalHexagramName == originalHexagramName &&
      other.changedHexagramName == changedHexagramName &&
      _sameInts(other.movingPositions, movingPositions);

  @override
  int get hashCode => Object.hash(
    castingTime, subject, originalHexagramName, changedHexagramName,
    lines.map((line) => line.toJson()).join(), movingPositions.join(','),
  );
}

bool _sameLines(List<LineState> a, List<LineState> b) =>
    a.length == b.length && a.asMap().entries.every((e) => e.value.toJson().toString() == b[e.key].toJson().toString());

bool _sameInts(List<int> a, List<int> b) =>
    a.length == b.length && a.asMap().entries.every((e) => e.value == b[e.key]);
