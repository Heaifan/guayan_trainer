/// 某条关系上的用户备注。
///
/// 备注与关系实例解耦：不绑定任何临时 RelationInstance UUID，
/// 而是通过 (caseId + [RelationNote.relationKey]) 在重算后重新绑定。
/// 用于记录这条关系在具体占问中的语义、验证结果与复盘结论。
library;

import 'relation_key.dart';

class RelationNote {
  const RelationNote({
    required this.caseId,
    required this.relationKey,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 所属卦例（绑定作用域）。
  final String caseId;

  /// 稳定关系身份（绑定依据）。
  final RelationKey relationKey;

  final String content;

  final DateTime createdAt;
  final DateTime updatedAt;

  RelationNote copyWith({String? content, DateTime? updatedAt}) =>
      RelationNote(
        caseId: caseId,
        relationKey: relationKey,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'caseId': caseId,
        'relationKey': relationKey.toJson(),
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory RelationNote.fromJson(Map<String, Object?> json) => RelationNote(
        caseId: json['caseId'] as String,
        relationKey:
            RelationKey.fromJson(json['relationKey'] as Map<String, Object?>),
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
