---
agent: agent
description: "测试驱动开发——先写测试再写实现，红-绿-重构循环 (test-driven development - red-green-refactor cycle)"
---

# 测试驱动开发

编写代码或实现功能时使用。严格遵循红-绿-重构循环：先写失败测试，再写最小实现，最后重构。

## 加载技能

使用 read_file 读取以下技能文件并严格遵循其完整工作流：
- skills/test-driven-development/SKILL.md

同时读取 VS Code Copilot Chat 工具映射作为参考：
- skills/using-superpowers/references/copilot-chat-tools.md

## 关键工具指引

- **运行测试**：使用 `run_in_terminal` 执行测试命令（npm test、pytest、cargo test 等）
- **任务跟踪**：使用 `manage_todo_list` 跟踪每个测试用例的红-绿-重构状态
- **搜索现有测试**：使用 `file_search` 查找已有测试文件，使用 `grep_search` 搜索测试模式

## 核心纪律

没有看到测试失败，就不能写生产代码。如果没有看到测试失败，你就不知道它是否测试了正确的东西。

## 立即开始

询问用户要实现的功能，开始 TDD 循环。
