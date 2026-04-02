---
agent: agent
description: "系统化调试——先找根因再修复，拒绝随机猜测 (systematic debugging - find root cause before fixing)"
---

# 系统化调试

测试失败或行为异常且原因不明显时使用。遵循严格的根因调查流程，避免随机补丁。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/systematic-debugging/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **收集错误**：使用 `get_errors` 获取编译/lint 错误信息
- **复现问题**：使用 `run_in_terminal` 执行命令复现症状
- **追踪来源**：使用 `grep_search` 搜索错误相关代码、`read_file` 阅读相关文件
- **任务跟踪**：使用 `manage_todo_list` 跟踪调试阶段（根因调查 → 模式分析 → 假设测试 → 实施修复）

## 核心纪律

在没有完成根因调查之前，不得尝试任何修复。修复症状就是失败。

## 立即开始

询问用户描述遇到的问题症状，开始根因调查流程。
