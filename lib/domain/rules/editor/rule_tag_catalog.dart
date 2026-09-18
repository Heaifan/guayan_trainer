/// Stable action tag IDs and their user-facing labels.
class RuleTagCatalog {
  const RuleTagCatalog._();

  static const _labels = {
    'road': '道路',
    'road_clash_home': '有路冲家',
    'career': '事业',
    'relationship': '感情',
  };

  static String display(String tagId) => _labels[tagId] ?? tagId;
}
