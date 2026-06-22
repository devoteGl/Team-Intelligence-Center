param(
    [switch]$Preview,
    [switch]$NoPull,
    [switch]$NoGlobal,
    [switch]$NoProject,
    [switch]$Help,
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$CodexHome = ""
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File tools\update.ps1 [-Preview] [-ProjectRoot PATH] [-CodexHome PATH] [-NoPull] [-NoGlobal] [-NoProject]

Defaults:
  One-command update for Team-Intelligence-Center users.
  Pulls the rules source, refreshes Codex global wrappers, and refreshes the current project entrypoint.
"@
}

if ($Help) {
    Write-Usage
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$ProjectProvided = $PSBoundParameters.ContainsKey("ProjectRoot")

if (-not $NoProject) {
    $ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
    if (-not $ProjectProvided -and $ProjectRoot -eq $PackageRoot) {
        $NoProject = $true
    }
}

function Invoke-OrPrint {
    param([string[]]$Command)
    if ($Preview) {
        Write-Host ("  - would run: " + ($Command -join " "))
    } else {
        & $Command[0] $Command[1..($Command.Count - 1)]
    }
}

function Get-RelativeRulesPath {
    if ($NoProject) {
        return ""
    }
    $prefix = $ProjectRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($PackageRoot.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $PackageRoot.Substring($prefix.Length)
    }
    return ""
}

function Update-RulesSource {
    if ($NoPull) {
        Write-Host "Rules source update skipped by -NoPull."
        return
    }

    $inside = $false
    try {
        $inside = ((git -C $PackageRoot rev-parse --is-inside-work-tree 2>$null) -eq "true")
    } catch {
        $inside = $false
    }
    if (-not $inside) {
        Write-Host "Rules source is not a Git repository; skipping pull: $PackageRoot"
        return
    }

    $branch = ""
    try {
        $branch = git -C $PackageRoot symbolic-ref --quiet --short HEAD 2>$null
    } catch {
        $branch = ""
    }
    if (-not [string]::IsNullOrWhiteSpace($branch)) {
        Write-Host "Updating rules source on branch $branch..."
        Invoke-OrPrint @("git", "-C", $PackageRoot, "pull", "--ff-only")
        return
    }

    $relativeRulesPath = Get-RelativeRulesPath
    $projectGit = $false
    if (-not [string]::IsNullOrWhiteSpace($relativeRulesPath)) {
        try {
            $projectGit = ((git -C $ProjectRoot rev-parse --is-inside-work-tree 2>$null) -eq "true")
        } catch {
            $projectGit = $false
        }
    }
    if ($projectGit) {
        Write-Host "Rules source appears to be a detached submodule; updating from project root..."
        Invoke-OrPrint @("git", "-C", $ProjectRoot, "submodule", "update", "--remote", "--", $relativeRulesPath)
        Write-Host "If the submodule pointer changed, review and commit it in the business project."
        return
    }

    Write-Host "Rules source is detached and no project submodule context was found; skipping pull: $PackageRoot"
}

Write-Host "Team-Intelligence-Center one-command update"
Write-Host "rules_dir: $PackageRoot"
if ($NoProject) {
    Write-Host "project: skipped"
} else {
    Write-Host "project: $ProjectRoot"
}
if ($Preview) {
    Write-Host "mode: preview"
} else {
    Write-Host "mode: apply"
}
Write-Host ""

Update-RulesSource

Write-Host ""
Write-Host "Validating rules package..."
if ($Preview) {
    Invoke-OrPrint @("bash", (Join-Path $ScriptDir "validate-pack.sh"))
} elseif (Get-Command bash -ErrorAction SilentlyContinue) {
    bash (Join-Path $ScriptDir "validate-pack.sh")
} else {
    Write-Warning "bash not found; skipping validate-pack.sh."
}

if (-not $NoGlobal) {
    Write-Host ""
    Write-Host "Refreshing Codex global loader..."
    $globalArgs = @()
    if ($Preview) {
        $globalArgs += "-DryRun"
    } else {
        $globalArgs += "-Yes"
    }
    if (-not [string]::IsNullOrWhiteSpace($CodexHome)) {
        $globalArgs += @("-CodexHome", $CodexHome)
    }
    $globalArgs += @("-RulesDir", $PackageRoot)
    & (Join-Path $ScriptDir "install-codex-global.ps1") @globalArgs
} else {
    Write-Host ""
    Write-Host "Codex global loader refresh skipped by -NoGlobal."
}

if (-not $NoProject) {
    Write-Host ""
    Write-Host "Refreshing project entrypoint..."
    $installArgs = @("-RulesDir", $PackageRoot, "-ProjectRoot", $ProjectRoot)
    if ($Preview) {
        $installArgs = @("-Preview") + $installArgs
    } else {
        $installArgs = @("-Refresh") + $installArgs
    }
    & (Join-Path $ScriptDir "install.ps1") @installArgs
} else {
    Write-Host ""
    Write-Host "Project refresh skipped. Run from a business project or pass -ProjectRoot PATH."
}

if ($Preview) {
    Write-Host ""
    Write-Host "Dry run only. No files changed."
} else {
    Write-Host ""
    Write-Host "TIC update complete."
}
