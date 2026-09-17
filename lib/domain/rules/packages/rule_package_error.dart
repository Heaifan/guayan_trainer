class RulePackageIssue {
  const RulePackageIssue(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class RulePackageFormatException implements Exception {
  const RulePackageFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RulePackageVersionException implements Exception {
  const RulePackageVersionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RulePackageValidationResult {
  const RulePackageValidationResult(this.errors);

  final List<RulePackageIssue> errors;

  bool get isValid => errors.isEmpty;
}
