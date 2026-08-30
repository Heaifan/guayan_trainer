# GUAYAN-2.0 · REVIEW PAGE IMPLEMENTATION R1
## 审卦页完整实施任务书

> 目标：把当前“审卦”页实现成已经人工定稿的 **XYUI 长页排盘工作台**。
>
> 本轮视觉基准已经确定，不再做方案探索。
>
> **界面描述以本任务书中的 SVG 为最高优先级。**
>
> 若文字描述与 SVG 冲突：**SVG 优先。**

---

## 0. TASK

```text
TASK
GUAYAN-2.0-REVIEW-UI-R1

BRANCH
feat/guayan-2.0

TARGET
实现审卦页最终视觉骨架、传统六爻排盘主体、神煞区、四柱区、关系焦点区，并接入当前已有排卦结果数据。

STATUS
READY TO IMPLEMENT

USER VISUAL BASELINE
APPROVED DESIGN

STOP POINT
完成实现、测试、Android 构建、commit、push 后停止。
等待用户真机截图人工视觉验收。
不得自行宣布 USER VISUAL ACCEPTED。
```

---

## 1. 本轮页面定位

审卦页不是普通“检查列表”，也不是第二个“关系页”。

它的产品心智固定为：

```text
排卦结果上下文
↓
完整传统六爻排盘
↓
人工审卦
↓
关系焦点 / 规则依据
↓
必要时进入关系页继续深入
```

必须同时满足两件事：

```text
A. 传统六爻用户一眼能读懂排盘
B. 卦眼自己的 Relation / Rule / Note 能力能够继续承接
```

不得为了“现代 UI”删掉传统排盘要素。

---

## 2. 页面必须包含的要素

本轮必须保留：

```text
方式
事项
阳历时间
阴历时间

神煞

年柱
月柱
日柱
时柱
旬空

主卦
变卦

六神
伏神
六亲
地支
五行/纳音文本（按现有数据能力）
爻象
世
应
动爻
变爻

关系焦点
规则依据入口

Bottom Navigation
排卦 / 审卦 / 关系 / 卦例 / 训练
```

如果当前 Domain 尚未提供某项真实值：

- 不得伪造计算逻辑；
- 允许先使用现有测试数据 / placeholder adapter；
- 必须在报告 GAP 中明确标注；
- 不得在 Widget 内写一套“假六爻算法”。

---

## 3. 页面总体布局

页面采用：

```text
SafeArea
└── Column
    ├── ReviewAppBar
    ├── Expanded
    │   └── SingleChildScrollView
    │       └── Column
    │           ├── BasicInfoCard
    │           ├── ShenShaCard
    │           ├── FourPillarsStrip
    │           ├── HexagramResultHeader
    │           ├── HexagramResultTable
    │           └── RelationFocusCard
    └── MainTabBar
```

关键约束：

```text
正文可纵向滚动
Bottom Navigation 固定在 App Shell 底部
六爻排盘表本身不要再套内部纵向 Scroll
```

---

## 4. UI 风格

继续使用当前已经通过用户认可的 XYUI 视觉语言：

```text
Light
Flat
Compact
Low Saturation
High Information Density
Semantic State
```

禁止：

```text
Material 默认 Card / ListTile 风格
高饱和红绿
渐变
黑色科技风
超大圆角
大面积空白
巨大按钮
所有信息都做成 pill
```

推荐语义 Token：

```text
Page.Background      #F5F8F6
Surface.Default      #FFFFFF
Surface.Soft         #F8FBF9
Surface.Active       #EEF5F1

Border.Default       #DCE5E1
Border.Active        #91AC9D
Divider              #E5ECE8

Text.Primary         #243744
Text.Body            #405E6C
Text.Secondary       #71838B
Text.Muted           #7C8D94

Accent.Primary       #567866
Accent.Surface       #E6F0EB

Relation.Red         #B66F6F
Relation.Green       #6F9A82
Relation.Blue        #718AA5
Traditional.Gold     #B0905F
Pillar.Teal          #4F8A8B
```

若项目已有对应 Token，优先复用，不得再建第二套近似值。

---

## 5. Flutter 组件拆分建议

优先在现有结构内演进，不要为了完全匹配本建议而大搬家。

```text
lib/presentation/review/
├── review_page.dart
├── review_page_state.dart
├── review_controller.dart
│
└── widgets/
    ├── review_app_bar.dart
    ├── review_basic_info_card.dart
    ├── review_shensha_card.dart
    ├── review_four_pillars_strip.dart
    ├── review_hexagram_result_header.dart
    ├── review_hexagram_result_table.dart
    ├── review_hexagram_line_row.dart
    └── review_relation_focus_card.dart
```

公共导航继续复用：

```text
lib/app/navigation/main_tab_bar.dart
```

禁止复制第二个审卦专用 BottomBar。

---

## 6. 数据来源规则

优先复用当前已有 Domain：

```text
HexagramCase
LineState
RelationInstance
RelationKey
RelationNote
RuleId
RuleVersion
```

UI 不得创造第二套业务真相：

```text
FakeHexagram
ReviewLineV2
UiRelationEngine
TemporaryRuleCalculator
```

尤其禁止在 Widget 内：

```text
重新算六冲
重新算六合
重新算生克
重新算动变
重新算回头生克
```

如果关系数据尚未进入本页，则只做 presentation adapter。

---

## 7. ReviewPageState 建议

至少提供：

```text
question
castingMethod
solarDateTime
lunarDateTime

shenShaItems[]

yearPillar
monthPillar
dayPillar
hourPillar
xunKong

originalHexagramName
changedHexagramName
originalPalaceInfo
changedPalaceInfo

lines[6]

focusedLine
focusedRelations[]
rulePackId
ruleVersion
```

每一行至少能渲染：

```text
linePosition
sixSpirit
hiddenSpirit / 伏神
sixRelative
earthlyBranch
displayExtra
yinYang
movement
shiYing
changedLine
```

当前数据不支持的字段必须显式 nullable，不得偷偷猜。

---

## 8. 神煞区规则

神煞不能再输出成长段文本。

必须采用 **独立卡片 + 自适应标签网格**。

建议 Flutter：

```text
Wrap
spacing: 6~8
runSpacing: 8~10
```

标签内容由数据生成。

不要硬编码固定 16 个位置。

同一项结构：

```text
名称：值
```

例如：

```text
卦身：申
香闺：寅卯
驿马：寅
桃花：酉
贵人：酉亥
```

小屏允许自然换行，禁止文字溢出。

---

## 9. 四柱区

四柱显示顺序固定：

```text
年
月
日
时
旬空
```

不允许：

```text
旬空跑到独立大卡片
```

当前视觉采用一条横向紧凑 Strip。

若小屏宽度不足：

优先压缩 spacing / font scale；
不要拆成五个巨大卡片。

---

## 10. 六爻排盘主体

这是本轮最重要组件。

必须保留六行完整传统语义。

整体列心智：

```text
六神
主卦（含伏神）
变卦
```

每行内部要表达：

```text
六神

伏神
六亲 + 地支 + 五行/附加显示

主卦爻象
世 / 应
动爻标记

变卦信息
变卦爻象
```

页面不应该像普通 DataTable。

视觉必须仍然有六爻排盘感。

---

## 11. 爻象绘制

禁止 Unicode 爻象。

统一使用 Flutter CustomPainter / Canvas / CustomPaint 或现有矢量基础。

阴爻：

```text
━━  ━━
```

阳爻：

```text
━━━━━━
```

动爻符号继续使用矢量：

```text
老阴 -> 空心圆
老阳 -> X
```

不得用 Unicode `○` / `×` 作为最终 UI 图标。

---

## 12. 世 / 应

世应必须贴近对应主卦或变卦爻位，不能漂到看不出对应哪一行。

状态颜色：

```text
Text / marker
低饱和强调
```

不使用大红色块。

---

## 13. 关系焦点

RelationFocusCard 不是普通推荐卡。

它是：

```text
当前排盘
↓
人工继续审卦的入口
```

首轮至少展示：

```text
世应关系
生克关系
回头生 / 回头克
查看规则依据
```

后续真实数据接入后：

```text
focusedLine
focusedRelations
```

必须来自现有 `RelationInstance`。

不得用字符串重新解析关系。

---

## 14. 关系备注

若本轮已经能接到 RelationNote：

Relation Focus 中可展示：

```text
已有备注
```

以及入口：

```text
查看 / 编辑备注
```

但本轮不得为了这一页自行发明第二个 NoteStore。

必须复用现有：

```text
(caseId + RelationKey)
```

语义。

---

## 15. App Shell / Bottom Navigation

必须保持 5 项：

```text
排卦
审卦
关系
卦例
训练
```

审卦页激活：

```text
审卦
```

排卦图标必须继续使用用户指定的 **艮卦矢量图标**。

禁止退回旧普通图标。

---

## 16. Responsive

SVG 基准宽度：

```text
402 content width
430 full screen width
```

但 Flutter 禁止硬编码页面宽度 430。

建议：

```text
horizontalPadding = 14
contentWidth = constraints.maxWidth - 28
```

手机宽度：

```text
360–520 DIP
```

均需正常。

排盘表不得发生横向出界。

若内容过长：

```text
优先紧凑字号 + Flexible/Expanded + 文本省略
```

不要直接加横向滚动条破坏阅读。

---

## 17. Scroll / SafeArea

页面主体：

```text
SingleChildScrollView
```

Bottom TabBar：

```text
固定在 App Shell
```

必须考虑：

```text
Status Bar
Display Cutout
Gesture Navigation Area
```

使用 SafeArea / MediaQuery 或现有 Shell。

---

## 18. 开发顺序

每轮报告必须带以下 TODO，并维护实时状态：

```text
T0  PRECHECK
T1  Audit current ReviewPage / App Shell / result models
T2  Reuse/add semantic XYUI tokens
T3  Implement ReviewAppBar
T4  Implement BasicInfoCard
T5  Implement ShenShaCard
T6  Implement FourPillarsStrip
T7  Implement HexagramResultHeader
T8  Implement HexagramResultTable
T9  Implement six-line row model/view adapter
T10 Implement vector yao / moving-line marks
T11 Implement RelationFocusCard
T12 Connect existing HexagramCase / LineState data
T13 Connect existing RelationInstance where available
T14 Verify MainTabBar 5 items + 艮卦 icon
T15 Widget/unit tests
T16 flutter analyze
T17 Android build
T18 Real-device readiness check
T19 Update audit docs
T20 Commit
T21 Push
T22 STOP FOR USER VISUAL REVIEW
```

状态符号：

```text
✅ complete
🟡 in progress
⏭ skipped with reason
❌ blocked/fail
```

不得使用陈旧 TODO。

---

## 19. PRECHECK

动代码前报告：

```text
branch
HEAD
origin HEAD
git status
ahead/behind

Flutter version
Dart version

Android device state
```

目标分支：

```text
feat/guayan-2.0
```

以当前真实仓库为准，不要写死旧 commit。

禁止：

```text
rebase
force push
history rewrite
merge
branch delete
tag
release
```

---

## 20. Android

继续：

```text
NO ANDROID EMULATOR
```

不得启动模拟器。

允许：

```text
flutter build apk
flutter analyze
flutter test
adb devices
```

如果真机没连：

```text
REAL DEVICE: NOT CONNECTED
```

如实报告即可。

---

## 21. Low-memory

继续保留当前仓库低内存 Flutter / Gradle 配置。

不得：

```text
擅自提高超大 JVM heap
删除 low-memory 配置
并行启动多个 Gradle daemon
```

---

## 22. 测试最低覆盖

### A · 神煞

输入多个神煞：

```text
Wrap 无溢出
所有项可见
```

### B · 四柱

必须存在：

```text
年
月
日
时
旬空
```

### C · 六爻

必须渲染：

```text
6 rows
```

且：

```text
上爻在最上
初爻在最下
```

### D · 阴阳

阴爻：

```text
断线
```

阳爻：

```text
实线
```

### E · 动爻

moving line：

```text
老阴 / 老阳 marker 正确
```

### F · 世应

对应行显示正确。

### G · Relation Focus

已有 RelationInstance 时：

```text
可得到当前焦点关系
```

不得字符串重新计算。

### H · MainTabBar

必须：

```text
5 items
```

含：

```text
训练
```

排卦 icon：

```text
艮卦 VECTOR
```

---

## 23. 视觉验收重点

真机截图必须重点检查：

```text
A 神煞是否整齐
B 神煞是否有拥挤或文字溢出

C 年月日时旬空是否一眼可见

D 主卦和变卦是否明显分区
E 六行是否完整
F 六神是否对应正确行
G 伏神是否不会压主卦内容
H 世应是否清楚
I 动爻标识是否清楚
J 主变卦文字是否挤压

K 页面是不是可自然纵向滚动
L BottomBar 是否固定
M 是否有 Material 默认味
N 是否仍然符合 XYUI 浅色低饱和风格
```

---

## 24. 文件范围

原则上只修改：

```text
review presentation
shared navigation
necessary UI token
view adapter
directly related tests
audit docs
```

禁止顺手：

```text
Relation engine 大重构
Hexagram identity 修改
RuleVersion 语义修改
DB migration
新状态管理框架
新 UI library
Training 系统重构
```

如果必须跨越边界：

```text
STOP
REPORT
```

---

## 25. 停止条件

出现任一情况停止：

```text
需要修改 Stable Relation Identity
需要修改 HexagramCase identity
需要重新定义 RuleId / RuleVersion
需要数据库迁移
需要完整自定义规则 CRUD
需要引入新 UI dependency
连续两次修复仍失败
任务范围明显扩张
```

---

## 26. 完成报告模板

```text
GUAYAN-2.0 · REVIEW UI R1 REPORT

TODO
T0 ...
...
T22 ...

BRANCH
...

BEFORE
...

AFTER
...

FILES CHANGED
...

UI COMPONENTS
ReviewAppBar            PASS/FAIL
BasicInfoCard           PASS/FAIL
ShenShaCard             PASS/FAIL
FourPillarsStrip        PASS/FAIL
HexagramResultHeader    PASS/FAIL
HexagramResultTable     PASS/FAIL
RelationFocusCard       PASS/FAIL
MainTabBar              PASS/FAIL

TRADITIONAL ELEMENTS
方式
事项
阳历
阴历
神煞
四柱
旬空
六神
伏神
六亲
主卦
变卦
世
应
动爻

TEST
...

ANALYZE
...

ANDROID BUILD
...

REAL DEVICE
CONNECTED / NOT CONNECTED

GIT
LOCAL HEAD
REMOTE HEAD
AHEAD / BEHIND
WORKTREE

VISUAL
AWAITING USER REVIEW
```

---

## 27. Definition of Done

```text
[ ] 审卦页不再是普通占位页
[ ] 基本信息完整
[ ] 神煞为独立网格/Wrap
[ ] 神煞无溢出
[ ] 年月日时旬空完整
[ ] 主卦标题完整
[ ] 变卦标题完整
[ ] 六神完整
[ ] 伏神完整
[ ] 六爻六行完整
[ ] 阴阳爻绘制正确
[ ] 动爻标记为矢量
[ ] 世应位置正确
[ ] 关系焦点存在
[ ] 可承接 RelationInstance
[ ] BottomBar 五项完整
[ ] 训练存在
[ ] 排卦为艮卦矢量 icon
[ ] 页面支持纵向滚动
[ ] BottomBar 固定
[ ] 无 Android Emulator
[ ] tests pass
[ ] analyze pass
[ ] Android build pass
[ ] audit docs updated
[ ] commit
[ ] push
[ ] local == remote
[ ] worktree clean
```

最终：

```text
STOP.

GUAYAN-2.0
REVIEW PAGE XYUI R1
READY FOR USER VISUAL REVIEW
```

---

# 28. 强制视觉 SVG

以下 SVG 为本轮实现的直接视觉基准。
Codex 不得自行改成其它 Material 风格。



## 01 · ReviewAppBar

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="430" height="54" viewBox="0 0 430 54">
  <defs>
    <style>
      .title{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:18px;font-weight:700;fill:#243744}
      .tiny{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:9px;fill:#7C8D94}
      .divider{stroke:#E5ECE8;stroke-width:1}
    </style>
  </defs>

  <rect width="430" height="54" fill="#FFFFFF"/>
  <line x1="0" y1="53.5" x2="430" y2="53.5" class="divider"/>

  <line x1="24" y1="27" x2="36" y2="15" stroke="#405E6C" stroke-width="2.2" stroke-linecap="round"/>
  <line x1="24" y1="27" x2="36" y2="39" stroke="#405E6C" stroke-width="2.2" stroke-linecap="round"/>

  <text x="215" y="33" text-anchor="middle" class="title">审卦</text>
  <text x="215" y="47" text-anchor="middle" class="tiny">排盘结果</text>
</svg>
```


## 02 · BasicInfoCard

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="132" viewBox="0 0 402 132">
  <defs>
    <style>
      .surface{fill:#FFFFFF;stroke:#DCE5E1;stroke-width:1}
      .h2{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:14px;font-weight:700;fill:#243744}
      .body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;fill:#405E6C}
      .strong{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#243744}
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
    </style>
  </defs>

  <rect x="0.5" y="0.5" width="401" height="131" rx="12" class="surface"/>

  <text x="14" y="26" class="h2">方式</text>
  <text x="60" y="26" class="body">铜钱手动</text>

  <rect x="322" y="10" width="62" height="22" rx="11" fill="#E6F0EB" stroke="#83A491"/>
  <text x="353" y="25" text-anchor="middle" class="small">已生成</text>

  <text x="14" y="56" class="h2">事项</text>
  <text x="60" y="56" class="strong">我的正缘什么时候出现？</text>

  <text x="14" y="86" class="h2">时间</text>
  <text x="60" y="86" class="body">阳历：2026-08-30 17:59</text>
  <text x="60" y="106" class="body">阴历：二零二六年七月十八日 酉时</text>
</svg>
```


## 03 · ShenShaCard

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="162" viewBox="0 0 402 162">
  <defs>
    <style>
      .surface{fill:#FFFFFF;stroke:#DCE5E1;stroke-width:1}
      .chip{fill:#F3F7F5;stroke:#D6E1DC;stroke-width:1}
      .h2{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:14px;font-weight:700;fill:#243744}
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
    </style>
  </defs>

  <rect x="0.5" y="0.5" width="401" height="161" rx="12" class="surface"/>

  <text x="14" y="26" class="h2">神煞</text>
  <text x="68" y="26" class="small">按标签分组显示</text>

  <rect x="14" y="42" width="82" height="24" rx="12" class="chip"/>
  <text x="55" y="58" text-anchor="middle" class="small">卦身：申</text>

  <rect x="102" y="42" width="92" height="24" rx="12" class="chip"/>
  <text x="148" y="58" text-anchor="middle" class="small">香闺：寅卯</text>

  <rect x="200" y="42" width="92" height="24" rx="12" class="chip"/>
  <text x="246" y="58" text-anchor="middle" class="small">床帐：子亥</text>

  <rect x="298" y="42" width="86" height="24" rx="12" class="chip"/>
  <text x="341" y="58" text-anchor="middle" class="small">驿马：寅</text>

  <rect x="14" y="76" width="82" height="24" rx="12" class="chip"/>
  <text x="55" y="92" text-anchor="middle" class="small">桃花：酉</text>

  <rect x="102" y="76" width="82" height="24" rx="12" class="chip"/>
  <text x="143" y="92" text-anchor="middle" class="small">华盖：辰</text>

  <rect x="190" y="76" width="92" height="24" rx="12" class="chip"/>
  <text x="236" y="92" text-anchor="middle" class="small">贵人：酉亥</text>

  <rect x="288" y="76" width="96" height="24" rx="12" class="chip"/>
  <text x="336" y="92" text-anchor="middle" class="small">天喜：酉</text>

  <rect x="14" y="110" width="82" height="24" rx="12" class="chip"/>
  <text x="55" y="126" text-anchor="middle" class="small">天医：未</text>

  <rect x="102" y="110" width="82" height="24" rx="12" class="chip"/>
  <text x="143" y="126" text-anchor="middle" class="small">文昌：申</text>

  <rect x="190" y="110" width="82" height="24" rx="12" class="chip"/>
  <text x="231" y="126" text-anchor="middle" class="small">劫煞：巳</text>

  <rect x="278" y="110" width="106" height="24" rx="12" class="chip"/>
  <text x="331" y="126" text-anchor="middle" class="small">灾煞：午</text>

  <rect x="14" y="144" width="82" height="24" rx="12" class="chip"/>
  <text x="55" y="160" text-anchor="middle" class="small">金舆：未</text>

  <rect x="102" y="144" width="82" height="24" rx="12" class="chip"/>
  <text x="143" y="160" text-anchor="middle" class="small">亡神：亥</text>

  <rect x="190" y="144" width="92" height="24" rx="12" class="chip"/>
  <text x="236" y="160" text-anchor="middle" class="small">将星：子</text>

  <rect x="288" y="144" width="96" height="24" rx="12" class="chip"/>
  <text x="336" y="160" text-anchor="middle" class="small">羊刃：午</text>
</svg>
```


## 04 · FourPillarsStrip

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="58" viewBox="0 0 402 58">
  <defs>
    <style>
      .surface{fill:#FFFFFF;stroke:#DCE5E1;stroke-width:1}
      .teal{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#4F8A8B}
      .red{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#B66F6F}
    </style>
  </defs>

  <rect x="0.5" y="0.5" width="401" height="57" rx="10" class="surface"/>

  <text x="48" y="35" text-anchor="middle" class="teal">丙午年</text>
  <text x="143" y="35" text-anchor="middle" class="red">丙申月</text>
  <text x="238" y="35" text-anchor="middle" class="red">丙子日</text>
  <text x="320" y="35" text-anchor="middle" class="teal">丁酉时</text>
  <text x="392" y="35" text-anchor="end" class="teal">(申酉空)</text>
</svg>
```


## 05 · HexagramResultHeader

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="98" viewBox="0 0 402 98">
  <defs>
    <style>
      .surface{fill:#FFFFFF;stroke:#DCE5E1;stroke-width:1}
      .h2{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:14px;font-weight:700;fill:#243744}
      .strong{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#243744}
      .gold{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#B0905F}
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
      .divider{stroke:#E5ECE8;stroke-width:1}
    </style>
  </defs>

  <rect x="0.5" y="0.5" width="401" height="97" rx="12" class="surface"/>

  <text x="14" y="26" class="h2">排盘结果</text>

  <rect x="312" y="12" width="72" height="24" rx="12" fill="#E6F0EB" stroke="#83A491"/>
  <text x="348" y="28" text-anchor="middle" class="small">完整排盘</text>

  <text x="124" y="60" text-anchor="middle" class="strong">主卦</text>
  <text x="124" y="82" text-anchor="middle" class="gold">兑4 · 泽山咸</text>

  <text x="300" y="60" text-anchor="middle" class="strong">变卦</text>
  <text x="300" y="82" text-anchor="middle" class="gold">兑2 · 泽水困 · 六合卦</text>

  <line x1="10" y1="96" x2="392" y2="96" class="divider"/>
</svg>
```


## 06 · HexagramResultTable

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="492" viewBox="0 0 402 492">
  <defs>
    <style>
      .surface{fill:#FFFFFF;stroke:#DCE5E1;stroke-width:1}
      .body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;fill:#405E6C}
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
      .tiny{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:9px;fill:#7C8D94}
      .gold{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#B0905F}
      .red{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#B66F6F}
      .teal{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#4F8A8B}
      .divider{stroke:#E5ECE8;stroke-width:1}
      .yao{stroke:#243744;stroke-width:3.8;stroke-linecap:square}
    </style>
  </defs>

  <rect x="0.5" y="0.5" width="401" height="491" rx="12" class="surface"/>

  <text x="14" y="24" class="tiny">六神</text>
  <text x="68" y="24" class="tiny">主卦（含伏神）</text>
  <text x="256" y="24" class="tiny">变卦</text>

  <line x1="10" y1="36" x2="392" y2="36" class="divider"/>

  <!-- Row 1 -->
  <text x="14" y="66" class="gold">青龙</text>
  <text x="68" y="58" class="small">伏：财丙寅　父丁未</text>
  <text x="68" y="78" class="body">父母丁未土（天河水）</text>
  <line x1="186" y1="90" x2="202" y2="90" class="yao"/>
  <line x1="212" y1="90" x2="228" y2="90" class="yao"/>
  <text x="236" y="94" class="red">应</text>
  <text x="256" y="78" class="body">父母丁未土（天河水）</text>
  <line x1="350" y1="90" x2="364" y2="90" class="yao"/>
  <line x1="374" y1="90" x2="388" y2="90" class="yao"/>

  <line x1="10" y1="108" x2="392" y2="108" class="divider"/>

  <!-- Row 2 -->
  <text x="14" y="138" class="gold">玄武</text>
  <text x="68" y="130" class="small">伏：孙丙子　兄丁酉</text>
  <text x="68" y="150" class="body">兄弟丁酉金（山下火）</text>
  <line x1="186" y1="162" x2="202" y2="162" class="yao"/>
  <line x1="212" y1="162" x2="228" y2="162" class="yao"/>
  <text x="256" y="150" class="body">兄弟丁酉金（山下火）</text>
  <line x1="350" y1="162" x2="364" y2="162" class="yao"/>
  <line x1="374" y1="162" x2="388" y2="162" class="yao"/>

  <line x1="10" y1="180" x2="392" y2="180" class="divider"/>

  <!-- Row 3 -->
  <text x="14" y="210" class="gold">白虎</text>
  <text x="68" y="202" class="small">伏：父戊戌　孙丁亥</text>
  <text x="68" y="222" class="body">子孙丁亥水（屋上土）</text>
  <line x1="186" y1="234" x2="226" y2="234" class="yao"/>
  <text x="256" y="222" class="body">子孙丁亥水（屋上土）</text>
  <line x1="350" y1="234" x2="390" y2="234" class="yao"/>
  <text x="392" y="238" class="red">应</text>

  <line x1="10" y1="252" x2="392" y2="252" class="divider"/>

  <!-- Row 4 -->
  <text x="14" y="282" class="gold">腾蛇</text>
  <text x="68" y="274" class="small">伏：兄丙申　父丁丑</text>
  <text x="68" y="294" class="body">兄弟丙申金（山下火）</text>
  <line x1="186" y1="306" x2="202" y2="306" class="yao"/>
  <line x1="212" y1="306" x2="228" y2="306" class="yao"/>
  <text x="234" y="310" class="red">世</text>
  <text x="250" y="310" class="teal">○→</text>
  <text x="278" y="294" class="body">官鬼戊午火（天上火）</text>
  <line x1="358" y1="306" x2="372" y2="306" class="yao"/>
  <line x1="382" y1="306" x2="396" y2="306" class="yao"/>

  <line x1="10" y1="324" x2="392" y2="324" class="divider"/>

  <!-- Row 5 -->
  <text x="14" y="354" class="gold">勾陈</text>
  <text x="68" y="346" class="small">伏：官丙午　财丁卯</text>
  <text x="68" y="366" class="body">官鬼丙午火（天河水）</text>
  <line x1="186" y1="378" x2="202" y2="378" class="yao"/>
  <line x1="212" y1="378" x2="228" y2="378" class="yao"/>
  <text x="250" y="382" class="teal">X→</text>
  <text x="278" y="366" class="body">父母戊辰土（大林木）</text>
  <line x1="358" y1="378" x2="398" y2="378" class="yao"/>

  <line x1="10" y1="396" x2="392" y2="396" class="divider"/>

  <!-- Row 6 -->
  <text x="14" y="426" class="gold">朱雀</text>
  <text x="68" y="418" class="small">伏：父丙辰　官丁巳</text>
  <text x="68" y="438" class="body">父母丙辰土（沙中土）</text>
  <line x1="186" y1="450" x2="202" y2="450" class="yao"/>
  <line x1="212" y1="450" x2="228" y2="450" class="yao"/>
  <text x="256" y="438" class="body">妻财戊寅木（城头土）</text>
  <line x1="350" y1="450" x2="364" y2="450" class="yao"/>
  <line x1="374" y1="450" x2="388" y2="450" class="yao"/>
  <text x="390" y="454" class="red">世</text>

  <text x="14" y="480" class="small">传统排盘完整展示；关系连线与规则依据在焦点区继续展开。</text>
</svg>
```


## 07 · RelationFocusCard

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="402" height="114" viewBox="0 0 402 114">
  <defs>
    <style>
      .active{fill:#EEF5F1;stroke:#91AC9D;stroke-width:1.2}
      .chipR{fill:#FAEFEF;stroke:#D9ABAB;stroke-width:1}
      .chipB{fill:#EEF3F7;stroke:#AFC0CF;stroke-width:1}
      .h2{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:14px;font-weight:700;fill:#243744}
      .body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;fill:#405E6C}
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
    </style>
  </defs>

  <rect x="0.6" y="0.6" width="400.8" height="112.8" rx="10" class="active"/>

  <text x="14" y="26" class="h2">关系焦点</text>
  <text x="14" y="48" class="body">世爻发动，化官鬼午火；当前建议优先继续查看：</text>

  <rect x="14" y="62" width="78" height="24" rx="12" class="chipR"/>
  <text x="53" y="78" text-anchor="middle" class="small">世应关系</text>

  <rect x="100" y="62" width="78" height="24" rx="12" class="chipR"/>
  <text x="139" y="78" text-anchor="middle" class="small">生克关系</text>

  <rect x="186" y="62" width="92" height="24" rx="12" class="chipR"/>
  <text x="232" y="78" text-anchor="middle" class="small">回头生回头克</text>

  <rect x="286" y="62" width="98" height="24" rx="12" class="chipB"/>
  <text x="335" y="78" text-anchor="middle" class="small">查看规则依据 ›</text>
</svg>
```


## 08 · MainTabBar

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="430" height="56" viewBox="0 0 430 56">
  <defs>
    <style>
      .small{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:10px;fill:#71838B}
      .strong{font-family:"Microsoft YaHei","PingFang SC",sans-serif;font-size:12px;font-weight:700;fill:#243744}
      .divider{stroke:#E5ECE8;stroke-width:1}
    </style>
  </defs>

  <rect width="430" height="56" fill="#FFFFFF"/>
  <line x1="0" y1="0.5" x2="430" y2="0.5" class="divider"/>

  <!-- 排卦：艮卦 -->
  <line x1="36" y1="18" x2="56" y2="18" stroke="#71838B" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="36" y1="24" x2="44" y2="24" stroke="#71838B" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="48" y1="24" x2="56" y2="24" stroke="#71838B" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="36" y1="30" x2="44" y2="30" stroke="#71838B" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="48" y1="30" x2="56" y2="30" stroke="#71838B" stroke-width="1.8" stroke-linecap="round"/>
  <text x="46" y="50" text-anchor="middle" class="small">排卦</text>

  <!-- 审卦 ACTIVE -->
  <rect x="101" y="8" width="52" height="30" rx="15" fill="#E6F0EB"/>
  <ellipse cx="127" cy="23" rx="9" ry="6" fill="none" stroke="#567866" stroke-width="1.8"/>
  <circle cx="127" cy="23" r="2.3" fill="#567866"/>
  <text x="127" y="50" text-anchor="middle" class="strong">审卦</text>

  <!-- 关系 -->
  <circle cx="207" cy="20" r="4" fill="#71838B"/>
  <circle cx="223" cy="12" r="4" fill="#71838B"/>
  <circle cx="227" cy="28" r="4" fill="#71838B"/>
  <line x1="211" y1="18" x2="219" y2="14" stroke="#71838B" stroke-width="1.3"/>
  <line x1="211" y1="22" x2="223" y2="27" stroke="#71838B" stroke-width="1.3"/>
  <text x="217" y="50" text-anchor="middle" class="small">关系</text>

  <!-- 卦例 -->
  <rect x="284" y="14" width="20" height="22" rx="2" fill="none" stroke="#71838B" stroke-width="1.4"/>
  <line x1="288" y1="20" x2="300" y2="20" stroke="#71838B"/>
  <line x1="288" y1="25" x2="300" y2="25" stroke="#71838B"/>
  <line x1="288" y1="30" x2="297" y2="30" stroke="#71838B"/>
  <text x="294" y="50" text-anchor="middle" class="small">卦例</text>

  <!-- 训练 -->
  <path d="M360 20L370 15L380 20L370 25L360 20Z" fill="none" stroke="#71838B" stroke-width="1.6" stroke-linejoin="round"/>
  <path d="M364 23V29C364 31 367 33 370 33C373 33 376 31 376 29V23" fill="none" stroke="#71838B" stroke-width="1.4" stroke-linecap="round"/>
  <line x1="380" y1="20" x2="380" y2="28" stroke="#71838B" stroke-width="1.4"/>
  <circle cx="380" cy="30" r="1.7" fill="#71838B"/>
  <text x="370" y="50" text-anchor="middle" class="small">训练</text>
</svg>
```
