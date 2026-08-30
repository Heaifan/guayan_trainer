/// Canonical 无歧义性（T1）：任意合法 RuleId / Subtype / 字段组合
/// 绝不能生成相同的 RelationKey canonical（单射编码）。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_endpoint.dart';
import 'package:guayan_trainer/domain/relation_key.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  final source = LineEndpoint(LineScope.original, 3);
  final target = LineEndpoint(LineScope.changed, 3);

  RelationKey build({
    RelationType type = RelationType.huiTouSheng,
    String ruleId = 'sys.hui_tou_sheng',
    int ruleVersion = 1,
    String? subtype,
  }) =>
      RelationKey.from(
        type: type,
        ruleId: ruleId,
        ruleVersion: ruleVersion,
        source: source,
        target: target,
        subtype: subtype,
      );

  group('T1 · canonical 无歧义性', () {
    test('ruleId 含 | 时与其他字段组合不碰撞', () {
      // 旧拼接格式下存在理论碰撞风险的组合：ruleId='a|v1' v2
      // vs ruleId='a' v1 subtype='v2|...'
      final k1 = build(ruleId: 'a|v1', ruleVersion: 2);
      final k2 = build(ruleId: 'a', ruleVersion: 1, subtype: 'v2|...');
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('ruleId 含 | 与 subtype 含 | 不混淆', () {
      final k1 = build(ruleId: 'x|y');
      final k2 = build(ruleId: 'x', subtype: 'y');
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('ruleId 含 -> 不产生歧义', () {
      final k1 = build(ruleId: 'a->b');
      final k2 = build(ruleId: 'a', subtype: 'b');
      expect(k1.canonical, isNot(k2.canonical));
      expect(k1.canonical, isNot(contains('<->')));
    });

    test('subtype 含 | 与 <-> 不产生歧义', () {
      final k1 = build(subtype: 'v2|x<->y');
      final k2 = build(subtype: 'v2');
      expect(k1.canonical, isNot(k2.canonical));
    });

    test('ruleId 含反斜杠 \\ 正确转义', () {
      final k = build(ruleId: r'a\b');
      expect(k.canonical, contains(r'a\\b'));
    });

    test('单射抽样：多组不同字段组合 canonical 两两不同', () {
      final keys = [
        build(),
        build(ruleId: 'sys.hui_tou_sheng', subtype: 'a'),
        build(ruleId: 'sys.hui_tou_sheng', ruleVersion: 2),
        build(type: RelationType.huiTouKe, ruleId: 'sys.hui_tou_ke'),
        build(ruleId: 'custom|x'),
        build(ruleId: 'custom', subtype: 'x'),
      ];
      final canonicals = keys.map((k) => k.canonical).toSet();
      expect(canonicals.length, keys.length, reason: '6 个组合必须互不相同');
    });

    test('JSON round-trip 后 canonical 不变（含特殊字符）', () {
      final k = build(ruleId: 'custom|home->door', subtype: 'v2|<->');
      final restored = RelationKey.fromJson(k.toJson());
      expect(restored.canonical, k.canonical);
      expect(restored, k);
    });

    test('对称关系端点含特殊字符时仍稳定排序去重', () {
      // 端点 semanticId 由域内生成（original-1..6 / changed-1..6），
      // 不含分隔符；此处回归确认对称排序路径不受转义影响。
      final ab = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: 'sys.liu_chong',
        source: LineEndpoint(LineScope.original, 1),
        target: LineEndpoint(LineScope.original, 6),
      );
      final ba = RelationKey.from(
        type: RelationType.liuChong,
        ruleId: 'sys.liu_chong',
        source: LineEndpoint(LineScope.original, 6),
        target: LineEndpoint(LineScope.original, 1),
      );
      expect(ab.canonical, ba.canonical);
    });
  });
}
