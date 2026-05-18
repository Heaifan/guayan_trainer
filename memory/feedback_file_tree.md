---
name: feedback-file-tree
description: Must update file-tree.md after EVERY code change that adds/deletes/renames files or changes version
metadata:
  type: feedback
---

每次修改代码后，必须同步更新 file-tree.md。

**Why:** 这是项目文档纪律的核心要求。过去多次遗漏导致用户反复纠正。

**How to apply:**
- 每次新增/删除/重命名文件 → 更新目录树 + 模块职责表
- 每次发版 → 更新版本号 + 更新日志 + 版本历史 + 最后编辑时间
- 最后编辑时间必须写实际系统时间（`date +"%Y-%m-%d %H:%M"`），不能写估计值
- 当前版本日志发布日期旁附上 GitHub Release 链接
- 按用户要求：file-tree.md 只保留当前版本 + 上一版的更新日志，其余删除
