#!/usr/bin/env bash
# keep this installer in sync with install.ps1.
# Superpowers 中文版 - VS Code Copilot / KiloCode 安装脚本
# 用法: ./install.sh [--insiders] [--uninstall] [--kilocode]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析参数
INSIDERS=false
UNINSTALL=false
KILOCODE=false
for arg in "$@"; do
  case "$arg" in
    --insiders) INSIDERS=true ;;
    --uninstall) UNINSTALL=true ;;
    --kilocode) KILOCODE=true ;;
    --help|-h)
      echo "用法: ./install.sh [--insiders] [--uninstall] [--kilocode]"
      echo ""
      echo "选项:"
      echo "  --insiders    安装到 VS Code Insiders"
      echo "  --uninstall   卸载已安装的文件"
      echo "  --kilocode    安装到 KiloCode（与 --insiders 互斥）"
      exit 0
      ;;
    *) echo "未知参数: $arg"; exit 1 ;;
  esac
done

# 确定目标目录
if $KILOCODE; then
  TARGET_AGENT_DIR="$HOME/.kilo/agent"
  TARGET_COMMAND_DIR="$HOME/.kilo/command"
  TARGET_SKILL_DIR="$HOME/.kilo/skills"
  TARGET_AGENTS_MD="$HOME/.kilo/AGENTS.md"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if $INSIDERS; then
    TARGET_DIR="$HOME/Library/Application Support/Code - Insiders/User/prompts"
  else
    TARGET_DIR="$HOME/Library/Application Support/Code/User/prompts"
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  if $INSIDERS; then
    TARGET_DIR="$HOME/.config/Code - Insiders/User/prompts"
  else
    TARGET_DIR="$HOME/.config/Code/User/prompts"
  fi
else
  echo "不支持的操作系统: $OSTYPE"
  echo "Windows 用户请使用 install.ps1"
  exit 1
fi

# 需要安装的 prompt 文件（sp- 前缀）
PROMPT_FILES=(
  "sp-brainstorm.prompt.md"
  "sp-debug.prompt.md"
  "sp-tdd.prompt.md"
  "sp-plan-write.prompt.md"
  "sp-plan-exec.prompt.md"
  "sp-subagent.prompt.md"
  "sp-parallel.prompt.md"
  "sp-worktree.prompt.md"
  "sp-branch-finish.prompt.md"
  "sp-code-review-req.prompt.md"
  "sp-code-review-recv.prompt.md"
  "sp-global.instructions.md"
)

if $UNINSTALL; then
  # KiloCode 卸载
  if $KILOCODE; then
    echo "正在卸载 Superpowers (KiloCode)..."

    for f in "$SCRIPT_DIR"/commands-kilocode/*.md; do
      [[ -f "$f" ]] || continue
      name="$(basename "$f")"
      target="$TARGET_COMMAND_DIR/$name"
      if [[ -f "$target" ]]; then
        rm "$target"
        echo "  已删除: $name (command)"
      fi
    done

    for f in "$SCRIPT_DIR"/agents-kilocode/*.md; do
      [[ -f "$f" ]] || continue
      name="$(basename "$f")"
      target="$TARGET_AGENT_DIR/$name"
      if [[ -f "$target" ]]; then
        rm "$target"
        echo "  已删除: $name (agent)"
      fi
    done

    if [[ -d "$TARGET_SKILL_DIR" ]]; then
      rm -rf "$TARGET_SKILL_DIR"
      echo "  已删除: skills/"
    fi

    if [[ -f "$TARGET_AGENTS_MD" ]]; then
      rm "$TARGET_AGENTS_MD"
      echo "  已删除: AGENTS.md (全局指令)"
    fi

    echo ""
    echo "卸载完成。"
    exit 0
  fi

  # VS Code 卸载
  echo "正在卸载 Superpowers..."

  for f in "${PROMPT_FILES[@]}"; do
    target="$TARGET_DIR/$f"
    if [[ -f "$target" ]]; then
      rm "$target"
      echo "  已删除: $f"
    fi
  done

  for f in "$SCRIPT_DIR"/agents/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    target="$TARGET_DIR/$name"
    if [[ -f "$target" ]]; then
      rm "$target"
      echo "  已删除: $name (agent)"
    fi
  done

  if [[ -d "$TARGET_DIR/skills" ]]; then
    rm -rf "$TARGET_DIR/skills"
    echo "  已删除: skills/"
  fi

  GLOBAL_INSTRUCTIONS_DIR="$HOME/.copilot/instructions"
  if [[ -f "$GLOBAL_INSTRUCTIONS_DIR/global.instructions.md" ]]; then
    rm "$GLOBAL_INSTRUCTIONS_DIR/global.instructions.md"
    echo "  已删除: global.instructions.md (全局指令)"
  fi

  echo ""
  echo "卸载完成。"
  exit 0
fi

# KiloCode 安装
if $KILOCODE; then
  echo "正在安装 Superpowers 到 KiloCode..."
  echo "目标目录: $HOME/.kilo/"
  echo ""

  mkdir -p "$TARGET_AGENT_DIR"
  mkdir -p "$TARGET_COMMAND_DIR"
  mkdir -p "$TARGET_SKILL_DIR"

  COMMAND_COUNT=0
  for f in "$SCRIPT_DIR"/commands-kilocode/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    cp "$f" "$TARGET_COMMAND_DIR/$name"
    echo "  已安装: $name (command)"
    COMMAND_COUNT=$((COMMAND_COUNT + 1))
  done

  AGENT_COUNT=0
  for f in "$SCRIPT_DIR"/agents-kilocode/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    [[ "$name" == "AGENTS.md" ]] && continue
    cp "$f" "$TARGET_AGENT_DIR/$name"
    echo "  已安装: $name (agent)"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  done

  if [[ -d "$TARGET_SKILL_DIR" ]]; then
    rm -rf "$TARGET_SKILL_DIR"
  fi
  cp -r "$SCRIPT_DIR/skills" "$TARGET_SKILL_DIR"
  echo "  已安装: skills/ (全部技能文件)"

  if [[ -f "$SCRIPT_DIR/agents-kilocode/AGENTS.md" ]]; then
    cp "$SCRIPT_DIR/agents-kilocode/AGENTS.md" "$TARGET_AGENTS_MD"
    echo "  已安装: AGENTS.md (全局指令 → ~/.kilo/)"
  fi

  echo ""
  echo "安装完成！共安装 $COMMAND_COUNT 个命令、$AGENT_COUNT 个 agents。"
  echo ""
  echo "可用命令（在 KiloCode 中输入 / 触发）："
  echo "  /sp-brainstorm       头脑风暴 → 设计方案"
  echo "  /sp-debug            系统化调试"
  echo "  /sp-tdd              测试驱动开发"
  echo "  /sp-plan-write       编写实施计划"
  echo "  /sp-plan-exec        执行实施计划"
  echo "  /sp-subagent         子代理驱动开发"
  echo "  /sp-parallel         并行代理调度"
  echo "  /sp-worktree         Git Worktree 管理"
  echo "  /sp-branch-finish    完成开发分支"
  echo "  /sp-code-review-req  请求代码审查"
  echo "  /sp-code-review-recv 接收代码审查"
  echo ""
  echo "可用 Agents（在 KiloCode 中以 @ 触发）："
  echo "  @gem-orchestrator    多代理编排（主入口）"
  echo "  @gem-planner         制定执行计划"
  echo "  @gem-implementer     TDD 代码实现"
  echo "  @gem-reviewer        代码审查与验证"
  echo "  @gem-researcher      代码库探索与分析"
  echo "  @gem-critic          方案挑战与边界分析"
  echo "  @gem-designer        UI/UX 设计规格"
  echo "  @gem-browser-tester  浏览器 E2E 测试"
  echo "  @security-reviewer   深度安全审计"
  echo "  @performance-optimizer 性能分析与优化"
  echo "  @a11y-architect      无障碍架构"
  echo "  @silent-failure-hunter 静默失败检测"
  echo "  @gem-documentation-writer  技术文档"
  echo "  @se-technical-writer 技术博客/教程"
  echo "  @narrative-writer    Obsidian 学习笔记"
  echo ""
  echo "验证安装：在 KiloCode 中输入 @gem-orchestrator 你好"
  echo ""
  echo "卸载: ./install.sh --kilocode --uninstall"
  exit 0
fi

# VS Code 安装
echo "正在安装 Superpowers 到 VS Code Copilot..."
echo "目标目录: $TARGET_DIR"
echo ""

mkdir -p "$TARGET_DIR"

for f in "${PROMPT_FILES[@]}"; do
  cp "$SCRIPT_DIR/prompts/$f" "$TARGET_DIR/$f"
  echo "  已安装: $f"
done

AGENT_COUNT=0
for f in "$SCRIPT_DIR"/agents/*.md; do
  [[ -f "$f" ]] || continue
  name="$(basename "$f")"
  cp "$f" "$TARGET_DIR/$name"
  echo "  已安装: $name (agent)"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done

if [[ -d "$TARGET_DIR/skills" ]]; then
  rm -rf "$TARGET_DIR/skills"
fi
cp -r "$SCRIPT_DIR/skills" "$TARGET_DIR/skills"
echo "  已安装: skills/ (全部技能文件)"

GLOBAL_INSTRUCTIONS_DIR="$HOME/.copilot/instructions"
mkdir -p "$GLOBAL_INSTRUCTIONS_DIR"
if [[ -f "$SCRIPT_DIR/agents/global.instructions.md" ]]; then
  cp "$SCRIPT_DIR/agents/global.instructions.md" "$GLOBAL_INSTRUCTIONS_DIR/global.instructions.md"
  echo "  已安装: global.instructions.md (全局指令 → ~/.copilot/instructions/)"
fi

echo ""
echo "安装完成！共安装 ${#PROMPT_FILES[@]} 个命令、$AGENT_COUNT 个 agents。"
echo ""
echo "可用命令（在 Copilot Chat 中输入 / 触发）："
echo "  /sp-brainstorm       头脑风暴 → 设计方案"
echo "  /sp-debug            系统化调试"
echo "  /sp-tdd              测试驱动开发"
echo "  /sp-plan-write       编写实施计划"
echo "  /sp-plan-exec        执行实施计划"
echo "  /sp-subagent         子代理驱动开发"
echo "  /sp-parallel         并行代理调度"
echo "  /sp-worktree         Git Worktree 管理"
echo "  /sp-branch-finish    完成开发分支"
echo "  /sp-code-review-req  请求代码审查"
echo "  /sp-code-review-recv 接收代码审查"
echo ""
echo "可用 Agents（在 Copilot Chat 中以 @ 触发）："
echo "  @gem-orchestrator    多代理编排（主入口）"
echo "  @gem-planner         制定执行计划"
echo "  @gem-implementer     TDD 代码实现"
echo "  @gem-reviewer        代码审查与验证"
echo "  @gem-researcher      代码库探索与分析"
echo "  @gem-critic          方案挑战与边界分析"
echo "  @gem-designer        UI/UX 设计规格"
echo "  @gem-browser-tester  浏览器 E2E 测试"
echo "  @security-reviewer   深度安全审计"
echo "  @performance-optimizer 性能分析与优化"
echo "  @a11y-architect      无障碍架构"
echo "  @silent-failure-hunter 静默失败检测"
echo "  @gem-documentation-writer  技术文档"
echo "  @se-technical-writer 技术博客/教程"
echo "  @narrative-writer    Obsidian 学习笔记"
echo ""
echo "卸载: ./install.sh --uninstall$(if $INSIDERS; then echo ' --insiders'; fi)"
