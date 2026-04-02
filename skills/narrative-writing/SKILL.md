---
name: narrative-writing
description: Use when writing personal technical notes, learning summaries, decision records, or retrospectives for Obsidian. Defines the narrative arc, Obsidian format standards, and quality checklist for storytelling-style technical writing.
---

# 叙事型技术写作

## 概述

将技术经验和学习转化为引人入胜、有洞察力的个人笔记。使用叙事弧线（场景→冲突→探索→发现→总结）代替流水账式罗列。

**开始时宣告：** "我正在使用 narrative-writing 技能来创建叙事笔记。"

**配套 Agent：** `narrative-writer` — 为此技能设计的专业 agent。

## 核心原则

> **写故事，不写流水账。**

读者（未来的自己）需要的不是"发生了什么"，而是"我学到了什么、为什么重要、下次怎么用"。

## 叙事弧线模板

### 1. 场景引入（Scene）
设定情境。用一个具体场景开头，不用抽象定义。

```markdown
上周在给 API 加缓存时，发现 Redis 的淘汰策略比想象中复杂得多。
```

**不要：** "Redis 是一个内存数据库，支持多种数据结构。"

### 2. 问题/冲突（Conflict）
引出核心矛盾。明确说出"我原以为…但实际上…"。

### 3. 探索过程（Exploration）
还原思考路径。展示弯路和失败尝试——它们帮助避免重复。

### 4. 关键发现（Discovery）
先给直觉理解，再展开技术细节。用类比和具体例子。

### 5. 可操作总结（Actionable Summary）
2-5 条具体可执行的要点。使用 Obsidian callout：

```markdown
> [!tip] 下次遇到类似问题
> 1. 先确认缓存淘汰策略是否匹配业务场景
> 2. 用 `redis-cli INFO` 检查 eviction 统计
> 3. 压测时观察 hit rate 变化曲线
```

## Obsidian 格式规范

### 必需的 YAML Frontmatter

```yaml
---
date: YYYY-MM-DD
tags: [topic1, topic2]
type: learning | decision | retrospective | concept
status: draft | reviewed
---
```

### 格式元素

| 元素 | 用法 | 必需 |
|------|------|------|
| `[[wikilinks]]` | 连接相关笔记 | 每篇至少 1 个 |
| `#tags` | 分类（在 frontmatter 中定义）| 每篇至少 2 个 |
| `> [!tip]` | 突出关键发现 | 每篇至少 1 个 |
| `> [!warning]` | 标注陷阱/注意事项 | 可选 |
| 代码块 | 关键概念配代码示例 | 技术笔记必需 |

### 笔记类型

| 类型 | 适用场景 | 叙事重点 |
|------|---------|----------|
| `learning` | 学习/读书笔记 | 从困惑到理解的过程 |
| `decision` | 技术方案/决策记录 | 方案对比和选择理由 |
| `retrospective` | 项目复盘 | 做对了什么、下次改进什么 |
| `concept` | 概念解释 | 用最简单的方式解释复杂概念 |

## 质量检查清单

写完后逐项检查：

- [ ] 有没有流水账段落？（按时间罗列 → 应按 insight 组织）
- [ ] 核心 insight 是否在前 3 段内出现？
- [ ] 可操作总结是否可以独立阅读？（不需要重读全文）
- [ ] 是否有至少 1 个 `[[wikilink]]` 连接相关笔记？
- [ ] YAML frontmatter 是否完整（date, tags, type, status）？
- [ ] 技术术语是否保留英文？（避免生硬翻译）
- [ ] 每段是否只有一个核心观点？
- [ ] 是否用了 callout block 突出关键发现？

## Anti-patterns vs 正确做法

| 坏习惯 | 正确做法 |
|--------|---------|
| "首先…然后…接着…最后…" | "核心发现是…因为…具体来说…" |
| 堆砌所有细节 | 只保留服务于理解的细节 |
| 全文平铺无重点 | callout blocks + 加粗突出关键句 |
| 纯文字描述代码逻辑 | 直接给代码片段 + 注释 |
| 孤立笔记 | `[[wikilinks]]` 建立知识网络 |
| "缓存失效" 可以，"贮藏失效" 不行 | 保留英文术语，中文行文 |

## 示例笔记模板

```markdown
---
date: 2026-04-02
tags: [redis, caching, performance]
type: learning
status: draft
---

# Redis 淘汰策略：不只是 LRU 那么简单

上周在给用户 API 加缓存时，线上突然出现大量 cache miss。排查后发现，问题不在代码，而在 Redis 的淘汰策略选择上。

## 我原以为……

设置了 `maxmemory-policy allkeys-lru` 就万事大吉。LRU 嘛，最近最少使用的先淘汰，听起来完美。

但实际上，Redis 的 LRU 是**近似 LRU**——它只从随机采样的 key 中选最旧的淘汰，而不是真正追踪所有 key 的访问时间。

## 探索：为什么 hit rate 这么低？

我用 `redis-cli INFO stats` 看了 eviction 相关指标……

（探索过程省略）

## 原来如此

Redis 6.0+ 的 `allkeys-lfu` 策略更适合我们的场景，因为……

> [!tip] 下次遇到 Redis 缓存问题
> 1. 先用 `INFO stats` 检查 keyspace_hits/misses 比率
> 2. 确认 maxmemory-policy 是否匹配访问模式（LRU vs LFU）
> 3. 调整 `lfu-log-factor` 参数优化频率计数精度

## 相关笔记
- [[Redis 性能调优]]
- [[缓存设计模式]]
```

## 集成

**配套 Agent：**
- **narrative-writer** — 专为此技能设计，使用 Obsidian MCP 工具

**工具依赖：**
- Obsidian MCP server — 笔记读写操作
- `read_file` / `fetch_webpage` — 读取参考资料

**写作三层分工：**
- **gem-documentation-writer** — 代码文档（API docs, README）
- **se-technical-writer** — 发布型技术内容（博客、教程、ADR）
- **narrative-writer** — 个人知识管理（学习笔记、决策记录、复盘）
