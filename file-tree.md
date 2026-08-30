# 项目文件树 — 卦眼训练器

> **当前版本：** v0.1.10
> **创建时间：** 2026-05-15
> **最后编辑：** 2026-08-30 09:44

> 本文件用于记录项目目录结构、模块职责与版本演进。  
> 每次 AI 或人工修改代码后，如涉及新增、删除、重命名文件，必须同步更新本文档。

---

## 卦眼 2.0 Foundation — feat/guayan-2.0

> 分支：`feat/guayan-2.0`（继承 GitHub 历史，2.0 App 架构重新开发，旧功能未来收编进「训练」入口）

### 新增 2.0 骨架
- **入口极简化**：`lib/main.dart` 只做 `runApp(const GuayanApp())`，不再跳旧 HomePage、不再初始化旧 MistakeStore。
- **`lib/app/`**：2.0 应用壳
  - `app.dart` — `GuayanApp`：MaterialApp 组装 + 全局主题（浅色、紧凑）
  - `app_shell.dart` — `AppShell`：IndexedStack 状态保持 + NavigationBar 五主导航，`selectedIndex` 单一权威来源，默认 Index 0（排卦）
  - `navigation/main_tabs.dart` — 正式产品 IA：排卦/审卦/关系/卦例/训练（顺序固定）
  - `more_menu.dart` — AppBar 右上角「更多」：规则库 / 设置 / 关于
- **`lib/core/constants/app_info.dart`**：应用名「卦眼」、内部版本、主题种子色常量
- **`lib/domain/`（预留）**：GUAYAN-2.0-DOMAIN 阶段在此建立 HexagramCase / LineState / RelationInstance / RelationNote 等
- **`lib/application/`（预留）**：后续用例层；Foundation 阶段仅 AppShell 用 StatefulWidget，不引入状态管理框架
- **`lib/presentation/`**：五个主页面 Skeleton + 规则库/设置/关于
  - `casting/casting_page.dart` — 排卦工作台（含 §35 状态保持探针，后续可删）
  - `review/review_page.dart` — 审卦工作台
  - `relations/relations_page.dart` — 关系工作台
  - `cases/cases_page.dart` — 卦例工作台
  - `training/training_page.dart` — 训练（旧功能未来统一收编，本阶段仅 Skeleton）
  - `rules/rule_library_page.dart` — 规则库 Skeleton（自定义规则/规则包/系统规则，无 CRUD）
  - `settings/settings_page.dart`、`about/about_page.dart` — 占位页
  - `shared/module_placeholder.dart` — 模块占位共用组件
- **`test/foundation_test.dart`**：Foundation 验收 Widget 测试（五导航/默认排卦/切换/状态保持/更多/规则库/关于）

### 修改
- `android/app/src/main/AndroidManifest.xml` — Activity 增加 `android:screenOrientation="portrait"` 锁定竖屏；label 确认「卦眼」
- `lib/main.dart` — 替换为 2.0 极简入口
- `file-tree.md` — 记录 2.0 骨架

### 说明
- 旧训练资产（`lib/pages/`、`lib/data/`、`lib/services/`、`lib/models/`、`lib/widgets/effects/`、`五行相克特效/`、`五行相生特效/` 等）一律保留未迁移，后续进入「训练」阶段统一处理。
- 旧 `lib/app.dart`（`GuayanTrainerApp`）保留供旧测试引用，与 `lib/app/` 目录共存。
- 分支创建前已将未发布 hotfix 提交至 master（`610e81f`）并合并远端学习模块提交（`5c4bdb6`）。

---

## 成果归档提交 — 2026-08-27（未发布）

> 背景：开发机内存耗尽崩溃重启（Gradle 提交内存 errno 1455），判定本机暂不具备继续开发条件，全部工作成果一次性归档提交并推送 GitHub（`feat/guayan-2.0`），防止成果丢失。详见 `CHANGELOG.md`。

### 新增
- `AGENTS.md` — 项目代码规则（文件组织 / 架构分层 / 命名规范 / 文档纪律 / 版本与构建），AI 自动遵守
- `lib/data/training_question.dart` — 2.0 训练数据模型：`TrainingModule` / `RelationType` / `TrainingQuestion`
- `lib/data/wuxing_questions.dart` — 五行生克题库：相生 5 题 + 相克 5 题（10 题）
- `uploads/` — 参考资料：`XYUI1ComponentDocumentView.axaml`、`卦眼 2.0 总开发计划.md`
- `五行相克特效/` — 5 个相克 HTML 动画原型（金克木/木克土/土克水/水克火/火克金）
- `五行相生特效/` — 5 个相生 HTML 动画原型（金生水/水生木/木生火/火生土/土生金）
- `CHANGELOG.md` — 文件审计与变更日志

### 修改
- `android/gradle.properties` — 低内存开发机约束：JVM 堆 1G、Kotlin daemon 256m、`org.gradle.workers.max=1`，避免构建提交内存耗尽
- `file-tree.md` — 记录归档提交、新增文件与最后编辑时间

---

## GUAYAN-2.0-DOMAIN — Stable Relation Identity（2026-08-30，未发布）

> 阶段目标：**RelationInstance 可以重建，RelationNote 不能失忆。**
> 只做四个核心 Domain + 稳定关系身份，不扩范围；完整设计见 `lib/domain/README.md`。

### 新增（lib/domain/ — 纯 Dart 领域层，零 Flutter/外部依赖）
- `hexagram_case.dart` — 卦例持久化根对象（最小骨架）
- `line_state.dart` — 一爻状态：稳定爻位 + 动静 + 所值地支
- `line_endpoint.dart` — 关系端点稳定身份（卦侧 + 爻位）
- `relation_type.dart` — 关系类型枚举 + 系统规则 RuleId 常量
- `relation_key.dart` — **Stable Relation Identity 核心**（单一构造入口）
- `relation_instance.dart` — 一条具体关系（重算可重建）
- `relation_calculator.dart` — 最小确定性关系计算（动变/六冲/六合）
- `relation_note.dart` — 关系笔记（caseId + RelationKey 重新绑定）
- `relation_note_store.dart` — 笔记绑定存储（纯内存 + JSON 导入导出）

### 新增（test/domain/）
- `domain_test_utils.dart` — 共享演示卦例（动变 + 六冲）
- `relation_key_test.dart` — Test A 确定性 / Test B 差异性 / 方向处理
- `relation_key_serialization_test.dart` — RelationKey JSON round-trip 与展示名解耦
- `relation_rebinding_test.dart` — Test C 重算恢复笔记 / Test D 不串笔记 / Test E 顺序无关
- `relation_serialization_test.dart` — T8 序列化 → 反序列化 → 重算 → 重新绑定全链

### 新增（scripts/）
- `flutter.ps1` — 本机 Flutter 包装脚本（APPDATA 重定向 + 代理 + 直调 snapshot，解决 flutter.bat 挂起）

### 修改
- `lib/domain/README.md` — 占位说明替换为 Stable Relation Identity 设计文档
- `test/domain/`（新建目录）、`scripts/`（新建目录）
- `file-tree.md` — 记录 DOMAIN 阶段新增与职责

### 说明
- RelationKey = 语义坐标（类型机器名 + RuleId + RuleVersion + subtype + 端点），
  与运行时对象 / UI 顺序 / 数据库 row id 解耦；方向显式处理（有向保序、对称排序）。
- 笔记按 `(caseId + RelationKey)` 绑定；Domain 保持 storage-agnostic，持久化实现后续决定。
- 全量测试 31 个通过（21 领域 + 10 Foundation/Widget）；未启动 Android 模拟器。

---

## 未发布变更 — 2026-05-26

### 修复
- **错题回炉初始化**：`MistakeStore` 新增显式 `init()`，应用启动时真正等待 SharedPreferences 数据加载，避免首页/练习/回炉首次读取错题数量为空。
- **连连看构建错误**：修复 `LinkMatchGamePage` HUD 中动态错误数使用 `const TextStyle` 导致的编译失败。

### 修改文件
- `lib/main.dart` — 启动时调用 `MistakeStore.instance.init()`。
- `lib/services/mistake_store.dart` — 暴露初始化入口，保留同步 `all` 读取缓存。
- `lib/pages/practice/games/link_match_game_page.dart` — 修复动态 HUD 样式的 const 使用。
- `file-tree.md` — 更新最后编辑时间、未发布变更和相关职责说明。

---

## 未发布更新日志（远端合并）

### 新增
- **五行意象学习页**：`WuxingImageryPage` — 五行知识总卡 + 颜色、五味、脏腑、方位、品质、数字、四季、地支五行分板块意象
- **八卦学习页**：`BaguaStudyPage` — 八卦产生、歌诀、知识总卡、八卦分卡、病象折叠与文王卦使用提示

### 修改
- **学习入口命名**：`五行生克` 改为 `五行模块`
- **学习入口扩展**：新增 `八卦模块`，位于五行模块之后、十二地支之前
- **五行模块目录**：拆分 `五行颜色` 与 `五行意象`，后续相生、相克、以我为中心顺延
- **五行颜色页**：下一步跳转改为进入 `五行意象`

---

## 当前版本更新日志 — v0.1.10

> 发布日期：2026-05-22 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.10)

### 新增
- **关系连连看游戏**：`LinkMatchGamePage` — 25 组配对 / 50 张卡牌消除模板
- **`PracticeMode.linkMatch`**：第三种练习模式
- **`HitEffectKind` / `FallingRuleKind`** 枚举：为后续地支合/冲预留

### 游戏规则
- 上方源牌 25 张 + 下方目标牌 25 张，各自打乱
- 点击源牌 → 高亮 → 点击目标牌完成配对
- 正确：❤️/⚡ 反馈 + 两张牌消除消失 + 加分连击
- 错误：扣命 + 显示正确答案 + 写入回炉
- 默认 5 条命，全部配完或命用完 → 结果页

### 新增文件
- `lib/pages/practice/games/link_match_game_page.dart` — 连连看游戏主页面

### 修改文件
- `lib/models/practice/practice_enums.dart` — PracticeMode.linkMatch + HitEffectKind + FallingRuleKind
- `lib/pages/practice/practice_setup_page.dart` — 新增连连看模式选择与跳转
- `lib/pages/practice/practice_result_page.dart` — 新增 matchedCount/totalPairs 参数
- `lib/pages/practice/practice_page.dart` — 趣味游戏区增加连连看入口
- `lib/utils/practice_labels.dart` — PracticeStage 增加 linkMatch
- `lib/theme/wuxing_colors.dart` — 金颜色优化

---

## 前版更新日志 — v0.1.9

> 发布日期：2026-05-22 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.9)

### 新增
- **方块速答游戏**：通用单方块下落模板 `FallingBlockGamePage`
- **`PracticeMode.fallingBlock`**：正式启用方块速答模式
- **`PracticeSetupPage` 模式选择**：普通练习 / 方块速答 二选一切换
- **`PracticeResultPage` 游戏统计**：新增 `score` / `maxCombo` / `remainingLives` 可选显示
- **错题写入**：答错/漏掉统一走 `MistakeStore.addOrUpdateMistake`，漏掉显示"未作答"

### 游戏规则
- 题目方块从上往下掉，点击底部正确答案
- 答对：得分 +10+连击，连击递增
- 答错：生命 -1，连击清零，写入回炉
- 漏掉：生命 -1，标记超时，写入回炉
- 基础下落 4500ms，每 5 连击加速 250ms，最低 2200ms
- 题目用完或生命归零 → 结果页

### 新增文件
- `lib/pages/practice/games/falling_block_game_page.dart` — 打方块游戏主页面

### 修改文件
- `lib/models/practice/practice_enums.dart` — PracticeMode 增加 fallingBlock
- `lib/pages/practice/practice_setup_page.dart` — 增加模式选择与跳转
- `lib/pages/practice/practice_result_page.dart` — 增加游戏统计字段

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
├── memory/                 # 记忆与反馈记录
├── scripts/                # 开发辅助脚本（本机 flutter 包装）
├── test/                   # 测试
├── uploads/                # 参考资料（开发计划、组件文档）
├── 五行相克特效/            # 相克 HTML 动画原型（5 个）
├── 五行相生特效/            # 相生 HTML 动画原型（5 个）
├── AGENTS.md               # 项目代码规则（AI 自动遵守）
├── CHANGELOG.md            # 文件审计与变更日志
├── file-tree.md            # 项目结构说明文档
└── pubspec.yaml            # Flutter 依赖配置
```

---

## 3. lib 目录结构

```text
lib/
├── main.dart               # 应用入口
├── app.dart                # MaterialApp 主题配置
├── app/                    # 2.0 应用壳（GuayanApp / AppShell / 导航）
├── core/                   # 2.0 常量
├── domain/                 # 2.0 领域层（GUAYAN-2.0-DOMAIN）
├── application/            # 2.0 用例层（预留）
├── presentation/           # 2.0 五个主页面 + 规则库/设置/关于
├── shell/                  # 旧导航壳（1.0 遗留）
├── theme/                  # 颜色系统
├── data/                   # 数据层：纯数据映射与常量
├── models/                 # 模型层：类型定义
├── services/               # 服务层：业务逻辑
├── pages/                  # 页面层：按功能分子目录（1.0 遗留）
└── widgets/                # 组件层：可复用组件（1.0 遗留）
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
| `main.dart` | 应用入口，初始化错题缓存后调用 `runApp` 启动 `GuayanTrainerApp` |
| `app.dart` | MaterialApp 组装，配置古风主题色系，home 指向 `MainShell` |

### 5.3.1 lib/domain/（2.0 领域层）

| 文件 | 职责 |
| --- | --- |
| `hexagram_case.dart` | 卦例持久化根对象：id / question / createdAt / lines[6] |
| `line_state.dart` | 一爻状态：爻位 / 动静（老阴老阳发动）/ 所值地支 |
| `line_endpoint.dart` | 关系端点稳定身份：卦侧（original/changed）+ 爻位（1..6） |
| `relation_type.dart` | 关系类型枚举 + 方向类别 + 展示名 + 系统 RuleId 常量 |
| `relation_key.dart` | 关系稳定语义 key（Stable Relation Identity 核心） |
| `relation_instance.dart` | 一条具体关系实例（身份以 key 为准，可重算重建） |
| `relation_calculator.dart` | 最小确定性关系计算：动变 / 六冲 / 六合 |
| `relation_note.dart` | 关系笔记实体（caseId + RelationKey 绑定） |
| `relation_note_store.dart` | 笔记绑定存储：纯内存 + JSON 导入导出 |
| `README.md` | 领域设计与 Stable Relation Identity 说明 |

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
| `training_question.dart` | 2.0 训练数据模型：TrainingModule / RelationType / TrainingQuestion |
| `wuxing_questions.dart` | 五行生克题库：相生 5 题 + 相克 5 题 |
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
| `mistake_store.dart` | 错题回炉存储器：启动初始化、收录答错/迟疑，标记已会后移除 |

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
| `study_page.dart` | 学习页入口：五行模块/八卦模块/十二地支/六冲六合四张学习卡片 |
| `bagua_study_page.dart` | 八卦模块详情页：八卦产生、歌诀、知识总卡、分卡、病象与文王卦提示 |
| `wuxing_study_menu_page.dart` | 五行模块目录页：颜色、意象、生克、以我为中心导航卡片 + 综合练习 + 学习建议 |
| `wuxing_color_page.dart` | 五行颜色详情页：颜色卡片、对照表、记忆提示，下一步进入五行意象 |
| `wuxing_imagery_page.dart` | 五行意象详情页：五行知识总卡 + 颜色/五味/脏腑/方位/品质/数字/四季/地支五行分板块 |
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
| `practice_setup_page.dart` | 综合练习设置页：选择板块 + 题数 + 练习方式 |
| `practice_session_page.dart` | 通用练习页：计时 + 反馈 + 回炉写入 |
| `practice_result_page.dart` | 通用结果页：分项表现 + 平均反应 + 迟疑统计 |
| `games/falling_block_game_page.dart` | 方块速答游戏：单题下落 + 生命/分数/连击 + 回炉 |
| `games/link_match_game_page.dart` | 关系连连看：25组配对 + 50张卡牌消除 + 回炉 |

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

- 地支圆盘可视化组件；
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
| `v0.1.10` | 2026-05-22 | 新增 | 关系连连看：25组配对+50张卡消除+回炉 |
| `v0.1.9` | 2026-05-22 | 新增 | 方块速答游戏模板，单题下落 + 计时 + 回炉 |
| `v0.1.8.3` | 2026-05-18 | 重构 | 旧入口迁移到通用练习框架，经典按钮备份 |
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
