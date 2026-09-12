/// 卦中某一端点的**绘线定位键**。
///
/// ⚠️ 身份真源已上移：关系身份（RelationKey 的 source / target）自 R4 起由
/// `relation_endpoint.dart` 的 [RelationEndpoint] 承担。本类型只服务于
/// 可视化 / 绘线层（R5 adapter 把领域端点解析成控件位置），
/// **不得**再被用来构造 RelationKey。
library;

import 'line_scope.dart';

export 'line_scope.dart';

/// 爻位端点：1 = 初爻 … 6 = 上爻。
///
/// 构造时 runtime 校验爻位（不依赖 assert，持久化反序列化同样经过校验）。
class LineEndpoint {
  const LineEndpoint._(this.scope, this.position);

  factory LineEndpoint(LineScope scope, int position) {
    if (position < 1 || position > 6) {
      throw ArgumentError.value(position, 'position', '爻位必须在 1..6');
    }
    return LineEndpoint._(scope, position);
  }

  final LineScope scope;
  final int position;

  /// 唯一 canonical 语义 id，例如 `original-3`、`changed-6`。
  String get semanticId => '${scope.machineName}-$position';

  Map<String, Object> toJson() => {
    'scope': scope.machineName,
    'position': position,
  };

  factory LineEndpoint.fromJson(Map<String, Object?> json) => LineEndpoint(
    LineScope.values.byName(json['scope'] as String),
    json['position'] as int,
  );

  @override
  bool operator ==(Object other) =>
      other is LineEndpoint && other.semanticId == semanticId;

  @override
  int get hashCode => semanticId.hashCode;

  @override
  String toString() => semanticId;
}
