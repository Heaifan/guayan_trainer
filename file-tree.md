# 项目文件树 — 卦眼训练器

> **当前版本：** v0.1.5
> **创建时间：** 2026-05-15
> **最后编辑：** 2026-05-16 11:30

> 本文件用于记录项目目录结构、模块职责与版本演进。  
> 每次 AI 或人工修改代码后，如涉及新增、删除、重命名文件，必须同步更新本文档。

---

## 当前版本更新日志 — v0.1.5

> 发布日期：2026-05-16 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.5)

### 新增
- **五行相克学习页**：正式替代「即将开放」占位页，包含说明卡、五角星相克轮盘、五个 HTML 特效、中央标题、五条相克解释、断卦提示
- **五条相克 HTML 特效接入**：木克土（木根破土）、土克水（土堤束水）、水克火（水幕压火）、火克金（烈火熔金）、金克木（金刃断木）
- **WuxingControlWheel**：累计箭头动画 + 五槽位特效 + 中央标题，节奏同相生（箭头 3500ms + 暂停 1400ms）
- **WuxingControlArrowPainter**：朱砂红（#9C3B2E）五角星直线箭头，区别于相生的绿墨圆弧

### 修复
- **wrongCount 累加**：同一道错题重复答错不再重置为 1，改为 `old.wrongCount + 1`，`createdAt` 保留首次时间
- **回炉结果弹窗**：重做全部完成后弹出结果对话框，显示「已掌握 / 仍需回炉」数量
- **回炉阶段中文名**：错题卡片显示来源阶段（轮盘题/彩色单选/无色单选）

### 新增文件
- `lib/widgets/wuxing_control_painter.dart` — 相克五角星 CustomPainter

---

> 发布日期：2026-05-16

### 新增
- **错题持久化存储**：`MistakeStore` 改用 `SharedPreferences` 存储，关闭 App 后错题仍然存在
- **五行相生练习答错自动收录**：答错时写入包含题目、错误答案、正确答案、关系、题型阶段、错误次数的完整记录
- **回炉页错题列表**：显示每道错题的题目、错误答案、正确答案、关系、错误次数
- **单题重做**：每张错题卡有「重做」按钮，答对移出错题库，答错保留
- **重做全部错题**：顶部按钮连续重做所有错题，统一无色单选（方案 B）
- **首页回炉提醒**：显示最近 3 道错题概览
- **`MistakeItem` 模型**：`lib/models/mistake_item.dart`

### 新增文件
- `lib/models/mistake_item.dart` — 错题数据模型
- `lib/pages/review/review_training_page.dart` — 回炉练习页

### 修改文件
- `lib/services/mistake_store.dart` — 重写为持久化存储
- `lib/pages/practice/training_page.dart` — 答错写入错题库
- `lib/pages/review/review_page.dart` — 错题列表+重做入口
- `lib/pages/home/home_page.dart` — 适配新 MistakeStore API
- `lib/pages/practice/practice_page.dart` — 适配新 API
- `lib/main.dart` — 启动时预加载错题库

---

## 前版更新日志 — v0.1.4

> 发布日期：2026-05-16

### 新增
- **五行相生练习三阶段题型**：学习→五行相生进入练习后，12 题自动进阶
  - 第 1~4 题：**轮盘题** — 在五行轮盘上点击答案，配合箭头+动画
  - 第 5~8 题：**彩色单选** — 五张五行彩色选项卡，保留颜色辅助
  - 第 9~12 题：**无色单选** — 去掉颜色提示，纯文字卡练反射
- **阶段标签显示**：进度条旁显示当前阶段名（阶段一·轮盘题/阶段二·彩色单选/阶段三·无色单选）

---

## 前版更新日志 — v0.1.3.13

> 发布日期：2026-05-16

### 优化
- **箭头节奏对齐特效 5s 循环**：箭头 3500ms + 暂停 1400ms = 每边 4900ms ≈ 5s，与特效动画完全同步
- **整轮 25 秒封顶**：5 边 × 4900ms + 收尾 500ms = 25000ms，实际约 25s 完成一轮

---

## 前版更新日志 — v0.1.3.12

> 发布日期：2026-05-16

### 优化
- **箭头动画放慢至 1800ms**：比之前 1200ms 再慢 50%，每条相生关系更清晰可辨
- **火生土替换为纯 CSS 版**：删除旧版 JS 定时器方案，改用 CSS 关键帧驱动，viewBox 统一为 `0 0 200 200`，解决显示不完整问题

---

## 前版更新日志 — v0.1.3.11

> 发布日期：2026-05-16

### 新增
- **土生金 HTML 动画**：`earth_metal_html.dart` — 土层拱起→金石破土→光晕闪烁→土粒滑落
- **金生水 HTML 动画**：`metal_water_html.dart` — 金石呼吸→寒风拂过→水珠凝结→滴落涟漪
- **水生木 HTML 动画**：`water_wood_html.dart` — 春雨淅沥→原木润泽→发芽抽条→树冠繁茂
- **HtmlRelationEffect 全关系支持**：`_htmlFor()` 覆盖全部 5 条相生

### 修复
- **轮盘节奏还原为慢速**：箭头 1200ms + 暂停 650ms + 整轮停留 1400ms

---

> 发布日期：2026-05-16

### 优化
- **轮盘节奏加速**：箭头动画 1200ms→700ms，边间暂停 650ms→200ms，整轮停留 1400ms→500ms，一轮总时长 5 秒整

---

> 发布日期：2026-05-16

### 变更
- **木生火动画替换为钻木取火版**：`wood_fire_html.dart` — 竖直木钻杆高速旋转 → 接触点摩擦蓄热 → 烟雾缓慢飘升 → 少量火星慢速漂移 → 火苗柔和生长，5 秒循环

---

## 前版更新日志 — v0.1.3.8

> 发布日期：2026-05-16

### 新增
- **火生土 HTML 动画**：`fire_earth_html.dart` — 火苗燃烧→灰烬落下→灰堆长高掩埋火苗→循环，接入火土槽位
- **HtmlRelationEffect 多关系支持**：`_htmlFor()` 方法根据 `from`/`to` 返回对应 HTML（木火/火土），不再硬编码只支持木生火
- **GenerateRelationEffectsLayer 泛化**：对所有 `visibleEdges` 统一创建 `HtmlRelationEffect`，由组件内部判断是否有对应 HTML

### 优化
- **火生土性能**：灰烬粒子生成从 25ms→55ms，粒子大小 `2.5+1`→`2+0.8`，手机端更流畅

---

## 前版更新日志 — v0.1.3.7

> 发布日期：2026-05-16

### 优化
- **动画节奏放慢**：箭头动画 650ms→1200ms，边间暂停 350ms→650ms，整轮结束停留 1000ms→1400ms，更适合学习节奏
- **标题延迟出现**：`activeProgress >= 0.18` 后才显示标题，避免"文字抢跑"
- **标题改用 activeEdge**：不再从 `_activeEdgeIndex` 读取下一条，只跟随当前正在播放的边
- **标题位置下移**：`size * 0.42`→`0.46`，避免遮挡动画槽位
- **木火槽位内移**：`Offset(0.68, 0.28)`→`(0.60, 0.34)`，不再贴近火节点和箭头末端

---

## 前版更新日志 — v0.1.3.6

> 发布日期：2026-05-16

### 重构
- **中央单动画→五固定槽位**：移除中央 `HtmlRelationEffect` 单层动画，改为 `GenerateRelationEffectsLayer` 五槽位架构
- **新增中央关系标题**：`AnimatedOpacity` 显示当前播放中的相生关系名（如「木生火」「火生土」），动画结束时淡出
- **累计保留逻辑**：每条关系完成后，动画在对应槽位循环保留；到整轮结束再一起清空

### 新增
- **`GenerateRelationEffectsLayer`**：`lib/widgets/effects/generate_relation_effects_layer.dart` — 5 个固定坐标槽位，根据 `visibleEdges` 列表渲染对应的关系动画
- **槽位预留**：木生火槽位接入 `HtmlRelationEffect`（现有 HTML 动画），其余火土、土金、金水、水生木四个槽位预留占位

### 修复
- **`isAnimating` 时序 Bug**：`_onStatus` 回调中 `setState` 触发重建时，`isAnimating` 仍为 true 导致效果提前消失。改用显式 `_showWoodFire` 标记后废弃（v0.1.3.6 改用五槽位后彻底解决）

---

## 前版更新日志 — v0.1.3.5

> 发布日期：2026-05-16

### 优化
- **中央火焰动画放大**：`size * 0.26` → `size * 0.38`，视觉更醒目
- **火焰显示时长修正**：木→火全程持续显示（含动画+暂停期），直到火→土开始才消失
- **SVG viewBox 裁切**：`0 0 200 300` → `20 80 160 210`，火焰主体占比更大
- **淡入淡出过渡**：`AnimatedOpacity` 180ms，出现和消失更自然
- **应用图标替换**：`应用图标.png` 替换所有 mipmap 密度目录
- **应用名称**：`guayan_trainer` → `卦眼`

### 新增
- **WebView 中央特效**：`HtmlRelationEffect` + `wood_fire_html.dart` — 木生火 HTML/SVG 动画嵌入轮盘中央
- **webview_flutter 依赖**：v4.13.1 用于加载 HTML 动画

### 修复
- **学习页动画不显示**：`_onTick` 缺失 `setState`，HtmlRelationEffect 无法随动画帧更新
- **activeEdge 间隙 Bug**：`_ctrl.isAnimating` 为 false 时 `activeEdge` 置 null，350ms 暂停期正确隐藏活动边
- **箭头贝塞尔→圆弧**：`quadraticBezierTo` → `addArc`，沿轮盘圆周绘制相生弧线

---

## 前版更新日志 — v0.1.1

> 发布日期：2026-05-15

### 重构
- **底部四栏导航**：首页 / 学习 / 练习 / 回炉，通过 `MainShell` + `NavigationBar` + `IndexedStack` 实现
- **首页改为仪表盘**：不再堆训练入口，改为学习状态卡片 + 回炉提醒 + 快捷入口
- **学习页系统**：新增 `StudyPage` 知识图谱入口 + 五行/地支/六冲六合三个学习详情页
- **练习页独立**：原首页训练入口迁移至 `PracticePage`，按「基础训练/关系训练/综合训练」分组
- **回炉页升级为底部导航**：`ReviewPage` 显示回炉总览 + 错题/迟疑分区 + 标签已会
- **旧文件清理**：删除 `lib/pages/home_page.dart`、`mistake_page.dart`、`result_page.dart`、`training_page.dart`

### 新增
- **五行颜色系统**：`WuxingColors` — 5 种五行主色 + 5 种浅底色，贯穿所有页面
- **地支颜色映射**：地支按所属五行自动着色（子亥=水色蓝、寅卯=木色绿...）
- **训练题彩色选项**：训练页选项按钮根据五行/地支自动上色
- **结果页错题列表**：显示每个错题的题干 + 正确答案 + 你的答案

### 优化
- **题目文案更自然**：「木生什么？」→「木生谁？」；「谁生木？」→「谁来生木？」；「子冲谁？」→「子的冲神是谁？」
- **结果页按钮调整**：「查看错题回炉」→「立即回炉」+「再练一轮」+「返回首页」

---

## 前版更新日志 — v0.1.0

> 发布日期：2026-05-15

### 新增
- **项目初始化**：Flutter + Android 骨架搭建
- **五行数据层**：相生、相克、生我、克我映射表
- **十二地支数据**：五行、阴阳、方位、月份完整信息
- **六冲六合关系**：子午冲、丑未冲、子丑合、寅亥合等映射
- **5 种训练模式**：五行转轮、地支基础、六冲训练、六合训练、混合训练
- **训练引擎**：每题作答 + 即时反馈 + 计时判定
- **训练结果页**：正确率、回炉项、迟疑项统计
- **错题回炉**：答错/迟疑自动收录，标记"已会"两次后移除
- **主题配色**：古风暖色调（米金背景 + 墨绿主色）

---

## 1. 项目概览

**卦眼训练器** 是断卦基本功训练 App，用于训练五行生克、地支、六冲六合等基础知识。

当前技术栈：

| 类型 | 技术 |
| --- | --- |
| 前端框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 目标平台 | Android |

核心训练闭环：学习 → 练习 → 出错/迟疑 → 回炉 → 再练习。

---

## 2. 顶层目录结构

```text
guayan_trainer/
├── .claude/                # AI 协作规则
├── android/                # Android 原生壳
├── lib/                    # 主程序源码
├── test/                   # 测试
├── file-tree.md            # 项目结构说明文档
└── pubspec.yaml            # Flutter 依赖配置
```

---

## 3. lib 目录结构

```text
lib/
├── main.dart               # 应用入口
├── app.dart                # MaterialApp 主题配置
├── shell/                  # 导航壳
├── theme/                  # 颜色系统
├── data/                   # 数据层：纯数据映射与常量
├── models/                 # 模型层：类型定义
├── services/               # 服务层：业务逻辑
├── pages/                  # 页面层：按功能分子目录
└── widgets/                # 组件层：可复用组件（预留）
```

---

## 4. 模块职责说明

| 模块 | 职责 | 是否依赖 Flutter/Widget |
| --- | --- | --- |
| `theme/` | 五行颜色系统、主题色常量 | 是（Color） |
| `shell/` | 底部导航壳、页面切换 | 是 |
| `data/` | 数据表、常量、纯映射（五行/地支/冲合） | 否 |
| `models/` | 类型定义、数据结构 | 否 |
| `services/` | 出题引擎、错题存储 | 否 |
| `pages/` | 页面组件与用户交互 | 是 |
| `widgets/` | 可复用 UI 组件 | 是 |

---

## 5. 关键文件职责

### 5.1 根目录

| 文件 | 职责 |
| --- | --- |
| `pubspec.yaml` | 项目元信息、依赖声明与 flutter 配置 |
| `file-tree.md` | 项目文件树与模块说明文档 |

### 5.2 .claude/

| 文件 | 职责 |
| --- | --- |
| `CLAUDE.md` | AI 协作规则：文件组织、架构分层、命名规范、文档纪律 |

### 5.3 lib/

| 文件 | 职责 |
| --- | --- |
| `main.dart` | 应用入口，调用 `runApp` 启动 `GuayanTrainerApp` |
| `app.dart` | MaterialApp 组装，配置古风主题色系，home 指向 `MainShell` |

### 5.4 lib/shell/

| 文件 | 职责 |
| --- | --- |
| `main_shell.dart` | 底部四栏导航（首页/学习/练习/回炉），`IndexedStack` 页面保持 |

### 5.5 lib/theme/

| 文件 | 职责 |
| --- | --- |
| `wuxing_colors.dart` | 五行主色 + 浅底色映射，地支→五行→颜色查询，文字对比色计算 |

### 5.6 lib/data/

| 文件 | 职责 |
| --- | --- |
| `wuxing_data.dart` | 五行列表 + 相生相克映射表 + 反向查询 |
| `dizhi_data.dart` | 十二地支结构化数据：五行、阴阳、方位、月份 |
| `relation_data.dart` | 六冲六合映射 + 双端查询 + 关系判定 |

### 5.7 lib/models/

| 文件 | 职责 |
| --- | --- |
| `mistake_item.dart` | 错题记录模型，持久化 JSON 序列化 |
| `training_question.dart` | 题目类型枚举（8 种）+ 题目数据类 |
| `training_result.dart` | 单题作答记录 + 训练会话统计（正确率/回炉/迟疑） |

### 5.8 lib/services/

| 文件 | 职责 |
| --- | --- |
| `question_generator.dart` | 出题引擎：5 种训练模式 × 8 种题型随机生成 |
| `mistake_store.dart` | 错题回炉存储器：收录答错/迟疑，标记已会后移除 |

### 5.9 lib/pages/home/

| 文件 | 职责 |
| --- | --- |
| `home_page.dart` | 学习仪表盘：标题说明 + 学习状态卡 + 回炉提醒 + 快捷入口 |

### 5.10 lib/pages/study/

| 文件 | 职责 |
| --- | --- |
| `study_page.dart` | 学习页入口：五行生克/十二地支/六冲六合三张学习卡片 |
| `wuxing_study_menu_page.dart` | 五行模块目录页：4 个知识点导航卡片 + 学习建议 |
| `wuxing_color_page.dart` | 五行颜色与意象详情页：颜色卡片、对照表、记忆提示 |
| `wuxing_generate_page.dart` | 五行相生（占位：即将开放） |
| `wuxing_control_page.dart` | 五行相克学习页：五角星图、关系解释、断卦提示 |
| `wuxing_center_page.dart` | 以我为中心（占位：即将开放） |
| `dizhi_study_page.dart` | 地支学习详情：地支彩色网格、五行归类、地支分类 |
| `relation_study_page.dart` | 六冲六合学习详情：冲合对展示、跳转练习 |

### 5.11 lib/pages/practice/

| 文件 | 职责 |
| --- | --- |
| `practice_page.dart` | 练习页入口：按基础/关系/综合分组展示训练卡片 |
| `training_page.dart` | 训练页：题目展示 + 彩色选项 + 即时反馈 + 进度条 |
| `result_page.dart` | 结果页：正确率 + 回炉/迟疑汇总 + 错题列表 + 继续操作 |

### 5.12 lib/pages/review/

| 文件 | 职责 |
| --- | --- |
| `review_page.dart` | 回炉页：错题列表 + 单题重做 + 重做全部错题 |
| `review_training_page.dart` | 回炉练习页：无色单选重做，答对移除答错保留 |

### 5.13 lib/widgets/

| 文件 | 职责 |
| --- | --- |
| `wuxing_wheel.dart` | 五行轮盘组件：累计箭头动画、自动循环、节点高亮、中央特效 |
| `wuxing_arrow_painter.dart` | 圆弧箭头 CustomPainter：沿轮盘圆周绘制相生弧线 |
| `wuxing_control_wheel.dart` | 五行相克轮盘：五角星累计箭头 + 五槽位特效自播 |
| `wuxing_control_arrow_painter.dart` | 五角星直线箭头 CustomPainter：跨节点红色克制线 |
| `wuxing_control_painter.dart` | 静态相克五角星 CustomPainter |
| `effects/control/earth_water_control_html.dart` | 土克水 HTML/SVG 动画，土堤束水 |
| `effects/control/fire_metal_control_html.dart` | 火克金 HTML/SVG 动画，烈火熔金 |
| `effects/control/metal_wood_control_html.dart` | 金克木 HTML/SVG 动画，金刃断木 |
| `effects/control/water_fire_control_html.dart` | 水克火 HTML/SVG 动画，水幕压火 |
| `effects/control/wood_earth_control_html.dart` | 木克土 HTML/SVG 动画，木根破土 |
| `effects/control/control_relation_effect.dart` | 相克 HTML WebView 封装 |
| `effects/control/control_relation_effects_layer.dart` | 五相克槽位关系动画层 |
| `effects/earth_metal_html.dart` | 土生金 HTML/SVG 动画，金石破土而出 |
| `effects/fire_earth_html.dart` | 火生土 HTML/SVG 动画，灰烬掩埋火苗循环 |
| `effects/generate_relation_effects_layer.dart` | 五槽位关系动画层：固定坐标渲染多条关系动画 |
| `effects/html_relation_effect.dart` | WebView 封装组件，IgnorePointer 防拦截，支持全部五条相生 |
| `effects/metal_water_html.dart` | 金生水 HTML/SVG 动画，寒风凝水珠滴落 |
| `effects/water_wood_html.dart` | 水生木 HTML/SVG 动画，春雨润木发芽繁茂 |
| `effects/wood_fire_html.dart` | 木生火钻木取火 HTML/SVG 动画 |

### 5.14 test/

| 文件 | 职责 |
| --- | --- |
| `widget_test.dart` | Widget 冒烟测试：首页正确渲染 |

---

## 6. 模块依赖方向

```text
theme/  data/  ←  models/  ←  services/  ←  pages/  +  widgets/
                                                    ←  shell/
```

依赖约束：

1. `data/`、`theme/` 不依赖任何上层模块。
2. `models/` 不依赖任何上层模块。
3. `services/` 可以依赖 `data/` 与 `models/`，但不能依赖 Flutter Widget。
4. `pages/` 可以依赖 `services/`、`models/`、`data/`、`theme/`。
5. `shell/` 可以依赖所有页面模块。
6. `widgets/` 只依赖 `models/`。
7. 禁止循环依赖。
8. 禁止在页面组件中写复杂业务逻辑（出题、计分、错题管理）。

---

## 7. 当前架构原则

### 7.1 分层原则

```text
数据定义 → 主题系统 → 业务逻辑 → 状态管理 → UI 页面
```

| 层级 | 说明 |
| --- | --- |
| 数据定义 | 五行生克映射、地支信息、冲合关系 |
| 主题系统 | `WuxingColors` 颜色体系 |
| 业务逻辑 | 出题算法、计时判定、错题收录 |
| 状态管理 | `MistakeStore` 单例管理错题状态 |
| UI 页面 | 四栏导航 + 5 个子页面区 |

### 7.2 当前不做的内容

当前版本暂不开发：

- 本地持久化（SharedPreferences / 文件存储）；
- 地支圆盘可视化组件；
- 五行转轮可视化组件；
- 回炉专项训练模式；
- 三合三会数据与训练；
- 天干数据与训练；
- 纳音五行；
- 六十四卦；
- 统计图表与学习曲线；
- 多用户/多设备同步。

---

## 8. 版本历史

| 版本 | 日期 | 类型 | 说明 |
| --- | --- | --- | --- |
| `v0.1.5` | 2026-05-16 | 新增 | 五行相克学习页，wrongCount 修复，回炉弹窗，阶段标签 |
| `v0.1.4.2` | 2026-05-16 | 修复 | 金元素灰色文字，答题反馈色通用化 |
| `v0.1.4.1` | 2026-05-16 | 新增 | 回炉错题重做系统，持久化存储 |
| `v0.1.4` | 2026-05-16 | 新增 | 相生练习三阶段：轮盘→彩色单选→无色单选 |
| `v0.1.3.13` | 2026-05-16 | 优化 | 箭头 3500ms 对齐 5s 特效，一轮 25 秒 |
| `v0.1.3.12` | 2026-05-16 | 优化 | 箭头 1800ms、火生土纯 CSS 版修复 viewBox |
| `v0.1.3.11` | 2026-05-16 | 新增 | 全部五条相生 HTML 动画接入，轮盘还原慢速 |
| `v0.1.3.10` | 2026-05-16 | 优化 | 轮盘加速至 5 秒一轮 |
| `v0.1.3.9` | 2026-05-16 | 变更 | 木生火替换为钻木取火动画 |
| `v0.1.3.8` | 2026-05-16 | 新增 | 火生土 HTML 动画，HtmlRelationEffect 泛化 |
| `v0.1.3.7` | 2026-05-16 | 优化 | 放慢节奏、标题延迟、木火槽位内移 |
| `v0.1.3.6` | 2026-05-16 | 重构 | 五固定槽位 + 中央关系标题，废弃中央单动画 |
| `v0.1.3.5` | 2026-05-16 | 优化 | 中央火焰放大至 0.38、全程持续显示、SVG 裁切、淡入淡出 |
| `v0.1.3.4` | 2026-05-16 | 新增 | WebView 木生火中央 HTML 特效接入 |
| `v0.1.3.3` | 2026-05-16 | 修复 | 累计箭头正确暂停还原、圆弧箭头、addStatusListener |
| `v0.1.3.2` | 2026-05-15 | 重构 | 删除顺序卡、轮盘循环动画、金色银灰、弧线箭头 |
| `v0.1.3.1` | 2026-05-15 | 修复 | 关闭火焰特效、轮盘裁切修复、箭头动画重置、Painter 安全兜底 |
| `v0.1.3` | 2026-05-15 | 新增 | 五行相生学习页、相生专项训练、箭头动画 |
| `v0.1.2.2` | 2026-05-15 | 新增 | 五行轮盘 UI 组件 + 练习集成 |
| `v0.1.2.1` | 2026-05-15 | 修复 | 颜色页文本溢出 + 五行配色统一 |
| `v0.1.2` | 2026-05-15 | 新增 | 五行模块目录页、五行颜色与意象详情页、3 个知识占位页 |
| `v0.1.0` | 2026-05-15 | 新增 | 初始版本：五行、地支、六冲、六合训练 + 错题回炉 |

---

## 9. 后续版本计划

| 版本 | 目标 |
| --- | --- |
| `v0.1.2` | SharedPreferences 错题持久化 |
| `v0.1.3` | 地支圆盘视觉组件 |
| `v0.1.4` | 五行转轮视觉组件 |
| `v0.1.5` | 回炉专项训练 |
| `v0.2.0` | 三合三会数据与训练 |

---

## 10. 文档维护规范

每次修改代码后，必须检查是否需要更新本文档。

### 10.1 必须更新的情况

- 新增文件；
- 删除文件；
- 重命名文件；
- 移动目录；
- 文件职责发生明显变化；
- 新增模块；
- 架构依赖方向变化；
- 新增版本 tag；
- 新增长期计划或取消原计划。

### 10.2 不必更新的情况

- 只修改函数内部实现；
- 只调整样式细节；
- 只修复 bug；
- 只修改文案；
- 不改变文件职责的小范围重构。

### 10.3 AI 修改代码后的检查清单

每次提交代码后，检查：

```text
[ ] 是否新增 / 删除 / 重命名文件？
[ ] 是否改变现有文件职责？
[ ] 是否引入新的模块目录？
[ ] 是否破坏模块依赖方向？
[ ] 是否需要更新版本历史？
[ ] 是否需要更新后续版本计划？
```

如答案为"是"，必须同步修改 `file-tree.md`。

---

## 11. 备注

本文档只描述项目结构和模块职责，不记录具体算法细节。
