# 项目代码规则 — AI 自动遵守

## 一、规则优先级

根 `AGENTS.md` 是通用规则。任务书、Gate、durable state 已声明更严格约束时，更严格的局部规则优先。

- 普通纯逻辑 Dart：<= 150 行。
- 已声明 5+100 的 R5 / POST-R3 / Gate A 范围：继续 <= 100 行，且每目录直接文件 <= 5。
- `docs/governance/` 与 `tool/governance/`：按 5+100 自我约束。
- 禁止把局部 5+100 静默扩成全仓规则，也禁止用 150 行覆盖既有严格 Gate。

## 二、文件组织

文件夹使用具体功能名，禁止抽象名：factory、processor、handler、manager。
优先扁平结构；不要为了凑数建目录，也不要为减文件数硬合并不同职责。
Flutter Widget 不受通用 150 行限制，但仍禁止混合多模块职责。

## 三、架构分层

依赖方向：

`data/ <- models/ <- services/ <- pages/ + widgets/`

- data：数据表、常量、纯映射；不得依赖上层。
- models：类型与数据结构。
- services：业务逻辑、出题、存储；不得依赖 Widget。
- pages/widgets：页面与交互。

纯函数优先；副作用收敛到 store/service；返回结构化结果。

## 四、命名

- Dart 文件：snake_case.dart。
- 类/枚举：PascalCase。
- 函数/变量：camelCase。
- 常量：UPPER_SNAKE_CASE。

## 五、文档纪律

根 `file-tree.md` 必须随新增、删除、重命名、职责变化同步更新。
治理状态优先写入 `docs/governance/`；跨会话 durable state 写入 `memory/`。
禁止在多个文档维护互相冲突的同一条机器规则。

## 六、版本治理

Flutter 源版本唯一入口：

`pubspec.yaml -> MAJOR.MINOR.PATCH+COUNTER`

Android 安装后可见版本：

`MAJOR.MINOR.PATCH.COUNTER`

例如：`2.0.6+48 -> 2.0.6.48`。

每个独立 FEATURE、FIX、PERF 完成后，COUNTER 必须 +1。
连续 FIX1/FIX2/FIX3 必须真实留下三次计数，禁止事后压缩。
纯 GOVERNANCE/DOCS 默认不推进 Counter；若实际改变 Runtime/构建/数据行为，必须重新分类。
MAJOR/MINOR/PATCH 只在真实产品阶段或正式 Release 推进，Counter 不归零。

禁止手算下一版本。使用：

`dart run tool/governance/version_audit.dart`
`dart run tool/governance/version_next.dart FIX`

正式身份：`<VisibleVersion>@<ShortCommitSHA>`。
Tag 只用于正式产品 Release。

## 七、验证

按修改域执行相关 Gate，禁止用无关全量测试代替定向证据。
UI/关系绘制必须区分 AUTOMATED PASS 与 VISUAL PASS。
关键 Machine Gate 必须有负例；上游生成失败后，旧产物/SHA 不得继续作为 PASS。

正式验收必须绑定 Version + Commit + Branch + DirtyState。
Dirty=YES 不得宣布 FINAL ACCEPTED，除非任务明确只是 Probe。

## 八、Git 安全

精确 Stage。禁止：

- `git add .` / `git add -A`
- `reset --hard`
- `clean`
- `stash`
- force push
- 用 amend 隐藏真实治理/修复历史

来源不明修改、Foreign Dirty 必须保留并报告。

## 九、其它禁止事项

禁止循环依赖。
禁止在 Widget 中写复杂业务逻辑。
禁止 data 层依赖 Flutter。
禁止同文件混合多模块职责。
禁止为了得到 PASS 修改测试语义或隐藏失败。
