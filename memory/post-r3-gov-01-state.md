# POST-R3-GOV-01 · 收口进度（durable state）

> 供跨会话续做。**每次改动后更新本文件。**

## 冻结规则（用户批准）

```text
产品代码 lib/ test/ assets/  → diff = 0
行为等价                  → gate-a 6 份文档 SHA256 before == after
R4                        → 禁止进入
禁止用 PowerShell 文本手术搬 Dart 源码（只许用编辑工具按职责改）
禁止为减文件数而硬合并不同职责文件 → 用语义子目录
```

## 黄金快照

`memory/gate-a-golden-sha256.txt`（6 份文档，起始 HEAD 的 ecea249）

## 每步 5 道门

```text
1. 该文件与新增文件全部 <= 100 行
2. 该目录（递归） <= 5 文件
3. gate_a_runner test PASS
4. 6 份文档 SHA256 == 黄金快照
5. git diff --check PASS
```

只读自检：`dart run tool/gate_a/tools/gov_selfcheck.dart`

## ⚠️ 本轮踩过的坑（务必遵守）

1. `$x[1..0]` 在 PowerShell 会**降序反转**区间 → 会静默复制而非删除。
2. `.Replace('String _x(', 'String renderX(')` 这类
   **replacement 含 old substring** 的调用链会把 `String` 吃成 `ttring`。
   → 结论：**不要用 PowerShell 做源码改写**，只用 read/edit/write。
3. `Select-Object -First N` 提前截断管道会让 `$LASTEXITCODE` 看起来正常
   → 校验必须让生成器**完整跑完**（`> $null 2>&1` 后看真实 exit code）。
4. PowerShell 写文件时 `@"..."@` 会插值 `${...}`，且反复往返易引入重复 import
   → 写完必须检查重复 import 与 `ttring` 式损坏。

## 当前违规（gov_selfcheck 实测，ecea249 + 重命名）

### 规则 1 · >100 行

```text
cases/derive.dart                139
core/hexagram_audit.dart         110
core/pillars.dart                120
gate_a_main.dart                 322
reports/boundary_report.dart     124
reports/case_report.dart         110
reports/readme_header.dart       137
reports/solar_term_report.dart   221
tools/oracle_residual.dart       113
tools/selftest.dart              344
```

### 规则 2 · 目录 >5 文件

```text
cases     6
core      8
reports   6
tools     6
```

## 已就绪的重命名（已完成，勿重复）

```text
reports/readme_header.dart   _instructions      → renderInstructions        ✅
reports/master_table.dart    _masterTable       → renderMasterTable         ✅
reports/boundary_report.dart _solarTermSection  → renderSolarTermSection     ✅
```

> 但 `gate_a_main.dart` 内的**调用点尚未改名**（当前仍写 `_instructions()` /
> `_masterTable` / `_solarTermSection`），所以现在编译依赖旧名 —— 下一步必须
> 同步改调用点，否则会 break。**先做这一步再拆 main。**

## 下一步（严格顺序）

```text
S1 改 gate_a_main.dart 调用点：renderInstructions / renderMasterTable /
   renderSolarTermSection（用 edit 工具，逐处）
S2 拆 gate_a_main.dart 322 → 编排 + commands/
     - commands/generate_reports.dart（把 6 个 _write 与 _title 搬出）
     - commands/digest.dart（_consoleDigest + 案例锁定输出 + 尾部状态）
     main 只留：装载 ctx、结构自检、调用 generate、调用 digest
S3 tools/selftest.dart 344 → tools/selftest/{selftest_suite,source_checks,
   calendar_checks,hexagram_checks}.dart（tools/ 已有 6 文件，需先减到 5 或建子目录）
S4 reports/solar_term_report.dart 221 → reports/solar_term/{boundary,precision,source}
S5 reports/boundary_report.dart 124 → reports/boundary/{points,criteria}
S6 reports/case_report.dart 110 → reports/cases/{lines,summary}
S7 reports/readme_header.dart 137 → reports/readme/{header,sections}
S8 cases/derive.dart 139 → 拆出 hexagram_facts；cases/ 6→≤5
S9 tools/oracle_residual.dart 113 → 拆出 result/format 模型
S10 core/ 8→≤5：建 formatting/ time/ 等语义子目录（不硬合并）
S11 全量回归 + gov_selfcheck 全 PASS + commit/push
```

## 状态

```text
POST-R3-GOV-01
IN PROGRESS — 未收口
HEAD = ecea249（已推送，工作树干净）
```
