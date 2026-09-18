library;

import 'dynamic_object_definition.dart';
import '../ast/binding_selector.dart';

class DynamicObjectCatalog {
  static const all = [
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.all',
      displayName: '任一爻',
      cardinality: DynamicCardinality.many,
    ),
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.by_spirit',
      displayName: '六神所临之爻',
      cardinality: DynamicCardinality.exactlyOne,
      parameters: ['spirit'],
    ),
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.shi',
      displayName: '世爻',
      cardinality: DynamicCardinality.exactlyOne,
    ),
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.ying',
      displayName: '应爻',
      cardinality: DynamicCardinality.exactlyOne,
    ),
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.moving',
      displayName: '发动之爻',
      cardinality: DynamicCardinality.many,
    ),
    DynamicObjectDefinition(
      selectorId: 'dynamic.line.by_branch_relation',
      displayName: '与指定爻存在地支关系之爻',
      cardinality: DynamicCardinality.many,
      parameters: ['referenceObject', 'relation'],
    ),
  ];

  static DynamicObjectDefinition? find(String selectorId) {
    for (final item in all) {
      if (item.selectorId == selectorId) return item;
    }
    return null;
  }

  static String displayNameFor(DynamicBindingSelector selector) {
    final definition = find(selector.selectorId);
    if (definition == null) return selector.selectorId;
    if (selector.selectorId == 'dynamic.line.by_spirit') {
      final spirit = _spiritNames[selector.parameters['spirit']];
      if (spirit != null) return '$spirit所临之爻';
    }
    return definition.displayName;
  }

  static const _spiritNames = {
    'spirit.qing_long': '青龙',
    'spirit.zhu_que': '朱雀',
    'spirit.gou_chen': '勾陈',
    'spirit.teng_she': '螣蛇',
    'spirit.bai_hu': '白虎',
    'spirit.xuan_wu': '玄武',
  };
}
