项目代码规则 — AI 自动遵守

一、文件组织
文件大小
纯逻辑 .dart 文件不超过 150 行
超出必须拆分成多个文件，原文件保留为 barrel re-export
Flutter Widget（组件页）不受 150 行限制
文件夹命名
用具体功能名，禁止抽象名：factory、processor、handler、manager
✅ data/、pages/、services/、widgets/
❌ processors/、handlers/、utils/（作为文件夹名）
扁平优先
不设硬性文件数上限，不要为了凑数建子文件夹
两层嵌套足够：lib/module/file.dart

二、架构分层
依赖方向（单向）
data/ ← models/ ← services/ ← pages/ + widgets/
层级	职责	禁止依赖
data/	数据表、常量、纯映射	任何上层
models/	类型定义、数据结构	—
services/	业务逻辑、出题、存储	Flutter/Widget
pages/	页面组件、交互	—
widgets/	可复用组件	—
函数设计
纯函数优先：不修改外部状态，只返回结果
副作用收敛：只有 store/service 层写可变状态
返回结构化结果：让调用方按需取字段

三、命名规范
文件
.dart 逻辑文件：蛇形 snake_case.dart
Flutter Widget 文件：大驼峰 PascalCase.dart（目前先统一蛇形）
命名
类/枚举：大驼峰 PascalCase
函数/变量：小驼峰 camelCase
常量：大写蛇形 UPPER_SNAKE_CASE

四、文档纪律
file-tree.md
项目根目录维护一个 file-tree.md，结构同上。
必须更新的时机
发版 → 顶部版本号 + 更新日志 + 版本历史
新增/删除/重命名文件 → 目录树 + 模块职责
修改文件职责 → 模块职责表
最后编辑时间 → 改成当前系统时间

五、版本与构建
版本号
格式：v{major}.{minor}.{patch}
Android 版本同步维护 android/app/build.gradle 中的 versionCode 和 versionName
Git 提交
前缀：feat: / fix: / refactor: / docs: / perf:
描述 why，不拘泥 what
发版同时打 tag：git tag v{x.y.z}

六、禁止事项
禁止循环依赖
禁止在 Widget 中写复杂业务逻辑
禁止 data 层依赖 Flutter 框架
禁止使用大图表库（SVG/Dart 绘图够用）
禁止在同一个文件中混合多模块职责
