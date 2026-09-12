/// 每份 GA 文档顶部的**使用说明**（自 `readme_header.dart` 拆出的独立区块）。
///
/// 说明的是 Gate A-Compat 的填写方式；未填写记 `NOT EXECUTED`，不是 FAIL。
library;

/// 文档顶部的使用说明文本。
String renderInstructions() =>
    '''> **使用方式（Gate A-Compat 专用，可选）**：把表中「专业软件」列留空的位置，
> 用专业排盘软件按给出的「起卦时间 + 六爻输入」排出结果后逐项填入（或截图回传）。
> 未填写时该表 Result 记为 `NOT EXECUTED`，**不是** FAIL。
>
> **注意**：Gate A-Compat **不阻塞 R3**。核心业务真值由 Gate A-Truth 承担，
> 其证据来自独立规则核验与官方历法双源，不依赖任何专业软件。
>
> 时区统一 **+08:00**；六爻输入自**初爻至上爻**，7=少阳 8=少阴 9=老阳 6=老阴。

''';
