/// 卦侧：本卦（original）与变卦（changed）。
///
/// 这是**领域**概念（不是屏幕位置），因此独立成文件：
/// 关系端点（`relation_endpoint.dart`）与绘线定位（`line_endpoint.dart`）
/// 都从这一处取用，禁止各自重复定义。
library;

enum LineScope {
  original('original'),
  changed('changed');

  const LineScope(this.machineName);

  /// 稳定机器名，参与 canonical 序列化，禁止翻译成中文标题。
  final String machineName;
}
