---
agent: agent
description: "加载并执行现有实施计划，逐步验证，批量执行并设检查点 (load and execute implementation plan with verification)"
---

# 执行实施计划

有现成的计划文档需要执行时使用。加载计划，批判性审查，逐步执行并验证每一步。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [执行计划技能](skills/executing-plans/SKILL.md)

VS Code Copilot Chat 工具映射参考：
- [工具映射](skills/using-superpowers/references/copilot-chat-tools.md)

> 如果上述链接未自动加载内容，请使用 `read_file` 手动读取对应路径的文件。

## 关键工具指引

- **读取计划**：使用 `read_file` 读取计划文件
- **任务跟踪**：使用 `manage_todo_list` 逐步跟踪执行进度（与计划中的步骤一一对应）
- **执行验证**：使用 `run_in_terminal` 运行验证命令，确认每步预期输出
- **分派子代理**：如需分派子代理执行独立任务，使用 `runSubagent`

## 核心纪律

每完成一步必须运行验证命令并确认输出。没有验证证据不得声称完成。

## 立即开始

询问用户计划文件位置，加载并开始执行。
