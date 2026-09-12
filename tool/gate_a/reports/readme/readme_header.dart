/// README 头（自 `gate_a_main.dart` 拆出；改这里才是真源）。
///
/// 本文件出「标题 + 状态 + Gate A-Truth 逐项」；「数据来源 / 文件说明 /
/// Compat 怎么用」在 `readme_sources.dart`，「已有结果 / 覆盖矩阵 /
/// 立春焦点 / 精度原则」在 `readme_checklist.dart`。
///
/// ⚠️ 三段是**按顺序拼接**的，拼接结果必须与拆分前的单块模板逐字节一致：
/// 任何一段的段首/段尾空行被改动，`gate-a/README.md` 的 SHA256 就会变。
library;

import '../../cases/derive.dart';
import '../../gate_a_context.dart';
import 'readme_checklist.dart';
import 'readme_sources.dart';
import '../status/gate_status.dart';
import '../status/gate_truth_items.dart';

String renderReadmeHeader(GateAContext ctx, List<CaseFacts> facts) =>
    '${_titleAndStatus()}${sourcesSection(ctx)}${checklistSection(facts)}';

String _titleAndStatus() =>
    '''# 卦眼 2.0 · Gate A 收口（真值 Gate + 兼容性 Gate）

> 本目录全部文件由 `tool/gate_a/gate_a_main.dart` 生成。
> **核心真值不来自专业软件**：由独立规则核验、官方历法双源与边界 Golden Test 承担。
> 专业软件对照是**独立观察项**，见 `Gate A-Compat`。

## 状态

```text
${r3FinalStatusBlock()}
```

### Gate A-Truth 逐项

| 验收域 | 结果 | 证据 |
| --- | --- | --- |
${truthItems.map((t) => '| ${t.domain} | **${t.result}** | ${t.evidence} |').join('\n')}

```text
Gate A-Truth  = R3 的 blocker（当前 PASS）
Gate A-Compat = $compatStatus，NON-BLOCKING
```

> Gate A-Compat 未执行的理由：$compatReason

''';
