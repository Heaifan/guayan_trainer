library;

/// Rule AST 支持的四类动作：derive, tag, structure, record。
abstract class RuleAction {
  const RuleAction();
}

class DeriveAction extends RuleAction {
  const DeriveAction({
    required this.targetBinding,
    required this.factKey,
  });
  
  final String targetBinding;
  final String factKey;
}

class TagAction extends RuleAction {
  const TagAction({
    required this.categoryId,
    required this.tagId,
    this.subjectBinding,
  });
  
  final String categoryId;
  final String tagId;
  final String? subjectBinding;
}

class StructureAction extends RuleAction {
  const StructureAction({
    required this.structureId,
    required this.memberBindings,
  });
  
  final String structureId;
  final List<String> memberBindings;
}

class RecordAction extends RuleAction {
  const RecordAction({
    required this.recordType,
    required this.content,
  });
  
  final String recordType;
  final Map<String, dynamic> content;
}
