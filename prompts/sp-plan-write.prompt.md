---
agent: agent
description: "从规格文档创建细粒度的分步实施计划 (create detailed step-by-step implementation plan from spec)"
---

# 编写实施计划

有规范或需求文档需要转化为可执行的分步计划时使用。生成的计划假设执行者对代码库完全没有上下文。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [编写计划技能](skills/writing-plans/SKILL.md)

VS Code Copilot Chat 工具映射参考：
- [工具映射](skills/using-superpowers/references/copilot-chat-tools.md)

> 如果上述链接未自动加载内容，请使用 `read_file` 手动读取对应路径的文件。

## 关键工具指引

- **读取 spec**：使用 `read_file` 读取规格文档
- **探索代码库**：使用 `file_search`、`grep_search`、`semantic_search` 了解现有结构
- **任务跟踪**：使用 `manage_todo_list` 跟踪计划编写进度

## 核心纪律

每一步都必须包含实际内容——精确文件路径、完整代码块、验证命令和预期输出。禁止 TBD、TODO 或占位符。

## 立即开始

询问用户 spec 文件位置，开始编写实施计划。
