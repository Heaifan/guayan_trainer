library;

import 'binding_selector.dart';

/// 变量绑定，声明在规则上下文中引用的六爻对象。
class RuleBinding {
  const RuleBinding({
    required this.name,
    required this.selector,
  });

  /// 绑定名，如 "A", "B", "M", "D"
  final String name;

  /// 选择器，如 direct, relative
  final BindingSelector selector;
}
