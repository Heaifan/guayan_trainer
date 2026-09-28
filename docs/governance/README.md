# 卦眼开发治理

本目录只补齐卦眼现有治理体系的缺口，不复制 XYE 的治理组织。

## 权威入口

- 版本过程：`process-version.md`
- 验收契约：`validation-contract.md`
- 版本事件账本：`version-events.tsv`
- 可执行工具：`tool/governance/`
- 历史 Gate：`gate-a/`、`gate-b/`、`tool/gate_a/`
- Durable state：`memory/`

## 核心身份

Flutter 源版本保持合法格式：`MAJOR.MINOR.PATCH+COUNTER`。
Android 安装后显示：`MAJOR.MINOR.PATCH.COUNTER`。

例如：

- Source：`2.0.6+48`
- Visible：`2.0.6.48`
- Historical identity：`2.0.6.48@<commit>`

`COUNTER` 是连续开发过程计数器。FEATURE、FIX、PERF 每形成一个独立可验证结果均 +1；纯 GOVERNANCE/DOCS 默认不推进。

## 规则优先级

根 `AGENTS.md` 是通用规则。若某个任务、Gate 或 durable state 已明确声明更严格约束，则更严格的局部规则优先。

因此不存在“150 行”和“5+100”二选一：通用纯逻辑文件上限仍为 150 行；R5、POST-R3、Gate A 等已声明 5+100 的作用域继续执行 5+100。本目录和 `tool/governance/` 也按 5+100 自我约束。

## 历史数据

本治理上线前的事件无法全部可靠恢复，统一标记 `HISTORICAL PARTIAL`。禁止根据提交数量反推或伪造历史版本事件。
