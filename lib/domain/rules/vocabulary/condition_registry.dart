library;

import 'condition_definition.dart';
import 'condition_id.dart';

class CanonicalConditionRegistry {
  static const List<CanonicalConditionDefinition> _conditions = [
    CanonicalConditionDefinition(
      operatorId: ConditionId.nayinIs,
      displayName: '纳音为',
      operandCount: 2,
      vocabularyPolicy: VocabularyPolicy.closed,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.xunKong,
      displayName: '空亡',
      operandCount: 1,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.yuePo,
      displayName: '月破',
      operandCount: 1,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.riPo,
      displayName: '日破',
      operandCount: 1,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.inTomb,
      displayName: '已入墓',
      operandCount: 1,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.ruMu,
      displayName: '入墓于',
      operandCount: 2,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chongMu,
      displayName: '冲墓',
      operandCount: 2,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.chuMu,
      displayName: '出墓',
      operandCount: 3,
    ),
    CanonicalConditionDefinition(
      operatorId: ConditionId.hasTag,
      displayName: '具有标签',
      operandCount: 3,
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
