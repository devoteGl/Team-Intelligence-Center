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
  -RulesDir     Path that the target project should use to find Team-Intelligence-Center.
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

function Write-LockFile {
    $target = Join-Path $ProjectRoot ".tic-rules.lock"
    Add-Plan "write .tic-rules.lock"
    if (-not $DryRun) {
        $installedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $content = @"
managed_by=team-intelligence-center
version=1
rules_version=$Version
package_id=$PackageId
install_mode=minimal
rules_dir=$RulesDir
installed_at=$installedAt
"@
        Set-Content -LiteralPath $target -Value $content -Encoding UTF8
    }
}

Merge-Agents
Install-TemplateFile (Join-Path $PackageRoot "templates/docs/ai-rules-usage.md") (Join-Path $ProjectRoot "docs/ai-rules-usage.md")
Install-TemplateFile (Join-Path $PackageRoot "templates/ai-harness/project-adapter.md") (Join-Path $ProjectRoot "ai-harness/project-adapter.md")
Write-LockFile

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
