class WuxingData {
  static const List<String> elements = ['木', '火', '土', '金', '水'];

  static const Map<String, String> generates = {
    '木': '火',
    '火': '土',
    '土': '金',
    '金': '水',
    '水': '木',
  };

  static const Map<String, String> controls = {
    '木': '土',
    '土': '水',
    '水': '火',
    '火': '金',
    '金': '木',
  };

  static String? getGeneratedBy(String element) {
    for (final entry in generates.entries) {
      if (entry.value == element) return entry.key;
    }
    return null;
  }

  static String? getControlledBy(String element) {
    for (final entry in controls.entries) {
      if (entry.value == element) return entry.key;
    }
    return null;
  }
}
