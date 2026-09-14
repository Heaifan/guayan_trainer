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
      displayName: '已入墓',
      operandCount: 1,
      operandKinds: [OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.ruMu,
      displayName: '入墓于',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chongMu,
      displayName: '冲墓',
      operandCount: 2,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chuMu,
      displayName: '出墓',
      operandCount: 3,
      operandKinds: [OperandKind.bindingRef, OperandKind.bindingRef, OperandKind.bindingRef],
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.hasTag,
      displayName: '具有标签',
      operandCount: 3,
      operandKinds: [OperandKind.bindingRef, OperandKind.tagCategoryLiteral, OperandKind.shenShaIdLiteral],
      vocabularyPolicy: VocabularyPolicy.open,
    ),
  ];

  static CanonicalConditionDefinition? getDefinition(String operatorId) {
    for (final def in _conditions) {
      if (def.operatorId == operatorId) return def;
    }
    return null;
  }
}
