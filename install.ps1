<#
.SYNOPSIS
    Superpowers 中文版 - VS Code Copilot / KiloCode 安装脚本 (Windows)
.DESCRIPTION
    将 Superpowers 技能安装到 VS Code Copilot 用户目录或 KiloCode 全局目录，
    使用户可以通过 / 命令触发对应技能。
.PARAMETER Insiders
    安装到 VS Code Insiders
.PARAMETER Uninstall
    卸载已安装的文件
.PARAMETER Kilocode
    安装到 KiloCode（与 -Insiders 互斥）
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Insiders
    .\install.ps1 -Kilocode
    .\install.ps1 -Uninstall
    .\install.ps1 -Kilocode -Uninstall
#>
param(
    [switch]$Insiders,
    [switch]$Uninstall,
    [switch]$Kilocode
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 确定目标目录
if ($Kilocode) {
    $TargetAgentDir = Join-Path $env:USERPROFILE ".kilo\agent"
    $TargetCommandDir = Join-Path $env:USERPROFILE ".kilo\command"
    $TargetSkillDir = Join-Path $env:USERPROFILE ".kilo\skills"
    $TargetAgentsMd = Join-Path $env:USERPROFILE ".kilo\AGENTS.md"
} elseif ($Insiders) {
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
    "cc-start.prompt.md"
    "cc-brainstorm.prompt.md"
    "cc-design-system.prompt.md"
    "cc-setup-engine.prompt.md"
    "cc-gate-check.prompt.md"
    "cc-dev-story.prompt.md"
)

# KiloCode 卸载
if ($Kilocode -and $Uninstall) {
    Write-Host "正在卸载 Superpowers (KiloCode)..." -ForegroundColor Yellow
    
    foreach ($f in Get-ChildItem -Path (Join-Path $ScriptDir "commands-kilocode") -Filter "*.md") {
        $target = Join-Path $TargetCommandDir $f.Name
        if (Test-Path $target) {
            Remove-Item $target -Force
            Write-Host "  已删除: $($f.Name) (command)" -ForegroundColor Gray
        }
    }

    foreach ($f in Get-ChildItem -Path (Join-Path $ScriptDir "agents-kilocode") -Filter "*.md") {
        $target = Join-Path $TargetAgentDir $f.Name
        if (Test-Path $target) {
            Remove-Item $target -Force
            Write-Host "  已删除: $($f.Name) (agent)" -ForegroundColor Gray
        }
    }
    
    if (Test-Path $TargetSkillDir) {
        Remove-Item $TargetSkillDir -Recurse -Force
        Write-Host "  已删除: skills/" -ForegroundColor Gray
    }

    if (Test-Path $TargetAgentsMd) {
        Remove-Item $TargetAgentsMd -Force
        Write-Host "  已删除: AGENTS.md (全局指令)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "卸载完成。" -ForegroundColor Green
    exit 0
}

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

    # 删除全局指令
    $globalInstructionsDir = Join-Path $env:USERPROFILE ".copilot\instructions"
    $globalInstructionsFile = Join-Path $globalInstructionsDir "global.instructions.md"
    if (Test-Path $globalInstructionsFile) {
        Remove-Item $globalInstructionsFile -Force
        Write-Host "  已删除: global.instructions.md (全局指令)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "卸载完成。" -ForegroundColor Green
    exit 0
}

# KiloCode 安装
if ($Kilocode) {
    Write-Host "正在安装 Superpowers 到 KiloCode..." -ForegroundColor Cyan
    Write-Host "目标目录: $env:USERPROFILE\.kilo\" -ForegroundColor Gray
    Write-Host ""

    # 创建目标目录
    if (-not (Test-Path $TargetAgentDir)) {
        New-Item -ItemType Directory -Path $TargetAgentDir -Force | Out-Null
    }
    if (-not (Test-Path $TargetCommandDir)) {
        New-Item -ItemType Directory -Path $TargetCommandDir -Force | Out-Null
    }
    if (-not (Test-Path $TargetSkillDir)) {
        New-Item -ItemType Directory -Path $TargetSkillDir -Force | Out-Null
    }

    # 复制 commands
    $commandCount = 0
    $commandsSourceDir = Join-Path $ScriptDir "commands-kilocode"
    foreach ($f in Get-ChildItem -Path $commandsSourceDir -Filter "*.md") {
        $target = Join-Path $TargetCommandDir $f.Name
        Copy-Item $f.FullName $target -Force
        Write-Host "  已安装: $($f.Name) (command)" -ForegroundColor Gray
        $commandCount++
    }

    # 复制 agents
    $agentCount = 0
    $agentsSourceDir = Join-Path $ScriptDir "agents-kilocode"
    foreach ($f in Get-ChildItem -Path $agentsSourceDir -Filter "*.md") {
        if ($f.Name -eq "AGENTS.md") { continue }
        $target = Join-Path $TargetAgentDir $f.Name
        Copy-Item $f.FullName $target -Force
        Write-Host "  已安装: $($f.Name) (agent)" -ForegroundColor Gray
        $agentCount++
    }

    # 复制 skills 目录
    if (Test-Path $TargetSkillDir) {
        Remove-Item $TargetSkillDir -Recurse -Force
    }
    Copy-Item (Join-Path $ScriptDir "skills") $TargetSkillDir -Recurse
    Write-Host "  已安装: skills/ (全部技能文件)" -ForegroundColor Gray

    # 安装全局指令
    $globalSource = Join-Path $ScriptDir "agents-kilocode\AGENTS.md"
    if (Test-Path $globalSource) {
        Copy-Item $globalSource $TargetAgentsMd -Force
        Write-Host "  已安装: AGENTS.md (全局指令 → ~/.kilo/)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "安装完成！共安装 $commandCount 个命令、$agentCount 个 agents。" -ForegroundColor Green
    Write-Host ""
    Write-Host "可用命令（在 KiloCode 中输入 / 触发）：" -ForegroundColor Cyan
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
    Write-Host "可用 Agents（在 KiloCode 中以 @ 触发）：" -ForegroundColor Cyan
    Write-Host "  @gem-orchestrator    多代理编排（主入口）"
    Write-Host "  @gem-planner         制定执行计划"
    Write-Host "  @gem-implementer     TDD 代码实现"
    Write-Host "  @gem-reviewer        代码审查与验证"
    Write-Host "  @gem-researcher      代码库探索与分析"
    Write-Host "  @gem-critic          方案挑战与边界分析"
    Write-Host "  @gem-designer        UI/UX 设计规格"
    Write-Host "  @gem-browser-tester  浏览器 E2E 测试"
    Write-Host "  @security-reviewer   深度安全审计"
    Write-Host "  @performance-optimizer 性能分析与优化"
    Write-Host "  @a11y-architect      无障碍架构"
    Write-Host "  @silent-failure-hunter 静默失败检测"
    Write-Host "  @gem-documentation-writer  技术文档"
    Write-Host "  @se-technical-writer 技术博客/教程"
    Write-Host "  @narrative-writer    Obsidian 学习笔记"
    Write-Host ""
    Write-Host "验证安装：在 KiloCode 中输入 @gem-orchestrator 你好" -ForegroundColor Cyan
    Write-Host ""
    $uninstallCmd = ".\install.ps1 -Kilocode -Uninstall"
    Write-Host "卸载: $uninstallCmd" -ForegroundColor Gray
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

# 安装全局指令到 ~/.copilot/instructions/
$globalInstructionsDir = Join-Path $env:USERPROFILE ".copilot\instructions"
if (-not (Test-Path $globalInstructionsDir)) {
    New-Item -ItemType Directory -Path $globalInstructionsDir -Force | Out-Null
}
$globalSource = Join-Path $ScriptDir "agents\global.instructions.md"
if (Test-Path $globalSource) {
    Copy-Item $globalSource (Join-Path $globalInstructionsDir "global.instructions.md") -Force
    Write-Host "  已安装: global.instructions.md (全局指令 → ~/.copilot/instructions/)" -ForegroundColor Gray
}

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
Write-Host "可用命令（Game Studio，在 Copilot Chat 中输入 / 触发）：" -ForegroundColor Cyan
Write-Host "  /cc-start             项目引导上手"
Write-Host "  /cc-brainstorm        游戏概念头脑风暴"
Write-Host "  /cc-design-system     游戏系统 GDD 编写"
Write-Host "  /cc-setup-engine      配置游戏引擎"
Write-Host "  /cc-gate-check        阶段门禁检查"
Write-Host "  /cc-dev-story         实现开发故事"
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
Write-Host "  @security-reviewer   深度安全审计"
Write-Host "  @performance-optimizer 性能分析与优化"
Write-Host "  @a11y-architect      无障碍架构"
Write-Host "  @silent-failure-hunter 静默失败检测"
Write-Host "  @gem-documentation-writer  技术文档"
Write-Host "  @se-technical-writer 技术博客/教程"
Write-Host "  @narrative-writer    Obsidian 学习笔记"
Write-Host ""
$uninstallCmd = ".\install.ps1 -Uninstall"
if ($Insiders) { $uninstallCmd += " -Insiders" }
Write-Host "卸载: $uninstallCmd" -ForegroundColor Gray
