---
agent: agent
description: "并行调度多个独立代理，最大化吞吐量 (dispatch parallel agents for independent tasks)"
---

# 并行代理调度

3 个及以上独立任务可同时进行时使用。识别不相互依赖的任务，并行分派专用代理。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/dispatching-parallel-agents/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **并行分派**：使用 `runSubagent` 同时派遣多个子代理（各代理指令自包含、范围聚焦）
- **任务跟踪**：使用 `manage_todo_list` 跟踪各代理的分派和完成状态
- **结果验证**：使用 `run_in_terminal` 运行测试确认各代理变更无冲突

## 核心纪律

每个代理的提示词必须：聚焦（一个明确的问题域）、自包含（所有必要上下文）、明确输出要求。

## 立即开始

分析当前任务中可并行的独立部分。
