/// RelationKey 序列化：JSON round-trip 保真，且 key 与展示名 / UI 文本解耦。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_endpoint.dart';
import 'package:guayan_trainer/domain/relation_key.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  group('RelationKey 序列化', () {
    test('JSON round-trip 后 canonical 与相等性不变', () {
      final key = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        source: LineEndpoint(LineScope.changed, 3),
        target: LineEndpoint(LineScope.original, 3),
      );
      final restored = RelationKey.fromJson(key.toJson());
      expect(restored, key);
      expect(restored.canonical, key.canonical);
    });

    test('key 不依赖展示名 / UI 文本', () {
      final key = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        source: LineEndpoint(LineScope.changed, 3),
        target: LineEndpoint(LineScope.original, 3),
      );
      expect(
        key.canonical,
        isNot(contains(RelationType.huiTouSheng.displayName)),
      );
    });
  });
}
