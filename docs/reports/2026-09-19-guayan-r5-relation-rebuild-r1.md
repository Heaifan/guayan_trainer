# GUAYAN-R5-RELATION-REBUILD-R1 完成报告

## A. 旧系统删除

- 删除审卦页旧 `relation_route_layout.dart`、`relation_route_path.dart`、`back_relation_glyph.dart`。
- 删除旧端点固定选择、左右固定绕线和旧大弧线路径依赖。
- 新 Router 仅生成圆角正交候选；所有候选非法时返回 `NoRoute`，不绘制。

## B. 保留与回归

- Domain Relation、EffectiveRelationSet、Evidence、备注和持久化链路未删除。
- 关系页的完整关系模型与视觉协议保留。
- 审卦筛选/统计仅暴露 `GENERATES`、`OVERCOMES`、`RETURN_GENERATES`、`RETURN_OVERCOMES`。

## C. Domain Algorithm Proof

- 五行相生：木→火、火→土、土→金、金→水、水→木通过。
- 五行相克：木→土、土→水、水→火、火→金、金→木通过。
- Golden Case：三爻土 → 六爻水：Candidate=`OVERCOMES`，Effective=`OVERCOMES`，Reason=`五行克制事实通过作用权结算`。
- 回生/回克只接受同位变爻 → 原动爻；无生克时不生成回头关系。

## D. Golden Route Proof

Source/Target 使用三爻与六爻真实 RenderBox Bounds 生成的 8 Anchor 集合；Router 按相对方向、障碍碰撞、长度、转弯和方向惩罚选择 HV/VH/H-V-H/V-H-V 候选。主卦、变卦、伏神、爻体、世应、X/O 以及已放置 Label 统一进入带 5dp 安全边距的 Hard ObstacleMap。缺少 Bounds 或无合法路线时不绘制。

## E. 四种关系

- 生：绿色圆角正交实线，标签“生”。
- 克：红色圆角正交实线，标签“克”。
- 回生：绿色 `ReturnRelationGlyph` 局部回钩，标签“回生”。
- 回克：红色 `ReturnRelationGlyph` 局部回钩，标签“回克”。

## F. 性能与确定性

- 每个 Node 提供 8 Anchor；Relation ID 稳定排序，重复计算输出一致。
- 缓存统计：首次计算 `calculationCount=1`；同一输入再次绘制命中缓存；选中关系只改变 opacity/stroke，不触发 route calculation。
- 定向渲染测试命令总耗时基线：约 4,495ms（含 Flutter 测试启动）；缓存内部已记录 `lastCalculationDuration` 供真机采样。
- Obstacle count 与 projected relation count 由 `RelationRenderPlan` 在每帧首次计划计算时记录。

## G. 验证

- `flutter analyze`：通过。
- 定向 Domain/Renderer/Cache/Review tests：通过。
- `git diff --check`：通过。
- Release APK：`build/app/outputs/flutter-apk/app-release.apk`，64.9MB，构建通过。

## H. Git

- Branch：`feat/guayan-2.0`
- Commit：见交付回复中的最终 `git log`。
- Remote/Ahead/Behind/Working Tree：见最终验证结果。

## I. 主要修改文件

- 新增：`relation_render_plan.dart`、`relation_geometry.dart`、`relation_obstacle_map.dart`、`relation_orthogonal_router.dart`、`relation_label_placer.dart`、`return_relation_glyph.dart`、`relation_route_cache.dart`、`relation_debug_painter.dart`及对应测试。
- 重建：`widgets/relation_overlay.dart`、审卦关系筛选/统计与挂盘 Bounds 注册。
- 删除：旧审卦 Router、路径和回头 Glyph 文件。
