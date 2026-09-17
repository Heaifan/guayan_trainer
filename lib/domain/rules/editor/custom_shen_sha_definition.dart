library;

class CustomShenShaDefinition {
  const CustomShenShaDefinition({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory CustomShenShaDefinition.fromJson(Map<String, Object?> json) {
    return CustomShenShaDefinition(
      id: json['id']! as String,
      name: json['name']! as String,
      description: json['description']! as String,
    );
  }
}
