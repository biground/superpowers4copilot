#!/usr/bin/env bash
# Superpowers 中文版 - VS Code Copilot 安装脚本
# 用法: ./install.sh [--insiders] [--uninstall]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析参数
INSIDERS=false
UNINSTALL=false
for arg in "$@"; do
  case "$arg" in
    --insiders) INSIDERS=true ;;
    --uninstall) UNINSTALL=true ;;
    --help|-h)
      echo "用法: ./install.sh [--insiders] [--uninstall]"
      echo ""
      echo "选项:"
      echo "  --insiders    安装到 VS Code Insiders"
      echo "  --uninstall   卸载已安装的文件"
      exit 0
      ;;
    *) echo "未知参数: $arg"; exit 1 ;;
  esac
done

# 确定目标目录
if [[ "$OSTYPE" == "darwin"* ]]; then
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
  echo "正在卸载 Superpowers..."
  
  for f in "${PROMPT_FILES[@]}"; do
    target="$TARGET_DIR/$f"
    if [[ -f "$target" ]]; then
      rm "$target"
      echo "  已删除: $f"
    fi
  done
  
  # 删除 agents
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
  
  echo ""
  echo "卸载完成。"
  exit 0
fi

# 安装
echo "正在安装 Superpowers 到 VS Code Copilot..."
echo "目标目录: $TARGET_DIR"
echo ""

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 复制 prompt 文件
for f in "${PROMPT_FILES[@]}"; do
  cp "$SCRIPT_DIR/prompts/$f" "$TARGET_DIR/$f"
  echo "  已安装: $f"
done

# 复制 agents
AGENT_COUNT=0
for f in "$SCRIPT_DIR"/agents/*.md; do
  [[ -f "$f" ]] || continue
  name="$(basename "$f")"
  cp "$f" "$TARGET_DIR/$name"
  echo "  已安装: $name (agent)"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done

# 复制 skills 目录（prompt 文件通过相对路径引用）
if [[ -d "$TARGET_DIR/skills" ]]; then
  rm -rf "$TARGET_DIR/skills"
fi
cp -r "$SCRIPT_DIR/skills" "$TARGET_DIR/skills"
echo "  已安装: skills/ (全部技能文件)"

echo ""
echo "安装完成！共安装 ${#PROMPT_FILES[@]} 个命令、${AGENT_COUNT} 个 agents。"
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
echo "卸载: ./install.sh --uninstall$(if $INSIDERS; then echo ' --insiders'; fi)"
