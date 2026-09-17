library;

import 'condition_definition.dart';
import 'condition_id.dart';

class CanonicalConditionRegistry {
  static const List<CanonicalConditionDefinition> _conditions = [
    // Original Compatibility
    CanonicalConditionDefinition(
      operatorId: ConditionId.relative,
      displayName: '六亲关系',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.literal],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.spirit,
      displayName: '六兽',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.literal],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.generate,
      displayName: '生',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.empty,
      displayName: '空亡(旧版兼容)',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),

    // SUP1
    CanonicalConditionDefinition(
      operatorId: ConditionId.nayinIs,
      displayName: '纳音为',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.nayinIdLiteral],
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.xunKong,
      displayName: '空亡',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.yuePo,
      displayName: '月破',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.riPo,
      displayName: '日破',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.inTomb,
      displayName: '在库',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.ruMu,
      displayName: '入库于',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chongMu,
      displayName: '冲库',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chuMu,
      displayName: '出库',
      operandCount: 3,
      operandKinds: [
        OperandKind.bindingRef,
        OperandKind.bindingRef,
        OperandKind.bindingRef,
      ],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.hasTag,
      displayName: '具有标签',
      operandCount: 3,
      operandKinds: [
        OperandKind.bindingRef,
        OperandKind.tagCategoryLiteral,
        OperandKind.shenShaIdLiteral,
      ],
      vocabularyPolicy: VocabularyPolicy.open,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.stemIs,
      displayName: '天干为',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.literal],
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchIs,
      displayName: '地支为',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.literal],
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.elementIs,
      displayName: '五行为',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.literal],
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.controls,
      displayName: '克',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchClashes,
      displayName: '冲',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchCombines,
      displayName: '合',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchPunishes,
      displayName: '刑',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchHarms,
      displayName: '害',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.branchBreaks,
      displayName: '破',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.structureFormed,
      displayName: '成结构',
      operandCount: 1,
      operandKinds: [OperandKind.literal],
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
  ];

  static List<CanonicalConditionDefinition> get allConditions => _conditions;

  static CanonicalConditionDefinition? getDefinition(String operatorId) {
    for (final def in _conditions) {
      if (def.operatorId == operatorId) return def;
    }
    return null;
  }
}
