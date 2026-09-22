import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/action_resolution.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  group('ActionResolution · 回头生克', () {
    test('回头生只保留原动爻普通主动生克行为，不生成状态', () {
      final relation = RelationInstance.from(
        type: RelationType.huiTouSheng,
        ruleId: 'test.hui_tou_sheng',
        source: YaoEndpoint(LineScope.changed, 2),
        target: YaoEndpoint(LineScope.original, 2),
      );

      final result = resolveReturnActionResolution([relation]);

      expect(result.entries, hasLength(1));
      final entry = result.entries.single;
      expect(entry.actor, YaoEndpoint(LineScope.original, 2));
      expect(entry.action, ActionKind.ordinaryShengKeOutbound);
      expect(entry.disposition, ActionResolutionDisposition.preserved);
      expect(entry.reason, ActionResolutionReason.huiTouShengPreservesOutbound);
      expect(entry.evidence, [relation]);
      expect(result.preservedOriginalPositions, {2});
      expect(result.blockedOriginalPositions, isEmpty);
    });

    test('回头克阻断原动爻普通主动生克行为', () {
      final relation = RelationInstance.from(
        type: RelationType.huiTouKe,
        ruleId: 'test.hui_tou_ke',
        source: YaoEndpoint(LineScope.changed, 3),
        target: YaoEndpoint(LineScope.original, 3),
      );

      final result = resolveReturnActionResolution([relation]);

      expect(result.entries, hasLength(1));
      final entry = result.entries.single;
      expect(entry.actor, YaoEndpoint(LineScope.original, 3));
      expect(entry.disposition, ActionResolutionDisposition.blocked);
      expect(entry.reason, ActionResolutionReason.huiTouKeBlocksOutbound);
      expect(result.blockedOriginalPositions, {3});
      expect(result.preservedOriginalPositions, isEmpty);
    });

    test('非同位或方向错误的回头关系不进入行为裁决', () {
      final wrongDirection = RelationInstance.from(
        type: RelationType.huiTouKe,
        ruleId: 'test.wrong_direction',
        source: YaoEndpoint(LineScope.original, 1),
        target: YaoEndpoint(LineScope.changed, 1),
      );
      final wrongPosition = RelationInstance.from(
        type: RelationType.huiTouSheng,
        ruleId: 'test.wrong_position',
        source: YaoEndpoint(LineScope.changed, 1),
        target: YaoEndpoint(LineScope.original, 2),
      );

      final result = resolveReturnActionResolution([
        wrongDirection,
        wrongPosition,
      ]);

      expect(result.entries, isEmpty);
    });
  });
}
