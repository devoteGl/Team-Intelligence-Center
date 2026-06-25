param(
    [switch]$DryRun,
    [switch]$Yes,
    [switch]$Force,
    [switch]$Help,
    [string]$RulesDir = "",
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File tools/bootstrap-project.ps1 [-DryRun] [-Yes] [-Force] [-RulesDir PATH] [-ProjectRoot PATH]

Options:
  -DryRun        Show planned writes without changing files.
  -Yes          Skip interactive confirmation.
  -Force        Overwrite existing docs/ai-rules-usage.md and ai-harness/project-adapter.md after backing them up.
  -RulesDir     Path to Team-Intelligence-Center. Project-local paths are recorded as relative; external paths are written only to .tic-rules.local.
  -ProjectRoot  Target project root. Defaults to the current directory.
"@
}

if ($PSBoundParameters.ContainsKey("Help")) {
    Write-Usage
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "Project root does not exist: $ProjectRoot"
}

$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if ([string]::IsNullOrWhiteSpace($RulesDir)) {
    $RulesDir = $PackageRoot
}
$RulesDir = (Resolve-Path -LiteralPath $RulesDir).Path

$VersionPath = Join-Path $PackageRoot "VERSION"
if (Test-Path -LiteralPath $VersionPath) {
    $Version = (Get-Content -LiteralPath $VersionPath -Raw -Encoding UTF8).Trim()
} else {
    $Version = "unknown"
}

$PackageId = "Team_Intelligence_Center_$Version"
$BeginMarker = "<!-- TIC_LIGHT_AUTOMATION_BEGIN -->"
$EndMarker = "<!-- TIC_LIGHT_AUTOMATION_END -->"
$Stamp = Get-Date -Format "yyyyMMddHHmmss"
$Planned = New-Object System.Collections.Generic.List[string]

function Get-ProjectRelativeRulesPath {
    $root = [System.IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]@('\', '/'))
    $path = [System.IO.Path]::GetFullPath($RulesDir).TrimEnd([char[]]@('\', '/'))
    if ($path -eq $root) {
        return "."
    }

    $rootWithSeparator = $root + [System.IO.Path]::DirectorySeparatorChar
    if ($path.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $path.Substring($rootWithSeparator.Length)
        return $relative.Replace("\", "/")
    }

    return ""
}

$RulesProjectPath = Get-ProjectRelativeRulesPath
$RulesSourceMode = if ([string]::IsNullOrWhiteSpace($RulesProjectPath)) { "local_config" } else { "project_relative" }

if (-not $DryRun -and -not $Yes) {
    $answer = Read-Host "Install Team-Intelligence-Center lightweight rules into $ProjectRoot? [y/N]"
    if ($answer -notin @("y", "Y", "yes", "YES")) {
        Write-Host "Cancelled before writing."
        exit 1
    }
}

function Add-Plan {
    param([string]$Item)
    [void]$Planned.Add($Item)
}

function Render-Template {
    param([string]$Source)
    $content = Get-Content -LiteralPath $Source -Raw -Encoding UTF8
    $content = $content.Replace("{{TIC_RULES_DIR}}", $RulesDir)
    $content = $content.Replace("{{TIC_VERSION}}", $Version)
    return $content
}

function Backup-File {
    param([string]$Target)
    $relative = $Target.Substring($ProjectRoot.Length).TrimStart([char[]]@('\', '/'))
    $backup = Join-Path (Join-Path $ProjectRoot ".tic-backups") (Join-Path $Stamp $relative)
    $backupDir = Split-Path -Parent $backup
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    Copy-Item -LiteralPath $Target -Destination $backup -Force
}

function Merge-Agents {
    $template = Join-Path $PackageRoot "templates/AGENTS.md"
    $target = Join-Path $ProjectRoot "AGENTS.md"
    $rendered = Render-Template $template
    $block = "$BeginMarker`r`n$rendered`r`n$EndMarker`r`n"

    if (-not (Test-Path -LiteralPath $target)) {
        Add-Plan "create AGENTS.md"
        if (-not $DryRun) {
            Set-Content -LiteralPath $target -Value $block -Encoding UTF8
        }
        return
    }

    $existing = Get-Content -LiteralPath $target -Raw -Encoding UTF8
    if ($existing.Contains($BeginMarker) -and $existing.Contains($EndMarker)) {
        Add-Plan "replace TIC block in AGENTS.md"
        if (-not $DryRun) {
            Backup-File $target
            $pattern = [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)
            $updated = [regex]::Replace($existing, $pattern, $block.TrimEnd(), [System.Text.RegularExpressions.RegexOptions]::Singleline)
            Set-Content -LiteralPath $target -Value $updated -Encoding UTF8
        }
    } else {
        Add-Plan "append TIC block to AGENTS.md"
        if (-not $DryRun) {
            Backup-File $target
            $updated = $existing.TrimEnd() + "`r`n`r`n" + $block
            Set-Content -LiteralPath $target -Value $updated -Encoding UTF8
        }
    }
}

function Install-TemplateFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    $relative = $Destination.Substring($ProjectRoot.Length).TrimStart([char[]]@('\', '/'))
    if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
        Add-Plan "skip existing $relative"
        return
    }

    if (Test-Path -LiteralPath $Destination) {
        Add-Plan "overwrite $relative with backup"
    } else {
        Add-Plan "create $relative"
    }

    if (-not $DryRun) {
        $destDir = Split-Path -Parent $Destination
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        if (Test-Path -LiteralPath $Destination) {
            Backup-File $Destination
        }
        Set-Content -LiteralPath $Destination -Value (Render-Template $Source) -Encoding UTF8
    }
}

function Get-PackageManager {
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "pnpm-lock.yaml")) { return "pnpm" }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "yarn.lock")) { return "yarn" }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "package-lock.json")) { return "npm" }
    if ((Test-Path -LiteralPath (Join-Path $ProjectRoot "bun.lockb")) -or (Test-Path -LiteralPath (Join-Path $ProjectRoot "bun.lock"))) { return "bun" }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "package.json")) { return "npm 或项目约定" }
    return "未检测到 Node 包管理器"
}

function Get-DetectedStackFiles {
    $files = @(
        "package.json",
        "pnpm-workspace.yaml",
        "turbo.json",
        "vite.config.ts",
        "vite.config.js",
        "next.config.js",
        "nuxt.config.ts",
        "tsconfig.json",
        "pyproject.toml",
        "requirements.txt",
        "go.mod",
        "pom.xml",
        "build.gradle",
        "Cargo.toml",
        "Dockerfile",
        "docker-compose.yml"
    )
    $found = @()
    foreach ($file in $files) {
        if (Test-Path -LiteralPath (Join-Path $ProjectRoot $file)) {
            $found += "``$file``"
        }
    }
    if ($found.Count -eq 0) { return "未检测到常见技术栈文件" }
    return ($found -join "、")
}

function Get-DetectedCommonDirs {
    $dirs = @("src", "app", "apps", "packages", "components", "pages", "router", "routes", "api", "server", "backend", "frontend", "web", "admin", "miniapp", "tests", "test", "docs", "config", "scripts")
    $found = @()
    foreach ($dir in $dirs) {
        if (Test-Path -LiteralPath (Join-Path $ProjectRoot $dir) -PathType Container) {
            $found += "``$dir/``"
        }
    }
    if ($found.Count -eq 0) { return "未检测到常见模块目录" }
    return ($found -join "、")
}

function Get-NodeVersionSummary {
    $parts = @()
    $nvmrc = Join-Path $ProjectRoot ".nvmrc"
    $nodeVersionFile = Join-Path $ProjectRoot ".node-version"
    $packageJson = Join-Path $ProjectRoot "package.json"

    if (Test-Path -LiteralPath $nvmrc) {
        $parts += ".nvmrc=$((Get-Content -LiteralPath $nvmrc -Raw -Encoding UTF8).Trim())"
    }
    if (Test-Path -LiteralPath $nodeVersionFile) {
        $parts += ".node-version=$((Get-Content -LiteralPath $nodeVersionFile -Raw -Encoding UTF8).Trim())"
    }
    if (Test-Path -LiteralPath $packageJson) {
        try {
            $pkg = Get-Content -LiteralPath $packageJson -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($pkg.engines -and $pkg.engines.node) {
                $parts += "package.json engines.node=$($pkg.engines.node)"
            }
        } catch {
            $parts += "package.json 解析失败"
        }
    }

    if ($parts.Count -eq 0) {
        return "未声明；请在项目中补充 .nvmrc、.node-version 或 package.json engines.node"
    }
    return ($parts -join "；")
}

function Format-DependencyNames {
    param($Object)
    if (-not $Object) { return "无" }
    $names = @($Object.PSObject.Properties.Name | Sort-Object)
    if ($names.Count -eq 0) { return "无" }
    $limit = 40
    $shown = @($names | Select-Object -First $limit | ForEach-Object { "``$_``" }) -join "、"
    if ($names.Count -gt $limit) {
        return "$shown 等 $($names.Count) 项"
    }
    return $shown
}

function Get-PackageJsonSection {
    $packageJson = Join-Path $ProjectRoot "package.json"
    if (-not (Test-Path -LiteralPath $packageJson)) {
        return "未检测到 ``package.json``。如果本项目不是 Node 项目，请在“常用命令”和“模块地图”中补充真实技术栈信息。"
    }

    try {
        $pkg = Get-Content -LiteralPath $packageJson -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        return "检测到 ``package.json``，但 JSON 解析失败。请研发手工补充 scripts、dependencies 和工作区关系。"
    }

    $name = if ($pkg.name) { "``$($pkg.name)``" } else { "未声明" }
    $versionText = if ($pkg.version) { "``$($pkg.version)``" } else { "未声明" }
    $type = if ($pkg.type) { "``$($pkg.type)``" } else { "未声明" }
    $packageManagerField = if ($pkg.packageManager) { "``$($pkg.packageManager)``" } else { "未声明" }
    $workspaces = "未声明"
    if ($pkg.workspaces) {
        if ($pkg.workspaces -is [System.Array]) {
            $workspaces = (@($pkg.workspaces | ForEach-Object { "``$_``" }) -join "、")
        } elseif ($pkg.workspaces.packages) {
            $workspaces = (@($pkg.workspaces.packages | ForEach-Object { "``$_``" }) -join "、")
        }
        if ([string]::IsNullOrWhiteSpace($workspaces)) {
            $workspaces = "未声明"
        }
    }

    $scriptLines = @()
    if ($pkg.scripts) {
        foreach ($script in ($pkg.scripts.PSObject.Properties | Sort-Object Name)) {
            $scriptLines += "| ``$($script.Name)`` | ``$($script.Value)`` |"
        }
    }
    if ($scriptLines.Count -eq 0) {
        $scriptLines += "| 未声明 |  |"
    }

    @"
- package name：$name
- package version：$versionText
- package type：$type
- packageManager 字段：$packageManagerField
- workspaces：$workspaces

### package scripts

| script | command |
| --- | --- |
$($scriptLines -join "`r`n")

### dependencies

- dependencies：$(Format-DependencyNames $pkg.dependencies)
- devDependencies：$(Format-DependencyNames $pkg.devDependencies)
- peerDependencies：$(Format-DependencyNames $pkg.peerDependencies)
"@
}

function New-ProjectAdapterContent {
    $generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $projectName = Split-Path -Leaf $ProjectRoot
    $stackFiles = Get-DetectedStackFiles
    $commonDirs = Get-DetectedCommonDirs
    $packageManager = Get-PackageManager
    $nodeVersions = Get-NodeVersionSummary
    $packageSection = Get-PackageJsonSection
    $openSpec = if (Test-Path -LiteralPath (Join-Path $ProjectRoot "openspec") -PathType Container) { "已检测到 ``openspec/``" } else { "未检测到 ``openspec/``" }
    $monorepoParts = @()
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "pnpm-workspace.yaml")) { $monorepoParts += "检测到 ``pnpm-workspace.yaml``" }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "apps") -PathType Container) { $monorepoParts += "检测到 ``apps/``" }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot "packages") -PathType Container) { $monorepoParts += "检测到 ``packages/``" }
    $monorepo = if ($monorepoParts.Count -gt 0) { $monorepoParts -join "；" } else { "未检测到常见 monorepo 结构" }

    @"
# 项目适配说明

本文件由 Team-Intelligence-Center bootstrap 自动生成，用于让 AI 快速了解当前项目。请研发按真实情况补充业务背景、风险边界和缺失命令。

生成时间：$generatedAt
项目标识：``$projectName``
项目根：当前仓库根（安装脚本不写入本机绝对路径）

## 项目画像

- 产品 / 服务：待补充
- 主要用户：待补充
- 技术栈文件：$stackFiles
- 主要模块目录：$commonDirs
- 包管理器推断：$packageManager
- Node 版本声明：$nodeVersions
- 部署目标：待补充

## Node / 前端项目详情

$packageSection

## 项目关系

- OpenSpec：$openSpec
- Monorepo 线索：$monorepo
- 规则入口：bootstrap 会生成或更新项目根 ``AGENTS.md``

## 常用命令

请以项目真实命令为准。若上方 package scripts 已列出命令，优先使用其中的 lint、typecheck、test、build。

````bash
# 安装依赖

# lint

# 类型检查

# 测试

# 构建
````

## 模块地图

| 区域 | 路径 | 说明 |
| --- | --- | --- |
| 前端 | 待补充 |  |
| 后端 | 待补充 |  |
| 测试 | 待补充 |  |
| 文档 | 待补充 |  |

## 风险边界

列出需要额外谨慎、人工确认或回滚方案的区域：

- 认证 / 权限：待补充
- 支付 / 资金：待补充
- 数据迁移：待补充
- 生产配置：待补充
- 外部集成：待补充

## 本地决策

记录未来 AI 会话必须延续的项目级决策：

-
"@
}

function Install-ProjectAdapter {
    $destination = Join-Path $ProjectRoot "ai-harness/project-adapter.md"
    $relative = $destination.Substring($ProjectRoot.Length).TrimStart([char[]]@('\', '/'))
    if ((Test-Path -LiteralPath $destination) -and -not $Force) {
        Add-Plan "skip existing $relative"
        return
    }

    if (Test-Path -LiteralPath $destination) {
        Add-Plan "overwrite $relative with detected project profile and backup"
    } else {
        Add-Plan "create $relative with detected project profile"
    }

    if (-not $DryRun) {
        $destDir = Split-Path -Parent $destination
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        if (Test-Path -LiteralPath $destination) {
            Backup-File $destination
        }
        Set-Content -LiteralPath $destination -Value (New-ProjectAdapterContent) -Encoding UTF8
    }
}

function Write-LockFile {
    $target = Join-Path $ProjectRoot ".tic-rules.lock"
    Add-Plan "write .tic-rules.lock"
    if (-not $DryRun) {
        $contentLines = @(
            "managed_by=team-intelligence-center",
            "version=2",
            "rules_version=$Version",
            "package_id=$PackageId",
            "install_mode=minimal",
            "rules_source=$RulesSourceMode",
            "rules_path=$RulesProjectPath",
            "local_config=.tic-rules.local"
        )
        if (Test-Path -LiteralPath $target) {
            $knownKeys = @(
                "managed_by",
                "version",
                "rules_version",
                "package_id",
                "install_mode",
                "rules_source",
                "rules_path",
                "local_config"
            )
            foreach ($line in Get-Content -LiteralPath $target -Encoding UTF8) {
                if ([string]::IsNullOrWhiteSpace($line)) {
                    continue
                }
                $key = ($line -split "=", 2)[0]
                if ($knownKeys -notcontains $key) {
                    $contentLines += $line
                }
            }
        }
        $content = ($contentLines -join "`r`n") + "`r`n"
        Set-Content -LiteralPath $target -Value $content -Encoding UTF8
    }
}

function Write-LocalConfig {
    $target = Join-Path $ProjectRoot ".tic-rules.local"
    Add-Plan "write .tic-rules.local"
    if (-not $DryRun) {
        $updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $content = @"
# Local Team-Intelligence-Center resolver.
# This file is machine-specific and must not be committed.
rules_dir=$RulesDir
rules_source=$RulesSourceMode
rules_path=$RulesProjectPath
updated_at=$updatedAt
"@
        Set-Content -LiteralPath $target -Value $content -Encoding UTF8
    }
}

function Ensure-GitignoreLocalConfig {
    $target = Join-Path $ProjectRoot ".gitignore"
    $needsLocal = $true
    $needsBackups = $true

    if (Test-Path -LiteralPath $target) {
        $lines = @(Get-Content -LiteralPath $target -Encoding UTF8)
        $needsLocal = -not ($lines -contains ".tic-rules.local")
        $needsBackups = -not ($lines -contains ".tic-backups/")
    }

    if (-not $needsLocal -and -not $needsBackups) {
        Add-Plan "skip .gitignore TIC local entries"
        return
    }

    if (Test-Path -LiteralPath $target) {
        Add-Plan "append TIC local entries to .gitignore"
    } else {
        Add-Plan "create .gitignore with TIC local entries"
    }

    if (-not $DryRun) {
        $existing = ""
        if (Test-Path -LiteralPath $target) {
            Backup-File $target
            $existing = (Get-Content -LiteralPath $target -Raw -Encoding UTF8).TrimEnd()
        }

        $additions = New-Object System.Collections.Generic.List[string]
        [void]$additions.Add("# Team-Intelligence-Center local files")
        if ($needsLocal) { [void]$additions.Add(".tic-rules.local") }
        if ($needsBackups) { [void]$additions.Add(".tic-backups/") }

        $content = if ([string]::IsNullOrWhiteSpace($existing)) {
            ($additions -join "`r`n") + "`r`n"
        } else {
            $existing + "`r`n`r`n" + ($additions -join "`r`n") + "`r`n"
        }
        Set-Content -LiteralPath $target -Value $content -Encoding UTF8
    }
}

Merge-Agents
Install-TemplateFile (Join-Path $PackageRoot "templates/docs/ai-rules-usage.md") (Join-Path $ProjectRoot "docs/ai-rules-usage.md")
Install-TemplateFile (Join-Path $PackageRoot "templates/tool-rules/cursorrules.md") (Join-Path $ProjectRoot ".cursorrules")
Install-TemplateFile (Join-Path $PackageRoot "templates/tool-rules/windsurfrules.md") (Join-Path $ProjectRoot ".windsurfrules")
Install-TemplateFile (Join-Path $PackageRoot "templates/tool-rules/rules/team-intelligence-center.md") (Join-Path (Join-Path $ProjectRoot ".rules") "team-intelligence-center.md")
Install-ProjectAdapter
Write-LockFile
Write-LocalConfig
Ensure-GitignoreLocalConfig

Write-Host "Team-Intelligence-Center bootstrap plan for ${ProjectRoot}:"
foreach ($item in $Planned) {
    Write-Host "  - $item"
}

if ($DryRun) {
    Write-Host ""
    Write-Host "Dry run only. No files changed."
    exit 0
}

Write-Host ""
Write-Host "Bootstrap complete."
