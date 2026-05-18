# 项目文件树 — 卦眼训练器

> **当前版本：** v0.1.8.2
> **创建时间：** 2026-05-15
> **最后编辑：** 2026-05-18 16:20

> 本文件用于记录项目目录结构、模块职责与版本演进。  
> 每次 AI 或人工修改代码后，如涉及新增、删除、重命名文件，必须同步更新本文档。

---

## 当前版本更新日志 — v0.1.8.2

> 发布日期：2026-05-18 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.8.2)

### 修复
- **类型补全**：全部模型和参数强类型化
- **`isHesitant` 分离**：迟疑判断独立于超时
- **会话时间拆分**：`_sessionStartedAt` / `_questionStartedAt` 分开
- **题库补满**：`_takeWithRepeat()` 不足时自动重复抽题
- **同我题加入**：以我为中心关系判断包含全部五类，共 25 题
- **错题字段补全**：MistakeItem 新增 `explanation` / `reactionMs` / `isHesitant`

### 新增文件
- `lib/utils/practice_labels.dart` — 中文标签、题库容量、时间格式化

---

## 前版更新日志 — v0.1.8.1

> 发布日期：2026-05-18 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.8.1)

### 修复
- 通用练习框架加固：isHesitant 字段、会话时间分离、题库 _takeWithRepeat 补满、同我题加入、错字字段补全

---

## 前版更新日志 — v0.1.8

> 发布日期：2026-05-18 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.8)

### 新增
- **通用练习框架**：统一 `PracticeQuestion` / `PracticeAnswerRecord` / `PracticeSessionResult` 模型
- **综合练习入口**：学习→五行生克→★综合练习，支持多板块混合出题
- **四类题库**：五行相生（5题）、五行相克（5题）、以我为中心（25题）、旺相休囚死（25题）
- **计时系统**：每题记录反应耗时，超过 4 秒标记迟疑
- **结果页统计**：正确率 + 分项表现 + 平均反应 + 迟疑题 + 整场用时

---

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
| `wuxing_self_center_data.dart` | 以我为中心关系映射 + 旺相休囚死 |
| `dizhi_data.dart` | 十二地支结构化数据：五行、阴阳、方位、月份 |
| `relation_data.dart` | 六冲六合映射 + 双端查询 + 关系判定 |
| `practice/wuxing_practice_question_generator.dart` | 通用题库生成器：四类五行题库混合出题 |

### 5.7 lib/models/

| 文件 | 职责 |
| --- | --- |
| `mistake_item.dart` | 错题记录模型，持久化 JSON 序列化 |
| `training_question.dart` | 题目类型枚举（8 种）+ 题目数据类 |
| `training_result.dart` | 单题作答记录 + 训练会话统计（正确率/回炉/迟疑） |
| `practice/practice_enums.dart` | 通用练习枚举，Domain / Topic / AnswerKind / Stage |
| `practice/practice_question.dart` | 通用题目模型 |
| `practice/practice_answer_record.dart` | 答题记录 + 会话统计 + 分项统计 |

### 5.8 lib/services/

| 文件 | 职责 |
| --- | --- |
| `question_generator.dart` | 出题引擎：5 种训练模式 × 8 种题型随机生成 |
| `mistake_store.dart` | 错题回炉存储器：收录答错/迟疑，标记已会后移除 |

### 5.9 lib/utils/

| 文件 | 职责 |
| --- | --- |
| `practice_labels.dart` | 通用练习中文标签、题库容量、时间格式化函数 |

### 5.10 lib/pages/home/

| 文件 | 职责 |
| --- | --- |
| `home_page.dart` | 学习仪表盘：标题说明 + 学习状态卡 + 回炉提醒 + 快捷入口 |

### 5.11 lib/pages/study/

| 文件 | 职责 |
| --- | --- |
| `study_page.dart` | 学习页入口：五行生克/十二地支/六冲六合三张学习卡片 |
| `wuxing_study_menu_page.dart` | 五行模块目录页：4 个知识点导航卡片 + 综合练习 + 学习建议 |
| `wuxing_color_page.dart` | 五行颜色与意象详情页：颜色卡片、对照表、记忆提示 |
| `wuxing_generate_page.dart` | 五行相生（占位：即将开放） |
| `wuxing_control_page.dart` | 五行相克学习页：五角星图、关系解释、断卦提示 |
| `wuxing_center_page.dart` | 以我为中心学习页：五行选择 + 关系图 + 旺相休囚死 |
| `dizhi_study_page.dart` | 地支学习详情：地支彩色网格、五行归类、地支分类 |
| `relation_study_page.dart` | 六冲六合学习详情：冲合对展示、跳转练习 |

### 5.12 lib/pages/practice/

| 文件 | 职责 |
| --- | --- |
| `practice_page.dart` | 练习页入口：按基础/关系/综合分组展示训练卡片 |
| `training_page.dart` | 训练页：题目展示 + 彩色选项 + 即时反馈 + 进度条 |
| `result_page.dart` | 结果页：正确率 + 回炉/迟疑汇总 + 错题列表 + 继续操作 |
| `practice_setup_page.dart` | 综合练习设置页：选择板块 + 题数 |
| `practice_session_page.dart` | 通用练习页：计时 + 反馈 + 回炉写入 |
| `practice_result_page.dart` | 通用结果页：分项表现 + 平均反应 + 迟疑统计 |

### 5.13 lib/pages/review/

| 文件 | 职责 |
| --- | --- |
| `review_page.dart` | 回炉页：错题列表 + 单题重做 + 重做全部错题 |
| `review_training_page.dart` | 回炉练习页：无色单选重做，答对移除答错保留 |

### 5.14 lib/widgets/

| 文件 | 职责 |
| --- | --- |
| `wuxing_wheel.dart` | 五行轮盘组件：累计箭头动画、自动循环、节点高亮、中央特效 |
| `wuxing_arrow_painter.dart` | 圆弧箭头 CustomPainter：沿轮盘圆周绘制相生弧线 |
| `wuxing_control_wheel.dart` | 五行相克轮盘：五角星累计箭头 + 五槽位特效自播 |
| `wuxing_control_arrow_painter.dart` | 五角星直线箭头 CustomPainter：跨节点红色克制线 |
| `wuxing_control_painter.dart` | 静态相克五角星 CustomPainter |
| `wuxing_self_center_wheel.dart` | 以我为中心圆盘：中心+四向外圈节点 |
| `wuxing_self_center_painter.dart` | 四向箭头 + 中心双环 CustomPainter |
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

### 5.15 test/

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
| `v0.1.7.2` | 2026-05-18 | 优化 | 圆盘排版精修，箭头避让，胶囊节点 |
| `v0.1.7.1` | 2026-05-18 | 重构 | 以我为中心升级圆盘结构，四色箭头 |
| `v0.1.7` | 2026-05-18 | 新增 | 以我为中心学习页，旺相休囚死 |
| `v0.1.6.2` | 2026-05-18 | 优化 | 轮盘尺寸稳定，结果页三阶段统计，回炉来源标签 |
| `v0.1.6.1` | 2026-05-16 | 修复 | 答题前隐藏提示，答题后显示特效 |
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
