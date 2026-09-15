import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';

void main() {
  group('R5-D FINAL CORRECTION: RuleVersion SemVer', () {
    test('release > prerelease, build metadata ignored', () {
      final v1 = RuleVersion('1.0.1');
      final v2 = RuleVersion('1.0.0');
      expect(v1.compareTo(v2) > 0, true);

      final v3 = RuleVersion('2.0.0');
      final v4 = RuleVersion('1.9.9');
      expect(v3.compareTo(v4) > 0, true);

      final v5 = RuleVersion('1.0.0');
      final v6 = RuleVersion('1.0.0-alpha');
      expect(v5.compareTo(v6) > 0, true);

      final v7 = RuleVersion('1.0.0-alpha.2');
      final v8 = RuleVersion('1.0.0-alpha.1');
      expect(v7.compareTo(v8) > 0, true);

      final v9 = RuleVersion('1.0.0-beta');
      final v10 = RuleVersion('1.0.0-alpha');
      expect(v9.compareTo(v10) > 0, true);

      final v11 = RuleVersion('1.0.0+abc');
      final v12 = RuleVersion('1.0.0+xyz');
      expect(v11.compareTo(v12) == 0, true);
    });
  });
}
