/// Stable Relation Identity · Test A（确定性）与 Test B（差异性）。
///
/// Test A：相同语义坐标重复构造 → RelationKey 完全一致。
/// Test B：改变 type / source / target / 方向 / ruleId / ruleVersion / subtype
///         → 产生不同 RelationKey。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_endpoint.dart';
import 'package:guayan_trainer/domain/relation_key.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  final changed3 = LineEndpoint(LineScope.changed, 3);
  final original3 = LineEndpoint(LineScope.original, 3);
  final original1 = LineEndpoint(LineScope.original, 1);
  final original6 = LineEndpoint(LineScope.original, 6);

  final original5 = LineEndpoint(LineScope.original, 5);

  RelationKey huiTouSheng({int ruleVersion = 1}) => RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        ruleVersion: ruleVersion,
        source: changed3,
        target: original3,
      );

  group('Test A · 确定性', () {
    test('相同输入重复构造，RelationKey 完全一致', () {
      final k1 = huiTouSheng();
      final k2 = huiTouSheng();
      expect(k1.canonical, k2.canonical);
      expect(k1, k2);
      expect(k1.hashCode, k2.hashCode);
      expect(k1.direction, RelationDirection.directed);
    });

    test('相同输入重复构造对称关系，key 完全一致', () {
      final k1 = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: SystemRuleIds.liuChong,
        source: original1,
        target: original6,
      );
      final k2 = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: SystemRuleIds.liuChong,
        source: original1,
        target: original6,
      );
      expect(k1.canonical, k2.canonical);
    });
  });

  group('Test B · 差异性', () {
    test('不同 relation type → 不同 key', () {
      final k1 = huiTouSheng();
      final k2 = RelationKey.from(
        type: RelationType.huiTouKe,
        ruleId: SystemRuleIds.huiTouKe,
        source: changed3,
        target: original3,
      );
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('不同 source 端点 → 不同 key', () {
      final k1 = huiTouSheng();
      final k2 = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        source: LineEndpoint(LineScope.changed, 5),
        target: original3,
      );
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('不同 target 端点 → 不同 key', () {
      final k1 = huiTouSheng();
      final k2 = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        source: changed3,
        target: original5,
      );
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('有向关系 A→B 与 B→A → 不同 key（方向被显式保留）', () {
      final forward = RelationKey.from(
        type: RelationType.sheng,
        ruleId: SystemRuleIds.sheng,
        source: original1,
        target: original6,
      );
      final backward = RelationKey.from(
        type: RelationType.sheng,
        ruleId: SystemRuleIds.sheng,
        source: original6,
        target: original1,
      );
      expect(forward.direction, RelationDirection.directed);
      expect(forward.canonical, isNot(backward.canonical));
    });

    test('对称关系 A-B 与 B-A → 相同 key（端点排序规范化）', () {
      final ab = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: SystemRuleIds.liuChong,
        source: original1,
        target: original6,
      );
      final ba = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: SystemRuleIds.liuChong,
        source: original6,
        target: original1,
      );
      expect(ab.direction, RelationDirection.symmetric);
      expect(ab.canonical, ba.canonical);
      expect(ab, ba);
    });

    test('不同 ruleId → 不同 key', () {
      final k1 = huiTouSheng();
      final k2 = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: 'custom.other-school',
        source: changed3,
        target: original3,
      );
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('不同 ruleVersion → 不同 key', () {
      final k1 = huiTouSheng(ruleVersion: 1);
      final k2 = huiTouSheng(ruleVersion: 2);
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('不同 subtype → 不同 key', () {
      final k1 = huiTouSheng();
      final k2 = RelationKey.from(
        type: RelationType.huiTouSheng,
        ruleId: SystemRuleIds.huiTouSheng,
        source: changed3,
        target: original3,
        subtype: 'variant-a',
      );
      expect(k1.canonical, isNot(k2.canonical));
    });
  });
}
