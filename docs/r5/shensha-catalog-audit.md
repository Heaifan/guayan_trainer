# R5 神煞 Catalog 审计

审计日期：2026-09-17 23:09
审计范围：`lib/`、`test/`、`docs/`、`assets/`

## 结论

用户已确认 `shensha.standard.v1`：月支取 CalendarSnapshot 的节气月建，结果在排卦生成时计算并持久化，审卦页只读快照；禁止 Demo/Profile 作为 Runtime fallback。16 项日/月/干支神煞已按 Golden A 验证，卦身采用 `classic_yue_gua_shen.v1`，香闺与床帐由卦身五行派生。

## Catalog 审计表

| ID | 中文名 | 是否已有算法 | 取法基准 | 输入 | 输出 | 现有来源 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| shensha.gua_shen | 卦身 | 是 | 世爻位置/阴阳 | 世爻位与阴阳 | 地支 | `shensha_engine.dart` | VERIFIED |
| shensha.xiang_gui | 香闺 | 是 | 卦身五行所克 | 卦身 | 地支 | `shensha_engine.dart` | VERIFIED |
| shensha.chuang_zhang | 床帐 | 是 | 卦身五行所生 | 卦身 | 地支 | `shensha_engine.dart` | VERIFIED |
| shensha.yi_ma | 驿马 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.tao_hua | 桃花 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.hua_gai | 华盖 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.gui_ren | 贵人 | 是 | 日干 | 日干 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.tian_lu | 天禄 | 是 | 日干 | 日干 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.tian_xi | 天喜 | 是 | 月支 | 节气月建 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.tian_yi | 天医 | 是 | 月支退一位 | 节气月建 | 地支 | `shensha_engine.dart` | VERIFIED |
| shensha.wen_chang | 文昌 | 是 | 日干 | 日干 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.jie_sha | 劫煞 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.zai_sha | 灾煞 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.jin_yu | 金舆 | 是 | 日干 | 日干 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.wang_shen | 亡神 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.jiang_xing | 将星 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.yang_ren | 羊刃 | 是 | 日干 | 日干 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.mou_xing | 谋星 | 是 | 日支三合局 | 日支三合局 | 地支 | `shensha_tables.dart` | VERIFIED |
| shensha.wang_wang | 往亡 | 是 | 月支 | 节气月建 | 地支 | `shensha_tables.dart` | VERIFIED |

## 已确认的现有接线

- `CalendarSnapshot.shenShaResults` 保存生成时结果，`ReviewCaseAdapter` 只做结构投影。
- `ReviewTraditionalProfile` 仍仅供既有视觉/兼容测试使用。
- 规则中心的 `shensha` 是标签类别/语义校验，不是神煞公式库。

## 验证记录

- Golden A：丙午 丁酉 癸巳 壬戌，确认 16 项日/月/干支神煞输出。
- Golden B：世爻四爻、阴，确认卦身酉、香闺寅卯、床帐子亥及多支顺序。
- 变体：卦身使用 `classic_yue_gua_shen.v1`；现代资料差异保留为后续显式变体，不在 Runtime 猜测。
