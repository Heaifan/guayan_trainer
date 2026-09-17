library;

/// 将稳定规则值映射为用户可读的取象文本。
///
/// 映射只影响展示，不改变 AST、Action 或 canonical ID。
class RuleMappingTable {
  const RuleMappingTable._();

  static const Map<String, String> _values = {
    'sanHe.木': '繁荣、生长、条达',
    'sanHe.火': '光明、热烈、显达',
    'sanHe.金': '收敛、决断、肃杀',
    'sanHe.水': '流动、智慧、润下',
    'element.木': '生长、条达',
    'element.火': '光明、热烈',
    'element.土': '承载、稳定',
    'element.金': '收敛、决断',
    'element.水': '流动、润下',
  };

  static String? imageFor(String stableValue) => _values[stableValue];

  static Map<String, String> get all => Map.unmodifiable(_values);
}
