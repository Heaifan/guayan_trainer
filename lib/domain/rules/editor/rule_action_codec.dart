library;

import '../ast/rule_action.dart';
import '../facts/rule_value.dart';

class RuleActionCodec {
  static Map<String, dynamic> toJson(RuleAction action) {
    if (action is DeriveAction) {
      return {
        'type': 'derive',
        'target': action.targetBinding,
        'key': action.factKey,
      };
    }
    if (action is TagAction) {
      return {
        'type': 'tag',
        'cat': action.categoryId,
        'tagId': action.tagId,
        'subject': action.subjectBinding,
        if (action.target != null) 'target': action.target!.toJson(),
      };
    }
    if (action is StructureAction) {
      return {
        'type': 'structure',
        'id': action.structureId,
        'members': action.memberBindings,
      };
    }
    if (action is RecordAction) {
      return {
        'type': 'record',
        'id': action.recordType,
        'content': action.content.map((k, v) => MapEntry(k, v.toJson())),
      };
    }
    throw ArgumentError('Unknown action');
  }

  static RuleAction fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'derive':
        return DeriveAction(
          targetBinding: json['target'],
          factKey: json['key'],
        );
      case 'tag':
        return TagAction(
          categoryId: json['cat'],
          tagId: json['tagId'],
          subjectBinding: json['subject'],
          target: json['target'] == null
              ? null
              : ActionTarget.fromJson(
                  Map<String, Object?>.from(json['target'] as Map),
                ),
        );
      case 'structure':
        return StructureAction(
          structureId: json['id'],
          memberBindings: (json['members'] as List).cast<String>(),
        );
      case 'record':
        final content = (json['content'] as Map).map(
          (k, v) => MapEntry(k as String, RuleValue.fromJson(v)),
        );
        return RecordAction(recordType: json['id'], content: content);
    }
    throw ArgumentError('Unknown action json');
  }
}
