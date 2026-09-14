library;

/// 选择器基类。支持 direct 和 relative 两类。
abstract class BindingSelector {
  const BindingSelector();
}

class DirectSelector extends BindingSelector {
  const DirectSelector(this.target);
  
  /// SemanticRef 的字符串表达或其它标志
  final String target;
}

class RelativeSelector extends BindingSelector {
  const RelativeSelector({
    required this.baseBinding,
    required this.path,
  });
  
  /// 基于哪个 binding 的名字
  final String baseBinding;
  
  /// 关系路径，例如 "changedLine"
  final String path;
}
