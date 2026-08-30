/// 某一具体 HexagramCase 中，由某条规则识别出来的一条具体关系。
///
/// 运行时对象允许每次重算后重建（A != B），
/// 身份一律以 [RelationInstance.key]（RelationKey）为准。
/// 不持有任何按次生成的临时实例 id —— 那类 id 不能承担业务身份语义。
library;

import 'line_endpoint.dart';
import 'relation_key.dart';
import 'relation_type.dart';

class RelationInstance {
  const RelationInstance._({
    required this.key,
    required this.source,
    required this.target,
  });

  /// 单一构造入口：key 由语义坐标经 [RelationKey.from] 计算。
  factory RelationInstance.from({
    required RelationType type,
    required String ruleId,
    int ruleVersion = 1,
    required LineEndpoint source,
    required LineEndpoint target,
    String? subtype,
  }) {
    final key = RelationKey.from(
      type: type,
      ruleId: ruleId,
      ruleVersion: ruleVersion,
      source: source,
      target: target,
      subtype: subtype,
    );
    return RelationInstance._(key: key, source: source, target: target);
  }

  /// 稳定身份：重算后可重建，笔记凭它重新挂回。
  final RelationKey key;

  /// 关系类型（以 key 为唯一事实来源）。
  RelationType get type => key.type;

  final LineEndpoint source;
  final LineEndpoint target;

  Map<String, Object?> toJson() => {
        'key': key.toJson(),
        'source': source.toJson(),
        'target': target.toJson(),
      };

  factory RelationInstance.fromJson(Map<String, Object?> json) {
    final source =
        LineEndpoint.fromJson(json['source'] as Map<String, Object?>);
    final target =
        LineEndpoint.fromJson(json['target'] as Map<String, Object?>);
    final key = RelationKey.fromJson(json['key'] as Map<String, Object?>);
    return RelationInstance._(key: key, source: source, target: target);
  }

  @override
  bool operator ==(Object other) =>
      other is RelationInstance && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'RelationInstance(${key.canonical})';
}
