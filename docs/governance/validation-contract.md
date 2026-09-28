# GUAYAN Validation Contract R1

## 1. 正式验收身份

正式验收必须输出：

```text
Version: <visible version>
Source: <pubspec version>
Commit: <full sha>
Branch: <branch>
Dirty: NO
Identity: <visible>@<short sha>
```

Dirty Build 仅允许 Runtime/Debug/Visual Probe，不得宣布 FINAL ACCEPTED。

## 2. 分域验证

### Domain / Rules / DSL

执行 `flutter analyze`、相关定向测试；涉及 DSL/AST 必须补 round-trip 与 engine integration。

### Review / Relation / UI

执行静态检查、相关 Widget/Review 测试、APK 构建，并保留真实视觉验收。自动测试 PASS 不等于视觉 PASS。

### Case / Persistence

必须覆盖保存、回读、删除/恢复及旧数据兼容，不能只测内存对象。

### Performance

必须同时证明性能变化和行为不退化，禁止以主观“感觉更快”作为 PASS。

## 3. False PASS 防护

Machine Gate 本身也需要被验证：

- 关键 Gate 至少保留一个故意失败负例。
- 必须检查真实 exit code。
- 上游生成失败后，下游旧产物/SHA 不得继续作为 PASS 证据。
- 自检器结论与独立证据冲突时，以冲突为 BLOCK，不允许自动报喜。

## 4. 规则优先级

根 `AGENTS.md` 为通用约束；任务、Gate、durable state 中更严格的局部规则优先。

当前明确保留：POST-R3 / Gate A 的 5+100 与 Golden SHA 契约；R5 已声明 5+100 的任务范围继续沿用。其它普通纯逻辑 Dart 仍按根规则 150 行上限，直到单独迁移。

## 5. Git 收口

精确 Stage；禁止 `git add .`、`git add -A`、`reset --hard`、`clean`、`stash`、`force push`。来源不明修改与 Foreign Dirty 必须保留并报告。
