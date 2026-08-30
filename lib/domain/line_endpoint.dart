/// 卦中某一端点（爻）的稳定语义身份。
///
/// 端点身份只由「卦侧 + 爻位」决定，与运行时对象、计算顺序、UI 顺序、
/// 数据库 row id 均无关。RelationKey 的端点坐标由此对象产生。
library;

/// 卦侧：本卦（original）与变卦（changed）。
enum LineScope {
  original('original'),
  changed('changed');

  const LineScope(this.machineName);

  /// 稳定机器名，参与 canonical 序列化，禁止翻译成中文标题。
  final String machineName;
}

/// 爻位端点：1 = 初爻 … 6 = 上爻。
class LineEndpoint {
  const LineEndpoint(this.scope, this.position)
      : assert(position >= 1 && position <= 6, '爻位必须在 1..6');

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
