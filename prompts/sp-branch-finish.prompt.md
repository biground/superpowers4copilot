---
agent: agent
description: "完成开发分支——验证、合并选项、清理 (finish development branch - verify, merge options, cleanup)"
---

# 完成开发分支

分支开发完成、准备合并时使用。验证测试通过后，提供结构化的合并/推送/清理选项。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/finishing-a-development-branch/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **运行测试**：使用 `run_in_terminal` 执行测试命令确认全部通过
- **Git 操作**：使用 `run_in_terminal` 执行 merge、push、pr create 等操作
- **呈现选项**：使用 `vscode_askQuestions` 提供 4 个结构化选项（本地合并 / 推送 PR / 保持现状 / 丢弃）
- **任务跟踪**：使用 `manage_todo_list` 跟踪验证和清理步骤

## 核心纪律

验证测试 → 呈现选项 → 执行选择 → 清理。必须在合并前确认所有测试通过。

## 立即开始

检查当前分支状态，运行测试验证。
