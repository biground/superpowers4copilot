---
agent: agent
description: "子代理驱动开发——每任务派遣独立子代理，两阶段审查确保质量 (subagent-driven development with two-phase review)"
---

# 子代理驱动开发

复杂多步骤任务时使用。为每个任务分派全新的子代理，完成后进行规格合规审查和代码质量审查。

## 加载技能

严格遵循以下技能文件中的完整工作流：
- [子代理驱动开发技能](skills/subagent-driven-development/SKILL.md)

VS Code Copilot Chat 工具映射参考：
- [工具映射](skills/using-superpowers/references/copilot-chat-tools.md)

> 如果上述链接未自动加载内容，请使用 `read_file` 手动读取对应路径的文件。

## 关键工具指引

- **分派子代理**：使用 `runSubagent` 派遣实现者、规格审查者、代码质量审查者
- **任务跟踪**：使用 `manage_todo_list` 跟踪每个任务的实现-审查循环
- **读取 prompt 模板**：使用 `read_file` 读取子代理 prompt 模板：
  - skills/subagent-driven-development/implementer-prompt.md
  - skills/subagent-driven-development/spec-reviewer-prompt.md
  - skills/subagent-driven-development/code-quality-reviewer-prompt.md

## 核心纪律

每个任务一个全新子代理 + 两阶段审查（规格合规 + 代码质量）= 高质量、快速迭代。

## 立即开始

分析当前任务并拆解为子代理任务。
