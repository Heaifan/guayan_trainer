# GUAYAN Process Version Contract R1

## 1. 版本编码

Flutter 唯一源：`pubspec.yaml`。

```text
MAJOR.MINOR.PATCH+COUNTER
```

Android `versionCode = COUNTER`，Android `versionName = MAJOR.MINOR.PATCH.COUNTER`。

例如：`2.0.6+48` 在设备上显示 `2.0.6.48`。

## 2. 身份职责

- Product Version：`MAJOR.MINOR.PATCH`，表达产品阶段。
- Process Counter：`COUNTER`，表达真实开发迭代次数。
- Commit SHA：唯一历史定位。
- Acceptance Identity：`VisibleVersion@ShortSHA`。

Version 与 SHA 不得互相替代。

## 3. Version Event

以下事件必须 `COUNTER +1`：

- `FEATURE`：独立、可描述、可验收的新能力。
- `FIX`：已观察 Bug / Regression / Acceptance Failure 的一轮真实修复。
- `PERF`：形成正式可验证 Runtime/APK 的性能改进。

同一问题经历 FIX1/FIX2/FIX3，必须留下三次事件，禁止事后压缩。

## 4. 不计数事件

纯 `GOVERNANCE`、`DOCS`、不改变行为的内部整理默认不推进 Counter。

若所谓 refactor/governance 实际改变 Runtime、持久化、构建身份或用户行为，必须按 FEATURE/FIX/PERF 重新分类。

## 5. 产品版本推进

MAJOR/MINOR/PATCH 只在真实产品阶段或正式 Release 推进；Process Counter 不归零。

例如：`2.0.6+61 -> 2.0.7+62`。

## 6. 工具

禁止手算下一版本。使用：

```text
dart run tool/governance/version_audit.dart
dart run tool/governance/version_next.dart FIX
dart run tool/governance/version_selftest.dart
dart run tool/governance/version_metrics.dart
```

解析失败、未知事件类型或版本倒退必须 BLOCK。

## 7. 历史恢复

治理上线前历史为 `HISTORICAL PARTIAL`。只记录 Git、pubspec、CHANGELOG、Tag 或已有治理记录可以证明的事件，禁止补造。
