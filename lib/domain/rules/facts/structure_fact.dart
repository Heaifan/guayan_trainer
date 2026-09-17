library;

enum StructureKind { sanHe }

enum StructureState { formed, unformed }

class StructureFact {
  const StructureFact({
    required this.id,
    required this.kind,
    required this.state,
    required this.element,
    required this.memberObjectIds,
  });

  final String id;
  final StructureKind kind;
  final StructureState state;
  final String element;
  final List<String> memberObjectIds;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'state': state.name,
    'element': element,
    'memberObjectIds': memberObjectIds,
  };
}
