---
agent: agent
description: "系统化处理代码审查反馈——验证、评估、技术性回应 (process code review feedback systematically)"
---

# 接收代码审查

收到代码审查反馈需要处理时使用。逐条验证反馈的技术正确性，实施合理建议，有理有据地反驳不合理建议。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/receiving-code-review/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **验证反馈**：使用 `read_file` 和 `grep_search` 对照代码库实际情况检查反馈
- **实施修改**：使用 `replace_string_in_file` 修改代码，使用 `run_in_terminal` 运行测试验证
- **任务跟踪**：使用 `manage_todo_list` 逐条跟踪反馈处理状态（接受/推回/讨论）

## 核心纪律

实施前先验证。假设前先提问。技术正确性优先于社交舒适度。禁止表演性肯定（"你说得太对了！"）。

## 立即开始

询问用户审查反馈的来源，开始逐条处理流程。
