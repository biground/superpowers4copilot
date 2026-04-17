# KiloCode 工具映射

技能使用 Claude Code / Copilot 的工具名称。当你在 KiloCode 中执行技能时，请使用以下对应工具：

| 技能/Copilot 工具 | KiloCode 对应工具 | 说明 |
|---|---|---|
| `Read` / `read_file` | `read` | 读取文件内容（含目录、图片） |
| `Write` / `create_file` | `write` | 创建新文件或覆盖已有文件 |
| `Edit` / `replace_string_in_file` / `multi_replace_string_in_file` | `edit` | 替换已有文件中的文本 |
| `Bash` / `run_in_terminal` | `bash` | 在持久化终端会话中执行命令 |
| `Grep` / `grep_search` | `grep` | 按文本或正则表达式搜索文件内容 |
| `Glob` / `file_search` | `glob` | 按 glob 模式搜索文件路径 |
| `Skill` / `read_file`（技能） | `skill` | 调用技能 |
| `Task` / `runSubagent` | `task` | 分派子代理执行独立任务 |
| `TodoWrite` / `manage_todo_list` | `todowrite` | 管理待办事项列表，跟踪多步骤任务进度 |
| `WebFetch` / `fetch_webpage` | `webfetch` | 获取网页内容 |
| `WebSearch` | `websearch` | 搜索互联网 |
| `AskHuman` / `vscode_askQuestions` | `question` | 结构化提问（选择题/开放题） |
| `get_errors` | `bash`（运行 lint/typecheck） | 获取编译/lint 错误 |
| `semantic_search` | `grep` / `codesearch` | 语义搜索代码 |
| `list_dir` | `read`（目录） | 列出目录内容 |
| `view_image` | `read`（图片文件） | 查看图片文件 |
| `memory` | `bash`（读写文件） | 管理持久化记忆笔记 |
| `vscode_listCodeUsages` | `grep` | 查找代码引用 |

## 提问规范

在需要向用户提问或提供选项时，使用 `question` 工具，而非纯文本列出选项。这提供了结构化的选择界面。
