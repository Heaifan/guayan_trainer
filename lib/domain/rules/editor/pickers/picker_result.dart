library;

class PickerResult {
  const PickerResult({
    required this.value,
    required this.displayText,
    this.metadata = const {},
  });

  final String value;
  final String displayText;
  final Map<String, Object?> metadata;
}
