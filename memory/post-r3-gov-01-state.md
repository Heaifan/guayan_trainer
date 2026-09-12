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
2. 该目录（**直接文件**）<= 5
3. gate_a_runner test PASS
4. 6 份文档 SHA256 == 黄金快照（**必须先确认生成器 exit 0**）
5. git diff --check PASS
```

一条命令跑完整链（推荐）：

```text
powershell -File tool/gate_a/gate_a_runner.ps1 verify
  = imports → generate → gov → selftest → cross，任一步失败即停
```

只读自检（沿用旧命令，入口路径未变）：

```text
dart run tool/gate_a/tools/checks/gov_selfcheck.dart   # 规则 0 自证 + 5+100 + SHA
dart run tool/gate_a/tools/checks/check_imports.dart   # 悬空相对 import
```

---

## S0 独立核验结论（本轮最重要的产出）

**不要信自检器，先独立数一遍。** 用 PowerShell 逐级枚举（第二维度）
复核 `tool/gate_a/**` 后，确认 5 处「检查器给假结论」：

```text
1) gov_selfcheck 规则 2 数错口径
   旧代码：dir.listSync(recursive: true).whereType<File>().length  ← 数「后代文件」
   根目录：只数根下的文件，**完全漏掉** 7 个子目录
   实测：cases/ 1 个直接文件 + 2 个子目录（6 个后代）→ 被报成「6 个文件」
         reports/ 7 个直接文件 + status/（2 个）    → 数字被写成 9
   而 post-r3-gov-01-state.md 与提交 1541660 都写着「规则 2 PASS」→ **假 PASS**

2) gate_a_runner.ps1 8 个模式里 4 个路径失效（目录搬迁 1541660 未同步）
   tools/oracle_residual.dart · tools/precision_closeout.dart
   tools/enumerate_hexagrams.dart · tools/solve_cases.dart  → 全不存在
   后果：closeout / residual / enumerate / solve 根本跑不起来

3) check_imports.dart 盲点：`if (!target.startsWith('.')) continue;`
   → `import 'status/gate_status.dart'`（漏写 ../）被**静默跳过**：
     检查器报 OK，生成器随后编译失败（本轮真的撞上了）
   另：正则扫注释，把自己的示例注释当成 import 举报

4) 生成器失败时 SHA 比对**无意义**：旧文档仍在盘上 → 规则 3 显示 PASS
   本轮实测：GEN_EXIT=254 时 6/6 仍报 OK（空洞证据）

5) 黄金快照对行尾敏感：core.autocrlf=true 且无 .gitattributes
   → checkout 把 gate-a/*.md 的 LF 还原成 CRLF
     实测 checkout SHA 0485795… ≠ 黄金 062AD56…（内容一字未改）
```

### 修复（全部已落盘）

```text
tools/gov/dir_scan.dart          规则 2：直接文件计数（非递归）+ 证据表
tools/gov/line_scan.dart         规则 1：Dart 文件行数
tools/gov/doc_scan.dart          规则 3：SHA 快照（缺快照不得当 PASS）
tools/gov/rules_regression.dart  规则 0：临时夹具自证计数口径（先自证再查仓库）
tools/gov/gov_rules.dart         编排 + 逐目录证据打印 + MAX DIRECT FILES
tools/checks/gov_selfcheck.dart  改为薄入口
gate_a_runner.ps1                $Scripts 路径表 + 缺文件即失败 + verify 链
tools/checks/check_imports.dart  只跳过 package:/dart:；注释不误报
.gitattributes                   gate-a/*.md text eol=lf
```

### 规则 2 口径（**已冻结，勿再改**）

```text
每个目录的**直接文件数** <= 5。子目录不计入父目录预算。
理由：子目录正是本规则要求的修复动作；若子目录也占预算，
      7 个语义模块目录永远无法满足，且与「禁止硬合并职责」自相矛盾。
tool/gate_a 根目录 = 3 文件 + 7 子目录（files=3 判 PASS，subdirs 单独打印为透明度）。
该口径由 rules_regression.dart 的夹具断言（含「wide 直接 4 / 后代 24 不得判超限」）。
```

---

## 当前状态（本轮已完成）

```text
规则 0（规则实现自证）   PASS
规则 1（<=100 行）      PASS — 63 个 Dart 文件，0 个超标
规则 2（直接文件 <=5）   PASS — 25 个目录，MAX = 5
规则 3（SHA 等价）      PASS — 6/6 IDENTICAL
独立目录审计            PASS — MAX DIRECT FILES = 5，0 个目录超 5
lib/ test/ assets/ diff 0
```

9 个超限文件全部拆完（去向见 `file-tree.md` 的 POST-R3-GOV-01 一节）。

---

## 教训（务必遵守）

```text
1. PowerShell `$x[1..0]` 会降序反转 → 静默复制而非删除。
2. .Replace(old, new) 若 new 含 old 子串 → 链式替换会把 String 吃成 ttring。
3. PowerShell 双引号会插值 $ 与反引号 → 源码改写必须走 Dart 脚本或编辑工具。
4. Windows 路径是反斜杠：任何自写路径解析先 replaceAll('\\','/')，
   且正则拆分目录要写 [/\\.]，否则 lastIndexOf('/') 返回 -1。
5. relOf(fromDir, toFile) 在 fromDir=='' 时必须过滤空段，否则多一个 `../`。
6. 重构脚本必须先写后删；删除条件要显式排除「值 == 键」的未移动文件。
7. 每次校验都要让生成器**完整跑完**（不要 Select-Object -First 截断管道），
   并检查真实 exit code。
8. ★ PowerShell 的 Get-Content **不加 -Encoding UTF8** 会按 GBK 解码，
   UTF-8 中文文件行数会被数错（本轮实测 99 vs 真实 111）。
   量行数必须 `-Encoding UTF8`，或以 Dart 的 readAsLinesSync 为准。
9. ★ 生成器 exit != 0 时，任何 SHA/等价性结论都**不算数** —— 旧文件还在盘上。
   verify 链已把这条固化为「generate 失败即终止」。
10. ★ dart format（SDK 3.11）会重排老风格代码：**只 format 本步改动过的文件**，
    对目录跑 format 会污染无关文件（本轮误伤 3 个，已逐文件还原）。
11. ★ 删 import 前先确认它是否提供了隐式用到的类型：
    `line_state.dart` 看着没用，其实是 `MovementType` 的来源。
12. ★★ 沙箱受限模式下**子进程 stdio 一律被拒**（命名管道 / 句柄继承），
    而 `dart analyze`（analysis_server）与 `flutter test`（frontend_server）
    都必须 spawn 带 stdio 的子进程。dart:io 探针实测：
      Process.start（默认管道）    → FAIL ProcessException 拒绝访问 process_win.cc:742
      ProcessStartMode.inheritStdio → FAIL process_win.cc:748
      ProcessStartMode.detached     → OK
    表现极具误导性：`dart analyze` 报 `CreateFile failed 5`；
    `flutter test` 则**零输出、零进程**，看起来像「卡住 / 编译慢」。
    → 再遇到「分析/测试工具莫名不动」，先跑这个探针（8 行），
      不要靠重试和干等（本轮白等约 15 分钟）。
    → danger-full-access 下两者都正常：flutter test 259/259（约 10 秒）。
13. ★ 不要用 `.bat` + `*>` 重定向判断「有没有输出」：本轮 flutter.bat
    在重定向下产出 0 字节日志，换成 `| Tee-Object -FilePath` 才看到实时进展。
```

## 下一步

```text
本轮 POST-R3-GOV-01 已收口 → 可进入 R4（需用户明确批准）。
R4 前建议：把 .gitattributes 的行尾锁定策略推广到 tool/ 与 lib/（需单独一轮，
否则一次性重排会淹没真实 diff）。
```
