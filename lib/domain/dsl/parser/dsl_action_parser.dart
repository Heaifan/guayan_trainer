library;

import '../../rules/ast/rule_action.dart';
import '../../rules/facts/rule_value.dart';
import '../dsl_diagnostics.dart';
import '../dsl_models.dart';

class DslActionParser {
  static RuleAction parseAction(DslLine line) {
    final text = line.text;
    if (text.startsWith('得 ')) {
      final parts = text.substring(2).trim().split(' ');
      if (parts.length != 2) throw _err(line, '无法识别得动作');
      return DeriveAction(targetBinding: parts[0], factKey: parts[1]);
    } else if (text.startsWith('取象 ')) {
      final parts = text.substring(3).trim().split(' ');
      if (parts.length != 2) throw _err(line, '无法识别取象动作');
      final tagParts = parts[1].split(':');
      if (tagParts.length != 2) throw _err(line, '取象目标格式应为 category:tag');
      return TagAction(
          categoryId: tagParts[0], tagId: tagParts[1], subjectBinding: parts[0]);
    } else if (text.startsWith('记 ')) {
      final parts = text.substring(2).trim().split(' ');
      if (parts.length < 2) throw _err(line, '记动作格式: 记 type key=value');
      final recordType = parts[0];
      final content = <String, RuleValue>{};
      for (int i = 1; i < parts.length; i++) {
        final kv = parts[i].split('=');
        if (kv.length == 2) content[kv[0]] = RuleValue.string(kv[1]);
      }
      return RecordAction(recordType: recordType, content: content);
    } else if (text.startsWith('成局 ')) {
      final parts = text.substring(3).trim().split(' ');
      if (parts.length < 2) throw _err(line, '成局动作格式: 成局 id A,B,C');
      final structureId = parts[0];
      final memberBindings = parts[1].split(',');
      return StructureAction(structureId: structureId, memberBindings: memberBindings);
    } else {
      throw _err(line, '无法识别动作: $text');
    }
  }

  static DslException _err(DslLine line, String msg) {
    return DslException(DslDiagnostic(line: line.lineNumber, column: 1, message: msg));
  }
}
