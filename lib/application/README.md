# application/（预留）

卦眼 2.0 应用层（用例/交互编排）属于后续阶段，本阶段不实现。

Foundation 阶段遵循「能简单就不要复杂」：仅 AppShell 使用 StatefulWidget
持有 selectedIndex 单一状态源，不引入 Riverpod/Bloc 等状态管理框架。
是否采用统一状态管理，等出现真正业务状态时再决定。
