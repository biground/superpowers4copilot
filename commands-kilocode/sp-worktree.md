---
description: "使用 Git Worktree 创建隔离工作区，并行开发多个功能分支"
---

# Git Worktree 管理

需要在隔离环境中进行开发时使用。创建共享同一仓库的隔离工作区，允许同时在多个分支上工作。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [Git Worktree 技能](skills/using-git-worktrees/SKILL.md)

KiloCode 工具映射参考：
- [工具映射](skills/using-superpowers/references/kilocode-tools.md)

> 如果上述链接未自动加载内容，请使用 `read` 手动读取对应路径的文件。

## 关键工具指引

- **Git 操作**：使用 `bash` 执行 git worktree 命令
- **安全验证**：使用 `bash` 运行 `git check-ignore` 验证目录已被忽略
- **项目设置**：使用 `bash` 在新 worktree 中运行项目安装命令

## 核心纪律

系统化的目录选择 + 安全验证 = 可靠的隔离。创建 worktree 后必须验证项目能正常构建和测试。

## 立即开始

询问用户需要的分支名称和功能描述。
