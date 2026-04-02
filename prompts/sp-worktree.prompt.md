---
agent: agent
description: "使用 Git Worktree 创建隔离工作区，并行开发多个功能分支 (create isolated workspace with Git Worktree)"
---

# Git Worktree 管理

需要在隔离环境中进行开发时使用。创建共享同一仓库的隔离工作区，允许同时在多个分支上工作。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/using-git-worktrees/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **Git 操作**：使用 `run_in_terminal` 执行 git worktree 命令
- **安全验证**：使用 `run_in_terminal` 运行 `git check-ignore` 验证目录已被忽略
- **项目设置**：使用 `run_in_terminal` 在新 worktree 中运行项目安装命令

## 核心纪律

系统化的目录选择 + 安全验证 = 可靠的隔离。创建 worktree 后必须验证项目能正常构建和测试。

## 立即开始

询问用户需要的分支名称和功能描述。
