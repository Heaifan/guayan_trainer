# Gate B 人工核对报告

本目录包含 R4-GATE-B-RELATION-TRUTH 的验收用例与运行结果。

## 目录
- `01-gb-01.md`: GB-01 单动爻综合案例
- `02-gb-02.md`: GB-02 多动爻 / 回头关系案例
- `03-gb-03.md`: GB-03 静爻事实账本案例
- `04-master-table.md`: 九类结果核对表

可以通过在项目根目录运行以下命令生成和校验：

```bash
dart run test/domain/gate_b/gate_b_runner.dart
```

所有案例独立定义和推演了关系真值 (Golden cases)，不依赖 `RelationCalculator` 的生产实现作为预言机。在 `gate_b_runner.dart` 中使用 `expectedTruth` 完成了这部分逻辑。
同时，也执行了以下回归校验：
- **缺失输入专项**：验证历法和 `changedBranch` 缺失时不会误报，并包含正确的 Diagnostic Missing Inputs。
- **确定性与排序**：相同输入得出相等的生成顺序，不因重算漂移。
- **序列化兼容**：端点的 JSON round trip 保证不破坏 Canonical ID 稳定。
- **无重复 RelationKey**：同一卦例不生成两条冲突 key 记录。
