library;

/// 由基础事实或结构事实确定性推导出的、可被规则消费的事实。
class DerivedFact {
  const DerivedFact({
    required this.id,
    required this.type,
    required this.value,
    required this.sourceIds,
  });

  final String id;
  final String type;
  final Object value;
  final List<String> sourceIds;

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type,
    'value': value,
    'sourceIds': sourceIds,
  };
}
