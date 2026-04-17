# Superpowers for Copilot

> 融合 [Superpowers](https://github.com/obra/superpowers) 技能体系与 [gem-team](https://github.com/mubaidr/gem-team) 多代理编排的 VS Code Copilot 中文定制版。

Superpowers for Copilot 将 Superpowers 的技能工作流与 gem-team 的多代理编排能力结合，为 VS Code GitHub Copilot 提供完整的 AI 驱动软件开发体验。

核心理念：**你不需要手动编排代理**。通过 `@gem-orchestrator` 发起任务，它会自动检测阶段、分派专业代理、综合结果、循环迭代——直到任务完成。

## 工作原理

```
用户描述需求
  → gem-orchestrator 检测阶段
    → 讨论阶段：苏格拉底式提问，逐步明确需求
    → 研究阶段：gem-researcher 探索代码库（最多 4 个并行）
    → 规划阶段：gem-planner 生成 DAG 执行计划
    → 执行阶段：按波次分派 gem-implementer / gem-designer / ...
      → 每波次后 gem-reviewer 集成检查
      → 复杂项目额外触发 gem-critic 挑战性审查
    → 总结阶段：验证 + 证据 → 完成
```

你只需要和 `@gem-orchestrator` 对话。它处理所有的任务分解、代理调度、错误重试和质量把关。

## 安装

### 前提

- VS Code 或 VS Code Insiders
- GitHub Copilot 扩展

### 安装步骤

**1. 克隆仓库**

```bash
git clone https://github.com/biground/superpowers4copilot.git ~/.copilot/superpowers4copilot
```

**2. 运行安装脚本**

macOS / Linux:

```bash
cd ~/.copilot/superpowers4copilot

# VS Code
./install.sh

# VS Code Insiders
./install.sh --insiders
```

Windows (PowerShell):

```powershell
cd $HOME\.copilot\superpowers4copilot

# VS Code
.\install.ps1

# VS Code Insiders
.\install.ps1 -Insiders
```

安装脚本会将 prompt 文件、agents 和 skills 复制到 VS Code 用户目录的 `prompts/` 下。

### KiloCode 安装

**1. 克隆仓库**（同上）

**2. 运行安装脚本**

macOS / Linux:

```bash
cd ~/.copilot/superpowers4copilot
./install.sh --kilocode
```

Windows (PowerShell):

```powershell
cd $HOME\.copilot\superpowers4copilot
.\install.ps1 -Kilocode
```

安装脚本会将 agents、commands 和 skills 复制到 KiloCode 全局配置目录（`~/.kilo/`）。

### 卸载

```bash
# macOS / Linux
./install.sh --uninstall
./install.sh --kilocode --uninstall

# Windows
.\install.ps1 -Uninstall
.\install.ps1 -Kilocode -Uninstall
```

Windows (PowerShell):

```powershell
cd $HOME\.copilot\superpowers4copilot
.\install.ps1 -Kilocode
```

安装脚本会将 agents、commands 和 skills 复制到 KiloCode 全局配置目录（`~/.kilo/`）。

### 卸载

```bash
# macOS / Linux
./install.sh --uninstall
./install.sh --kilocode --uninstall

# Windows
.\install.ps1 -Uninstall
.\install.ps1 -Kilocode -Uninstall
```

### 更新

```bash
cd ~/.copilot/superpowers4copilot
git pull
./install.sh          # 或 ./install.sh --insiders
```

### 验证安装

在 Copilot Chat 中输入 `@gem-orchestrator 你好`，如果代理能正常响应并进入阶段检测，说明安装成功。

在 KiloCode 中输入 `@gem-orchestrator 你好`，如果代理能正常响应并进入阶段检测，说明安装成功。

在 KiloCode 中输入 `@gem-orchestrator 你好`，如果代理能正常响应并进入阶段检测，说明安装成功。

## 代理系统

### 编排入口

| 代理 | 触发方式 | 说明 |
|:-----|:---------|:-----|
| **gem-orchestrator** | `@gem-orchestrator` | 多代理编排主入口。自动检测阶段、分派任务、综合结果 |

### 专业代理

| 代理 | 说明 |
|:-----|:-----|
| **gem-planner** | DAG 执行计划生成，含波次调度和风险预分析 |
| **gem-implementer** | TDD 驱动代码实现（Red-Green-Refactor），兼端到端调试 |
| **gem-reviewer** | 自动化基线审查：安全扫描、构建验证、PRD 合规 |
| **gem-researcher** | 代码库探索、模式发现、依赖映射（最多 4 并行） |
| **gem-critic** | 假设挑战、边界分析、过度工程检测 |
| **gem-designer** | UI/UX 设计规格，组件 API，无障碍指南 |
| **gem-browser-tester** | Playwright 浏览器 E2E 测试 |
| **security-reviewer** | 深度安全审计：OWASP Top 10、secrets 检测、输入验证 |
| **performance-optimizer** | 性能分析：瓶颈定位、Bundle 优化、内存泄漏检测 |
| **a11y-architect** | 无障碍架构：WCAG 2.2 合规、屏幕阅读器支持 |
| **silent-failure-hunter** | 静默失败检测：空 catch、错误吞没、危险回退 |
| **gem-documentation-writer** | 代码文档（API docs、README） |
| **se-technical-writer** | 技术博客、教程、ADR |
| **narrative-writer** | Obsidian 叙事式学习笔记 |
| **code-reviewer** | 深度代码审查：架构对齐 + 设计模式 |

### 魔法关键词

在对话中使用以下关键词，orchestrator 会自动切换执行模式：

| 关键词 | 效果 |
|:-------|:-----|
| `autopilot` | 跳过讨论阶段，全自动执行 |
| `deep-interview` | 扩展讨论，问 5-8 个问题 |
| `fast` / `parallel` | 提高并行代理上限（4 → 6-8） |
| `debug` | 直接进入端到端诊断 + 修复 |
| `critique` | 触发假设挑战分析 |

## Slash 命令

在 Copilot Chat 中输入 `/` 触发，或在 KiloCode 中输入 `/` 触发：

| 命令 | 用途 |
|:-----|:-----|
| `/sp-brainstorm` | 头脑风暴 → 设计方案 |
| `/sp-debug` | 系统化调试 |
| `/sp-tdd` | 测试驱动开发 |
| `/sp-plan-write` | 编写实施计划 |
| `/sp-plan-exec` | 执行实施计划 |
| `/sp-subagent` | 子代理驱动开发 |
| `/sp-parallel` | 并行代理调度 |
| `/sp-worktree` | Git Worktree 管理 |
| `/sp-branch-finish` | 完成开发分支 |
| `/sp-code-review-req` | 请求代码审查 |
| `/sp-code-review-recv` | 接收代码审查 |

## 技能库

### 测试
- **test-driven-development** — RED-GREEN-REFACTOR 循环（含测试反模式参考）

### 调试
- **systematic-debugging** — 四阶段根因分析流程
- **verification-before-completion** — 完成前强制验证

### 协作
- **brainstorming** — 苏格拉底式设计精炼
- **writing-plans** — 详细实施计划
- **executing-plans** — 批量执行 + 人工检查点
- **dispatching-parallel-agents** — 并行代理调度
- **subagent-driven-development** — 快速迭代 + 双阶段审查
- **requesting-code-review** / **receiving-code-review** — 代码审查流程
- **using-git-worktrees** — 并行开发分支
- **finishing-a-development-branch** — 分支合并决策

### 元技能
- **writing-skills** — 编写新技能的最佳实践
- **using-superpowers** — 技能系统入门
- **narrative-writing** — Obsidian 叙事式笔记

## 设计哲学

- **测试驱动** — 先写测试，永远如此
- **系统化优于临时方案** — 流程优于猜测
- **复杂度控制** — 简洁是首要目标
- **证据优于声明** — 验证后才能声称完成
- **委派优于亲执** — orchestrator 绝不自己执行任务

## 上游关系

本项目融合了两个上游仓库，并定期同步更新：

| 上游 | 来源 | 贡献内容 |
|:-----|:-----|:---------|
| [obra/superpowers](https://github.com/obra/superpowers) | `upstream-sp` | 技能体系、TDD 工作流、调试方法论、brainstorming 流程 |
| [mubaidr/gem-team](https://github.com/mubaidr/gem-team) | `upstream-gem` | gem-* 多代理编排系统、orchestrator 协调框架 |
| [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | `upstream-gsd` | 项目管理方法论、上下文工程、状态持久化、门控系统 |

本项目在此基础上的增强：
- **中文本地化**（技能描述、安装脚本、交互提示）
- **VS Code Copilot 原生集成**（prompt 文件 + agents + skills）
- **自动上游监控**（GitHub Actions 每日检查更新，创建 Issue 通知）

## 许可证

MIT License — 详见 [LICENSE](LICENSE) 文件。

## 社区

上游社区：[Discord](https://discord.gg/Jd8Vphy9jq) · [Issues](https://github.com/obra/superpowers/issues)
