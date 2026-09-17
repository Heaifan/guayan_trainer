library;

import 'dynamic_object_definition.dart';

class DynamicObjectCatalog {
  static const all = [
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
}
