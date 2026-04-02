---
agent: agent
description: "通过结构化的苏格拉底式对话，对功能设计进行头脑风暴与细化 (brainstorm and refine a feature design)"
---

# 头脑风暴 — 从想法到设计

在任何创意性工作之前——创建功能、构建组件、添加功能或修改行为——先使用此工作流探索意图、需求和设计。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [头脑风暴技能](skills/brainstorming/SKILL.md)

VS Code Copilot Chat 工具映射参考：
- [工具映射](skills/using-superpowers/references/copilot-chat-tools.md)

> 如果上述链接未自动加载内容，请使用 `read_file` 手动读取对应路径的文件。

## 关键工具指引

- **提问**：使用 `vscode_askQuestions` 逐个提问（选择题优先），不要用纯文本列选项
- **任务跟踪**：使用 `manage_todo_list` 跟踪检查清单（探索上下文 → 澄清 → 方案 → 设计 → spec → 自审 → 审阅 → 过渡到实施）
- **分派子代理**：如需分派子代理，使用 `runSubagent`
- **文件操作**：读文件用 `read_file`，搜索用 `grep_search` / `file_search`

## 核心纪律

在展示设计方案并获得用户批准之前，**不要**编写任何代码或采取任何实现行动。

## 立即开始

现在就与用户开始 brainstorming 工作流。
