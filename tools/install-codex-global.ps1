param(
    [switch]$DryRun,
    [switch]$Preview,
    [switch]$Yes,
    [switch]$Force,
    [switch]$Help,
    [string]$CodexHome = "",
    [string]$RulesDir = ""
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File tools\install-codex-global.ps1 [-DryRun] [-Yes] [-Force] [-CodexHome PATH] [-RulesDir PATH]

Installs a small Codex global TIC loader and tic-* skill wrappers.
It does not copy TIC project Skills into global skills.
"@
}

if ($Help) {
    Write-Usage
    exit 0
}

if ($Preview) {
    $DryRun = $true
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if ($env:CODEX_HOME) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME ".codex"
    }
}
if ([string]::IsNullOrWhiteSpace($RulesDir)) {
    $RulesDir = $PackageRoot
}

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$CodexHome = (Resolve-Path -LiteralPath $CodexHome).Path
$RulesDir = (Resolve-Path -LiteralPath $RulesDir).Path
$VersionPath = Join-Path $PackageRoot "VERSION"
$Version = if (Test-Path -LiteralPath $VersionPath) { (Get-Content -LiteralPath $VersionPath -Raw -Encoding UTF8).Trim() } else { "unknown" }
$BeginMarker = "<!-- TIC_CODEX_GLOBAL_BEGIN -->"
$EndMarker = "<!-- TIC_CODEX_GLOBAL_END -->"
$Stamp = Get-Date -Format "yyyyMMddHHmmss"
$Planned = New-Object System.Collections.Generic.List[string]

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
    $relative = $Target.Substring($CodexHome.Length).TrimStart([char[]]@('\', '/'))
    $backup = Join-Path (Join-Path $CodexHome ".tic-backups") (Join-Path (Join-Path "codex-global" $Stamp) $relative)
    $backupDir = Split-Path -Parent $backup
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    Copy-Item -LiteralPath $Target -Destination $backup -Force
}

function Merge-GlobalAgents {
    $template = Join-Path $PackageRoot "templates/codex-global/AGENTS.md"
    $target = Join-Path $CodexHome "AGENTS.md"
    $rendered = Render-Template $template
    $block = "$BeginMarker`r`n$rendered`r`n$EndMarker`r`n"

    if (-not (Test-Path -LiteralPath $target)) {
        Add-Plan "create AGENTS.md global TIC loader"
        if (-not $DryRun) {
            Set-Content -LiteralPath $target -Value $block -Encoding UTF8
        }
        return
    }

    $existing = Get-Content -LiteralPath $target -Raw -Encoding UTF8
    if ($existing.Contains($BeginMarker) -and $existing.Contains($EndMarker)) {
        Add-Plan "replace existing TIC loader block in AGENTS.md"
        if (-not $DryRun) {
            Backup-File $target
            $pattern = [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)
            $updated = [regex]::Replace($existing, $pattern, $block.TrimEnd(), [System.Text.RegularExpressions.RegexOptions]::Singleline)
            Set-Content -LiteralPath $target -Value $updated -Encoding UTF8
        }
    } else {
        Add-Plan "append TIC loader block to existing AGENTS.md"
        if (-not $DryRun) {
            Backup-File $target
            $updated = $existing.TrimEnd() + "`r`n`r`n" + $block
            Set-Content -LiteralPath $target -Value $updated -Encoding UTF8
        }
    }
}

function Install-SkillWrappers {
    $sourceRoot = Join-Path $PackageRoot "templates/codex-global/skills"
    foreach ($dir in Get-ChildItem -LiteralPath $sourceRoot -Directory) {
        $source = Join-Path $dir.FullName "SKILL.md"
        $destination = Join-Path (Join-Path $CodexHome "skills") (Join-Path $dir.Name "SKILL.md")

        if ((Test-Path -LiteralPath $destination) -and -not $Force) {
            $existing = Get-Content -LiteralPath $destination -Raw -Encoding UTF8
            if (-not $existing.Contains("Codex global wrapper for Team-Intelligence-Center")) {
                Add-Plan "skip existing non-TIC skill wrapper: skills/$($dir.Name)/SKILL.md"
                continue
            }
        }

        if (Test-Path -LiteralPath $destination) {
            Add-Plan "replace skills/$($dir.Name)/SKILL.md with backup"
        } else {
            Add-Plan "create skills/$($dir.Name)/SKILL.md"
        }

        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            if (Test-Path -LiteralPath $destination) {
                Backup-File $destination
            }
            Set-Content -LiteralPath $destination -Value (Render-Template $source) -Encoding UTF8
        }
    }
}

if (-not $DryRun -and -not $Yes) {
    $answer = Read-Host "Install TIC Codex global loader into $CodexHome? [y/N]"
    if ($answer -notin @("y", "Y", "yes", "YES")) {
        Write-Host "Cancelled before writing."
        exit 1
    }
}

Merge-GlobalAgents
Install-SkillWrappers

Write-Host "Team-Intelligence-Center Codex global install plan for ${CodexHome}:"
foreach ($item in $Planned) {
    Write-Host "  - $item"
}

if ($DryRun) {
    Write-Host ""
    Write-Host "Dry run only. No files changed."
} else {
    Write-Host ""
    Write-Host "Codex global loader install complete."
}
