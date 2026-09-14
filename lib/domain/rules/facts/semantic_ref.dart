library;

/// 规则系统中引用六爻对象的稳定语义引用。
/// 同一个语义对象必须永远生成相同的 SemanticRef。
/// 不依赖于 Widget Key、内存地址、或 UI 索引。
class SemanticRef {
  const SemanticRef(this.kind, this.key);

  /// 引用的大类（如 line, changed_line, calendar, hexagram, role 等）。
  final String kind;

  /// 具体的身份标识（如 2, month, base, world 等）。
  final String key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticRef && other.kind == kind && other.key == key;

  @override
  int get hashCode => Object.hash(kind, key);

  Map<String, Object?> toJson() => {
        'kind': kind,
        'key': key,
      };

  factory SemanticRef.fromJson(Map<String, Object?> json) => SemanticRef(
        json['kind'] as String,
        json['key'] as String,
      );

  @override
  String toString() => 'SemanticRef($kind/$key)';

  // 常用预设工厂方法
  factory SemanticRef.line(int index) => SemanticRef('line', index.toString());
  factory SemanticRef.changedLine(int index) =>
      SemanticRef('changed_line', index.toString());
  factory SemanticRef.hiddenSpirit(int index) =>
      SemanticRef('hidden_spirit', index.toString());
  
  static const month = SemanticRef('calendar', 'month');
  static const day = SemanticRef('calendar', 'day');
  static const hexagramBase = SemanticRef('hexagram', 'base');
  static const hexagramChanged = SemanticRef('hexagram', 'changed');
  static const roleWorld = SemanticRef('role', 'world');
  static const roleResponse = SemanticRef('role', 'response');
}
