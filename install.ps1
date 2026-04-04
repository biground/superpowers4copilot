<#
.SYNOPSIS
    Superpowers 中文版 - VS Code Copilot 安装脚本 (Windows)
.DESCRIPTION
    将 Superpowers 技能安装到 VS Code Copilot 用户目录，
    使用户可以通过 / 命令触发对应技能。
.PARAMETER Insiders
    安装到 VS Code Insiders
.PARAMETER Uninstall
    卸载已安装的文件
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Insiders
    .\install.ps1 -Uninstall
#>
param(
    [switch]$Insiders,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 确定目标目录
if ($Insiders) {
    $TargetDir = Join-Path $env:APPDATA "Code - Insiders\User\prompts"
} else {
    $TargetDir = Join-Path $env:APPDATA "Code\User\prompts"
}

# 需要安装的 prompt 文件
$PromptFiles = @(
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

if ($Uninstall) {
    Write-Host "正在卸载 Superpowers..." -ForegroundColor Yellow
    
    foreach ($f in $PromptFiles) {
        $target = Join-Path $TargetDir $f
        if (Test-Path $target) {
            Remove-Item $target -Force
            Write-Host "  已删除: $f" -ForegroundColor Gray
        }
    }

    # 删除 agents
    $agentsSourceDir = Join-Path $ScriptDir "agents"
    foreach ($f in Get-ChildItem -Path $agentsSourceDir -Filter "*.md") {
        $target = Join-Path $TargetDir $f.Name
        if (Test-Path $target) {
            Remove-Item $target -Force
            Write-Host "  已删除: $($f.Name) (agent)" -ForegroundColor Gray
        }
    }
    
    $skillsDir = Join-Path $TargetDir "skills"
    if (Test-Path $skillsDir) {
        Remove-Item $skillsDir -Recurse -Force
        Write-Host "  已删除: skills/" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "卸载完成。" -ForegroundColor Green
    exit 0
}

# 安装
Write-Host "正在安装 Superpowers 到 VS Code Copilot..." -ForegroundColor Cyan
Write-Host "目标目录: $TargetDir" -ForegroundColor Gray
Write-Host ""

# 创建目标目录
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# 复制 prompt 文件
foreach ($f in $PromptFiles) {
    $source = Join-Path $ScriptDir "prompts\$f"
    $target = Join-Path $TargetDir $f
    Copy-Item $source $target -Force
    Write-Host "  已安装: $f" -ForegroundColor Gray
}

# 复制 agents
$agentCount = 0
$agentsSourceDir = Join-Path $ScriptDir "agents"
foreach ($f in Get-ChildItem -Path $agentsSourceDir -Filter "*.md") {
    $target = Join-Path $TargetDir $f.Name
    Copy-Item $f.FullName $target -Force
    Write-Host "  已安装: $($f.Name) (agent)" -ForegroundColor Gray
    $agentCount++
}

# 复制 skills 目录（prompt 文件通过相对路径引用）
$skillsTarget = Join-Path $TargetDir "skills"
if (Test-Path $skillsTarget) {
    Remove-Item $skillsTarget -Recurse -Force
}
Copy-Item (Join-Path $ScriptDir "skills") $skillsTarget -Recurse
Write-Host "  已安装: skills/ (全部技能文件)" -ForegroundColor Gray

Write-Host ""
Write-Host "安装完成！共安装 $($PromptFiles.Count) 个命令、$agentCount 个 agents。" -ForegroundColor Green
Write-Host ""
Write-Host "可用命令（在 Copilot Chat 中输入 / 触发）：" -ForegroundColor Cyan
Write-Host "  /sp-brainstorm       头脑风暴 → 设计方案"
Write-Host "  /sp-debug            系统化调试"
Write-Host "  /sp-tdd              测试驱动开发"
Write-Host "  /sp-plan-write       编写实施计划"
Write-Host "  /sp-plan-exec        执行实施计划"
Write-Host "  /sp-subagent         子代理驱动开发"
Write-Host "  /sp-parallel         并行代理调度"
Write-Host "  /sp-worktree         Git Worktree 管理"
Write-Host "  /sp-branch-finish    完成开发分支"
Write-Host "  /sp-code-review-req  请求代码审查"
Write-Host "  /sp-code-review-recv 接收代码审查"
Write-Host ""
Write-Host "可用 Agents（在 Copilot Chat 中以 @ 触发）：" -ForegroundColor Cyan
Write-Host "  @gem-orchestrator    多代理编排（主入口）"
Write-Host "  @gem-planner         制定执行计划"
Write-Host "  @gem-implementer     TDD 代码实现"
Write-Host "  @gem-reviewer        代码审查与验证"
Write-Host "  @gem-researcher      代码库探索与分析"
Write-Host "  @gem-critic          方案挑战与边界分析"
Write-Host "  @gem-designer        UI/UX 设计规格"
Write-Host "  @gem-browser-tester  浏览器 E2E 测试"
Write-Host "  @gem-documentation-writer  技术文档"
Write-Host "  @se-technical-writer 技术博客/教程"
Write-Host "  @narrative-writer    Obsidian 学习笔记"
Write-Host ""
$uninstallCmd = ".\install.ps1 -Uninstall"
if ($Insiders) { $uninstallCmd += " -Insiders" }
Write-Host "卸载: $uninstallCmd" -ForegroundColor Gray
