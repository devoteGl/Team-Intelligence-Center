param(
    [switch]$Preview,
    [switch]$NoPull,
    [switch]$NoGlobal,
    [switch]$NoProject,
    [switch]$Help,
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$CodexHome = "",
    [ValidateSet("stable", "current")]
    [string]$Channel = "stable",
    [string]$TargetRef = "",
    [string]$Remote = "origin"
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File tools\update.ps1 [-Preview] [-Channel stable|current] [-TargetRef REF] [-Remote NAME]
    [-ProjectRoot PATH] [-CodexHome PATH] [-NoPull] [-NoGlobal] [-NoProject]

Defaults:
  One-command update for Team-Intelligence-Center users.
  Selects the latest stable SemVer tag, validates the rules source, refreshes Codex global wrappers,
  and refreshes the current project entrypoint.
"@
}

if ($Help) {
    Write-Usage
    exit 0
}

if ($TargetRef.StartsWith("-")) {
    throw "-TargetRef must not start with '-'."
}
if ($Remote.StartsWith("-")) {
    throw "-Remote must not start with '-'."
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
        $executable = $Command[0]
        $arguments = @()
        if ($Command.Count -gt 1) {
            $arguments = @($Command | Select-Object -Skip 1)
        }
        & $executable @arguments
    }
}

function Get-LatestSemVerTag {
    param([string]$RemoteName)
    $selectedTag = ""
    $selectedVersion = $null
    $remoteLines = @(git -C $PackageRoot ls-remote --tags --refs $RemoteName 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read release tags from remote $RemoteName."
    }
    foreach ($line in $remoteLines) {
        if ($line -notmatch '^[^\s]+\s+refs/tags/(.+)$') {
            continue
        }
        $tag = $Matches[1]
        $normalized = $tag -replace '^v', ''
        if ($normalized -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
            continue
        }
        try {
            $candidate = [version]$normalized
        } catch {
            continue
        }
        if ($null -eq $selectedVersion -or $candidate -gt $selectedVersion) {
            $selectedVersion = $candidate
            $selectedTag = $tag
        } elseif ($candidate -eq $selectedVersion -and $selectedTag.StartsWith("v") -and -not $tag.StartsWith("v")) {
            $selectedTag = $tag
        }
    }
    return $selectedTag
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

    if (-not $Preview) {
        $dirty = @(git -C $PackageRoot status --porcelain)
        if (@($dirty | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
            throw "Rules source has uncommitted changes. Commit, stash, or rerun with -NoPull to refresh wrappers from the current worktree."
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($TargetRef)) {
        Write-Host "Pinning rules source to ref $TargetRef from $Remote..."
        Invoke-OrPrint @("git", "-C", $PackageRoot, "fetch", $Remote, "--prune", "--tags")
        if ($Preview) {
            Invoke-OrPrint @("git", "-C", $PackageRoot, "checkout", "--detach", $TargetRef)
        } else {
            $refExists = $false
            try {
                git -C $PackageRoot rev-parse --verify --quiet "$TargetRef^{commit}" 2>$null | Out-Null
                $refExists = ($LASTEXITCODE -eq 0)
            } catch {
                $refExists = $false
            }
            if ($refExists) {
                $remoteRef = "refs/remotes/$Remote/$TargetRef"
                $remoteRefExists = $false
                try {
                    git -C $PackageRoot rev-parse --verify --quiet "$remoteRef^{commit}" 2>$null | Out-Null
                    $remoteRefExists = ($LASTEXITCODE -eq 0)
                } catch {
                    $remoteRefExists = $false
                }
                if ($remoteRefExists) {
                    git -C $PackageRoot checkout --detach $remoteRef
                } else {
                    git -C $PackageRoot checkout --detach $TargetRef
                }
            } else {
                git -C $PackageRoot fetch $Remote $TargetRef
                git -C $PackageRoot checkout --detach FETCH_HEAD
            }
        }
    } elseif ($Channel -eq "current") {
        $branch = ""
        try {
            $branch = git -C $PackageRoot symbolic-ref --quiet --short HEAD 2>$null
        } catch {
            $branch = ""
        }
        if ([string]::IsNullOrWhiteSpace($branch)) {
            throw "Current channel requires a checked-out branch. Use -Channel stable or -TargetRef REF."
        }
        Write-Host "Updating rules source on current branch $branch..."
        Invoke-OrPrint @("git", "-C", $PackageRoot, "pull", "--ff-only")
    } else {
        Write-Host "Updating rules source from latest stable SemVer tag on $Remote..."
        Invoke-OrPrint @("git", "-C", $PackageRoot, "fetch", $Remote, "--prune", "--tags")
        $latestTag = Get-LatestSemVerTag $Remote
        if ([string]::IsNullOrWhiteSpace($latestTag)) {
            if ($Preview) {
                Write-Host "  - stable tag will be resolved after fetch"
            } else {
                throw "No SemVer release tag is available. Use -Channel current for a development branch or -TargetRef REF to pin explicitly."
            }
        } else {
            Write-Host "Selected stable tag: $latestTag"
            Invoke-OrPrint @("git", "-C", $PackageRoot, "checkout", "--detach", $latestTag)
        }
    }

    $superproject = ""
    try {
        $superproject = git -C $PackageRoot rev-parse --show-superproject-working-tree 2>$null
    } catch {
        $superproject = ""
    }
    if (-not [string]::IsNullOrWhiteSpace($superproject)) {
        Write-Host "Rules source is a submodule. Review and commit the parent project submodule pointer after validation: $superproject"
    }
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
if (-not [string]::IsNullOrWhiteSpace($TargetRef)) {
    Write-Host "update_ref: $TargetRef"
} else {
    Write-Host "update_channel: $Channel"
}
Write-Host ""

Update-RulesSource

$activeVersion = "unknown"
$versionFile = Join-Path $PackageRoot "VERSION"
if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
    $activeVersion = (Get-Content -LiteralPath $versionFile -Raw).Trim()
}
Write-Host "active_rules_version: $activeVersion"

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
