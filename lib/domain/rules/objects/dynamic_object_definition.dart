library;

enum DynamicCardinality { exactlyOne, zeroOrOne, many }

class DynamicObjectDefinition {
  const DynamicObjectDefinition({
    required this.selectorId,
    required this.displayName,
    required this.cardinality,
    this.parameters = const [],
    this.resultObjectType = 'line',
  });

  final String selectorId;
  final String displayName;
  final DynamicCardinality cardinality;
  final List<String> parameters;
  final String resultObjectType;
}
