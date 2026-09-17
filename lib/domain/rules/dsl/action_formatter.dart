library;

import 'dart:convert';
import '../ast/rule_action.dart';

class ActionFormatter {
  const ActionFormatter();

  void format(RuleAction action, int indentLevel, StringBuffer buffer) {
    final indent = '    ' * indentLevel;

    if (action is DeriveAction) {
      buffer.writeln('$indent得 ${action.targetBinding} ${action.factKey}');
    } else if (action is TagAction) {
      if (action.subjectBinding != null) {
        buffer.writeln(
          '$indent取象 ${action.subjectBinding} ${action.categoryId}:${action.tagId}',
        );
      } else {
        buffer.writeln('$indent取象 ${action.categoryId}:${action.tagId}');
      }
    } else if (action is StructureAction) {
      buffer.writeln(
        '$indent成局 ${action.structureId}: ${action.memberBindings.join(', ')}',
      );
    } else if (action is RecordAction) {
      final map = action.content.map((k, v) => MapEntry(k, v.value));
      final jsonStr = jsonEncode(map);
      buffer.writeln('$indent记 ${action.recordType} $jsonStr');
    }
  }
}
