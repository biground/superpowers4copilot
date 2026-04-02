---
agent: agent
description: "分派代码审查代理，获取结构化的改进建议 (dispatch code review agent for structured feedback)"
---

# 请求代码审查

主要开发步骤完成后使用。分派 code-reviewer 子代理进行全面审查，在问题蔓延前捕获。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [请求代码审查技能](skills/requesting-code-review/SKILL.md)

VS Code Copilot Chat 工具映射参考：
- [工具映射](skills/using-superpowers/references/copilot-chat-tools.md)

> 如果上述链接未自动加载内容，请使用 `read_file` 手动读取对应路径的文件。

## 关键工具指引

- **获取变更信息**：使用 `run_in_terminal` 运行 `git diff`、`git rev-parse` 获取 SHA
- **分派审查代理**：使用 `runSubagent` 分派 code-reviewer 子代理
- **读取审查模板**：使用 `read_file` 读取 skills/requesting-code-review/code-reviewer.md 模板
- **任务跟踪**：使用 `manage_todo_list` 跟踪审查反馈的处理状态

## 核心纪律

审查者获得精心构建的评估上下文——而非你的会话历史。尽早审查，频繁审查。

## 立即开始

收集当前变更信息（diff、SHA），准备分派审查代理。
