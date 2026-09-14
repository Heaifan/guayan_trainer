library;

class ActionSchemaValidator {
  static void validate(List<dynamic> actions, Set<String> declaredBindings) {
    for (final act in actions) {
      final type = act['type'];
      if (type == 'derive') {
        final target = act['target'];
        if (!declaredBindings.contains(target)) throw FormatException('derive targetBinding not found: ');
      } else if (type == 'tag') {
        final categoryId = act['categoryId'];
        final tagId = act['tagId'];
        if (categoryId == null || (categoryId as String).trim().isEmpty) throw FormatException('Tag without categoryId');
        if (tagId == null || (tagId as String).trim().isEmpty) throw FormatException('Tag without tagId');
        final subject = act['subject'];
        if (subject != null && !declaredBindings.contains(subject)) throw FormatException('tag subjectBinding not found: ');
      } else if (type == 'structure') {
        final structureId = act['structureId'];
        if (structureId == null || (structureId as String).trim().isEmpty) throw FormatException('Structure without structureId');
        final members = act['members'] as List?;
        if (members == null) throw FormatException('Structure missing members');
        for (final m in members) {
          if (!declaredBindings.contains(m)) throw FormatException('structure memberBinding not found: ');
        }
      } else if (type == 'record') {
        final recordType = act['recordType'];
        if (recordType == null || (recordType as String).trim().isEmpty) throw FormatException('Record without recordType');
        final content = act['content'];
        if (content == null || content is! Map) throw FormatException('Record missing content');
        for (final v in content.values) {
          if (v != null && v is! String && v is! int && v is! double && v is! bool) {
            throw FormatException('Record content values must be scalar');
          }
        }
      } else {
        throw FormatException('unknown action type: ');
      }
    }
  }
}
