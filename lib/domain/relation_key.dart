/// 关系的稳定语义身份（Stable Relation Identity）。
///
/// 相同语义关系 → 永远得到相同 RelationKey；
/// 不同语义关系 → 不发生误合并。
///
/// key 由语义坐标计算，与生成时间、运行时对象、计算顺序、UI 顺序、
/// 数据库自增 row id 完全无关。禁止在项目各处自行拼接 key 字符串，
/// 一切 key 只能通过 [RelationKey.from] 单一入口构造。
library;

import 'line_endpoint.dart';
import 'relation_type.dart';

/// 关系方向（构造 RelationKey 时显式处理）。
enum RelationDirection {
  /// 对称/无向：A-B 与 B-A 是同一关系，端点排序后入 key。
  symmetric,

  /// 有向：A→B 与 B→A 语义不同，端点顺序原样入 key。
  directed,
}

/// 稳定关系身份 Value Object。
///
/// 序列化规范（canonical，字段以 `|` 分隔，端点为 `->` / `<->`）：
/// ```text
/// 有向:   {type}|{ruleId}|v{ruleVersion}|{subtype|-}|{source}->{target}
/// 对称:   {type}|{ruleId}|v{ruleVersion}|{subtype|-}|{min}<->{max}
/// ```
/// 例：`hui_tou_sheng|sys.hui_tou_sheng|v1|-|changed-3->original-3`
///
/// 无歧义性：所有字符串字段（type / ruleId / subtype / 端点）在拼接前经
/// [_escape] 稳定转义（`\` → `\\`，`|` → `\|`），因此任意合法字段组合
/// 都不可能拼出相同 canonical（单射编码）。ruleId / subtype 来自自定义
/// 规则 JSON 时含分隔符也不会产生身份碰撞。
class RelationKey {
  const RelationKey._({
    required this.type,
    required this.ruleId,
    required this.ruleVersion,
    required this.source,
    required this.target,
    this.subtype,
  });

  /// 单一构造入口。
  factory RelationKey.from({
    required RelationType type,
    required String ruleId,
    int ruleVersion = 1,
    required LineEndpoint source,
    required LineEndpoint target,
    String? subtype,
  }) {
    if (ruleVersion < 1) {
      throw ArgumentError.value(ruleVersion, 'ruleVersion', '必须 >= 1');
    }
    return RelationKey._(
      type: type,
      ruleId: ruleId,
      ruleVersion: ruleVersion,
      source: source,
      target: target,
      subtype: subtype,
    );
  }

  final RelationType type;

  /// 规则稳定身份：系统规则为 `sys.*`，自定义规则为 JSON `id` 字段。
  final String ruleId;

  /// 规则版本：规则语义变更时递增，key 随之变化（有意为之）。
  final int ruleVersion;

  final LineEndpoint source;
  final LineEndpoint target;

  /// 可选变体/上下文（稳定机器名），例如未来区分合的种类。
  final String? subtype;

  /// 显式方向：对称类型 → symmetric；有向类型 → directed（顺序即方向）。
  RelationDirection get direction => type.directionKind ==
          RelationDirectionKind.symmetric
      ? RelationDirection.symmetric
      : RelationDirection.directed;

  /// 确定性 canonical 序列化；两端顺序按方向类别显式处理。
  /// 所有字符串字段均经 [_escape] 转义，保证单射（无歧义）。
  String get canonical {
    final head =
        '${_escape(type.machineName)}|${_escape(ruleId)}|v$ruleVersion|'
        '${subtype == null ? '-' : _escape(subtype!)}';
    final a = source.semanticId;
    final b = target.semanticId;
    if (type.directionKind == RelationDirectionKind.symmetric) {
      final sorted = [a, b]..sort();
      return '$head|${_escape(sorted[0])}<->${_escape(sorted[1])}';
    }
    return '$head|${_escape(a)}->${_escape(b)}';
  }

  /// 稳定转义：仅转义段分隔符 `|` 与转义符本身 `\`。
  /// 保证不同字段组合绝不生成相同 canonical（单射）。
  static String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('|', r'\|');

  Map<String, Object?> toJson() => {
        'type': type.machineName,
        'ruleId': ruleId,
        'ruleVersion': ruleVersion,
        'source': source.toJson(),
        'target': target.toJson(),
        if (subtype != null) 'subtype': subtype,
      };

  factory RelationKey.fromJson(Map<String, Object?> json) => RelationKey.from(
        type: RelationType.fromMachineName(json['type'] as String),
        ruleId: json['ruleId'] as String,
        ruleVersion: json['ruleVersion'] as int? ?? 1,
        source:
            LineEndpoint.fromJson(json['source'] as Map<String, Object?>),
        target:
            LineEndpoint.fromJson(json['target'] as Map<String, Object?>),
        subtype: json['subtype'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is RelationKey && other.canonical == canonical;

  @override
  int get hashCode => canonical.hashCode;

  @override
  String toString() => 'RelationKey($canonical)';
}
