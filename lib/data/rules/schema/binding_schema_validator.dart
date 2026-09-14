library;

class BindingSchemaValidator {
  static Set<String> validateAndCollect(List<dynamic> bindings) {
    final declaredBindings = <String>{};
    // Pass 1: Collect and deduplicate
    for (final b in bindings) {
      final name = b['name'];
      if (name == null) throw FormatException('Binding必须有name');
      if (!declaredBindings.add(name)) {
        throw FormatException('Duplicate Binding name: ');
      }
    }
    // Pass 2: Validate selectors
    for (final b in bindings) {
      final selector = b['selector'];
      if (selector == null || selector is! Map) {
        throw FormatException('Binding missing selector');
      }
      final type = selector['type'];
      if (type == 'direct') {
        if (selector['target'] == null) {
          throw FormatException('DirectSelector missing target');
        }
      } else if (type == 'relative') {
        final baseBinding = selector['base'];
        if (baseBinding == null || selector['path'] == null) {
          throw FormatException('RelativeSelector missing base or path');
        }
        if (!declaredBindings.contains(baseBinding)) {
           throw FormatException('RelativeSelector unknown base binding: ');
        }
      } else {
        throw FormatException('Unknown BindingSelector type: ');
      }
    }
    return declaredBindings;
  }
}
