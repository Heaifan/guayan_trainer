# GUAYAN-R5-RELATION-REBUILD-R1 Design

## Goal

彻底替换审卦页旧 Relation Visualization，立即交付一个可用的生克基础绘制系统：审卦页只绘制生、克、回生、回克；Domain 关系算法、EffectiveRelationSet、关系页、Evidence、备注与持久化保持不变。

## Scope and invariants

- Renderer 只消费 `GENERATES / OVERCOMES / RETURN_GENERATES / RETURN_OVERCOMES` 对应的 `RelationType.sheng / ke / huiTouSheng / huiTouKe`。
- 飞伏、合、冲、月日、动变等关系仍保留在 Domain 与关系页，但不进入审卦 Renderer，也不计入审卦页关系统计。
- 回生/回克只接受同位变爻 → 同位原动爻；没有五行生克时不生成回钩。
- 审卦 UI 不判断五行，数据链固定为 Domain Facts → Candidate Relations → Resolution → EffectiveRelationSet → 四类过滤 → Renderer。
- 关系页保持原有数据投影、筛选、详情、Evidence、备注与持久化行为。

## Architecture

审卦关系层分为四个纯逻辑单元和一个 Flutter 接入层：

1. `review_relation_projection.dart`：从有效关系生成四类审卦绘制模型与统计，不重新计算 Domain。
2. `relation_geometry.dart`：定义 Node Bounds、8 Anchors、Obstacle Bounds、Safe Padding 与路线几何值对象。
3. `relation_obstacle_map.dart`：接受 Layout 完成后的真实 RenderBox Bounds，统一 inflate Safe Padding，并提供碰撞测试。
4. `relation_orthogonal_router.dart`：按 Anchor Pair 生成 HV/VH/H-V-H/V-H-V 候选，使用圆角正交段和成本函数选择合法短路线；不包含 Bezier。
5. `relation_overlay.dart`：在 Layout 后收集 Bounds，构建/读取 RouteCache，绘制普通关系、Label、箭头与 ReturnRelationGlyph；点击只改变 repaint 状态。

## Geometry and routing contract

- 每个可连接 Node 暴露 NW/N/NE/W/E/SW/S/SE 八个虚拟 Anchor，坐标由真实 Bounds 推导。
- AnchorPair 先按相对方向筛选，再由距离、障碍、转弯数、绕行距离共同评分；左右绕行不写死。
- 所有挂盘可见元素（伏神、主卦、变卦文本，六爻符号，世应、X/O、纳音和已放置关系 Label）都是 Hard Obstacle。
- `safePadding` 集中为 Token，初值 5dp；碰撞使用 `bounds.inflate(safePadding)`。
- 路径成本为 `length + bends * bendPenalty + crossings * crossingPenalty + detourPenalty + anchorDirectionPenalty`，合法性优先于成本。
- 普通路径使用 2dp 左右实线、约 9dp 箭头和圆角转弯；生绿色，克红色。
- 回生/回克使用局部 ReturnRelationGlyph，不进入普通长距离 Router，Label 统一为“回生”“回克”。
- Label 候选在合法 Segment 附近生成，必须通过障碍和已放置 Label 碰撞测试，放置后成为 Hard Obstacle。

## Cache and invalidation

`RelationRouteCache` keyed by layout fingerprint, effective relation fingerprint, viewport size, font/layout state and visibility state. Bounds、EffectiveRelationSet、屏幕尺寸、字体尺寸或伏神/元素显示状态改变时 invalidate；普通 repaint 和 selection 不重新 Route。

## Debug mode

Debug flag shows Node Bounds、8 Anchors、Obstacle Bounds、Safe Padding、Selected Anchors、Route Segments、Label Bounds；正常模式隐藏所有调试图层。

## Testing and delivery gates

- Domain tests cover five generates pairs, five overcome pairs, 三爻土 → 六爻水 Golden Case 的 Candidate/Effective/Reason、回生、回克和无回头关系。
- Geometry tests cover eight anchors, relative direction, real Bounds, safe padding and hard obstacle collision.
- Router tests cover the Golden Case, no Bezier/C/U path, short legal route and both-side selection.
- Return glyph tests cover local mirrored hooks and obstacle avoidance.
- Cache tests prove repaint and selection do not route again while Bounds changes do.
- Regression gates: `flutter analyze`, targeted tests, full `flutter test`, `git diff --check`, release APK build.
- Update `file-tree.md` with new/deleted files, responsibilities and current edit time.

## Explicit non-goals

本轮不接入飞伏、冲合、月日、动变等新绘制类型；不修改关系页；不恢复或兼容旧 Bézier Router；不使用固定汉字宽度估算 Bounds。
