# POST-R3-GOV-01 · 收口进度（durable state）

> 供跨会话续做。**每次改动后更新本文件。**

## 冻结规则（用户批准）

```text
产品代码 lib/ test/ assets/  → diff = 0
行为等价                  → gate-a 6 份文档 SHA256 before == after
R4                        → 禁止进入
禁止用 shell/文本手术搬 Dart 源码（只许 read/edit/write 或一次性 Dart 脚本）
禁止为减文件数而硬合并不同职责文件 → 用语义子目录
```

## 黄金快照

`memory/gate-a-golden-sha256.txt`（6 份文档，起始 HEAD ecea249）

## 每步 5 道门

```text
1. 该文件与新增文件全部 <= 100 行
2. 该目录（**直接子项**：文件 + 子目录） <= 5
3. gate_a_runner test PASS
4. 6 份文档 SHA256 == 黄金快照
5. git diff --check PASS
```

只读自检（两条）：
```text
dart run tool/gate_a/tools/checks/gov_selfcheck.dart   # 5+100 + SHA
dart run tool/gate_a/tools/checks/check_imports.dart    # 悬空相对 import
```

## 当前状态（本文件更新时）

```text
规则 1（<=100 行）  FAIL — 9 个文件超标
规则 2（目录 <=5）  PASS ✅
规则 3（SHA 等价）  PASS ✅
```

### 超标文件

```text
cases/derive.dart                    139
core/audit/hexagram_audit.dart       110
core/pillars/pillars.dart            120
reports/boundary_report.dart         125
reports/case_report.dart             110
reports/readme_header.dart           137
reports/solar_term_report.dart       221
tools/diag/oracle_residual.dart      113
tools/selftest.dart                  344
```

> ⚠️ 注意：reports/ 下几个文件是**旧版单文件内容**（拆分成果在恢复 ecea249
> 时丢失，只保留了目录搬迁）。因此 221 / 137 / 125 这些行数即旧值。

## 目录现状

```text
gate_a_main.dart / gate_a_context.dart / gate_a_runner.ps1   （根 3 项）
commands/   digest.dart, generate_reports.dart
cases/      derive.dart + data/(4) + logic/(1)
core/       audit/, formatting/, pillars/, time/(2)     （5 项）
reports/    boundary_report.dart, case_report.dart, day_report.dart,
            master_table.dart, readme_header.dart, readme_instructions.dart,
            solar_term_report.dart, status/(2)          （→ 待建子目录）
tools/      selftest.dart + checks/(5) + diag/(2)
data/       hko_source.dart, naoj_source.dart, fixtures/
astro/      5 文件
```

## 下一步

```text
S1  reports/ 建子目录（readme/ cases/ solar_term/ boundary/ status/），
    把 boundary_report / case_report / readme_header / solar_term_report
    按上次已验证的方案重新拆分（reports/ 直接子项降到 <=5）
S2  cases/derive.dart 139 → 拆出事实模型/锁定
S3  tools/selftest.dart 344 → tools/selftest/ 子目录（suite + 各类 checks）
S4  tools/diag/oracle_residual.dart 113 → 拆出 result 模型
S5  core/audit/hexagram_audit.dart 110、core/pillars/pillars.dart 120 → 各拆或在子目录内再分层
S6  全量回归 + gov_selfcheck 全 PASS + commit/push
```

## 教训（务必遵守）

```text
1. PowerShell `$x[1..0]` 会降序反转 → 静默复制而非删除。
2. .Replace(old, new) 若 new 含 old 子串 → 链式替换会把 String 吃成 ttring。
3. PowerShell 双引号会插值 $ 与反引号 → 源码改写必须走 Dart 脚本或编辑工具。
4. Windows 路径是反斜杠：任何自己写的路径解析必须先 replaceAll('\\','/')，
   且正则拆分目录要写 [/\\.]，否则 lastIndexOf('/') 返回 -1。
5. relOf(fromDir, toFile) 在 fromDir=='' 时必须过滤空段，否则多一个 `../`。
6. 重构脚本必须先写后删；删除条件要显式排除「值 == 键」的未移动文件。
7. 每次校验都要让生成器**完整跑完**（不要 Select-Object -First 截断管道），
   并检查真实 exit code。
```

## 状态

```text
POST-R3-GOV-01
IN PROGRESS — 规则 2 PASS，规则 1 尚余 9 个文件
```
