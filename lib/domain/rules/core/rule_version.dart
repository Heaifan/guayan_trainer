library;

class RuleVersion implements Comparable<RuleVersion> {
  RuleVersion(this.version) {
    if (version.isEmpty) throw ArgumentError('RuleVersion cannot be empty');
    final semverRegex = RegExp(r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$');
    if (!semverRegex.hasMatch(version)) {
      throw ArgumentError('RuleVersion must strictly follow Semantic Versioning (e.g., 1.0.0). Invalid: ');
    }
  }

  final String version;

  @override
  int compareTo(RuleVersion other) {
    if (version == other.version) return 0;
    final partsA = version.split(RegExp(r'[-+]'))[0].split('.').map((e) => int.parse(e)).toList();
    final partsB = other.version.split(RegExp(r'[-+]'))[0].split('.').map((e) => int.parse(e)).toList();
    for (int i = 0; i < 3; i++) {
      if (partsA[i] != partsB[i]) return partsA[i].compareTo(partsB[i]);
    }
    // Simplistic comparison for pre-release / build metadata (just fallback to string)
    return version.compareTo(other.version);
  }


  @override
  bool operator ==(Object other) => identical(this, other) || other is RuleVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;

  String toJson() => version;
  factory RuleVersion.fromJson(String json) => RuleVersion(json);
  @override
  String toString() => version;
}
