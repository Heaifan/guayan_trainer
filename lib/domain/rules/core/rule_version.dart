library;

class RuleVersion implements Comparable<RuleVersion> {
  static final _regex = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-zA-Z0-9-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
  );

  RuleVersion(this.version) {
    if (version.isEmpty) throw ArgumentError('RuleVersion cannot be empty');
    if (!_regex.hasMatch(version)) {
      throw ArgumentError(
        'RuleVersion must strictly follow Semantic Versioning (e.g., 1.0.0). Invalid: ',
      );
    }
  }

  final String version;

  @override
  int compareTo(RuleVersion other) {
    if (version == other.version) return 0;
    final m1 = _regex.firstMatch(version)!;
    final m2 = _regex.firstMatch(other.version)!;

    for (int i = 1; i <= 3; i++) {
      final p1 = int.parse(m1.group(i)!);
      final p2 = int.parse(m2.group(i)!);
      if (p1 != p2) return p1.compareTo(p2);
    }

    final pre1 = m1.group(4);
    final pre2 = m2.group(4);
    if (pre1 == null && pre2 == null) return 0; // build metadata is ignored
    if (pre1 != null && pre2 == null) return -1;
    if (pre1 == null && pre2 != null) return 1;

    final parts1 = pre1!.split('.');
    final parts2 = pre2!.split('.');
    final len = parts1.length < parts2.length ? parts1.length : parts2.length;
    for (int i = 0; i < len; i++) {
      final part1 = parts1[i];
      final part2 = parts2[i];
      if (part1 == part2) continue;
      final num1 = int.tryParse(part1);
      final num2 = int.tryParse(part2);
      if (num1 != null && num2 != null) return num1.compareTo(num2);
      if (num1 != null && num2 == null) return -1;
      if (num1 == null && num2 != null) return 1;
      return part1.compareTo(part2);
    }
    return parts1.length.compareTo(parts2.length);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;

  String toJson() => version;
  factory RuleVersion.fromJson(String json) => RuleVersion(json);
  @override
  String toString() => version;
}
