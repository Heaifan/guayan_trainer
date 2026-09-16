library;

import '../core/rule_version.dart';

class RuleVersionBumper {
  static RuleVersion bumpPatch(RuleVersion old) {
    final parts = old.toString().split('.');
    if (parts.length != 3) return RuleVersion('1.0.0');
    final p = int.tryParse(parts[2]);
    if (p == null) return RuleVersion('1.0.0');
    return RuleVersion('${parts[0]}.${parts[1]}.${p + 1}');
  }
}
