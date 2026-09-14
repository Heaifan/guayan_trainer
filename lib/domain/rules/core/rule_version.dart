library;

class RuleVersion {
  RuleVersion(this.version) {
    if (version.isEmpty) throw ArgumentError('RuleVersion cannot be empty');
    final semverRegex = RegExp(r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$');
    if (!semverRegex.hasMatch(version)) {
      throw ArgumentError('RuleVersion must strictly follow Semantic Versioning (e.g., 1.0.0). Invalid: ');
    }
  }

  final String version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RuleVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;

  String toJson() => version;
  factory RuleVersion.fromJson(String json) => RuleVersion(json);
  @override
  String toString() => version;
}
