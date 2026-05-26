param(
    [ValidateSet("feature", "feat", "fix", "bug", "docs", "doc", "chore", "refactor")]
    [string]$Type = "feature",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Task
)

$ErrorActionPreference = "Stop"

function Slugify {
    param([string]$Text)
    $lower = $Text.ToLowerInvariant()
    $slug = [regex]::Replace($lower, "[^a-z0-9]+", "-")
    $slug = $slug.Trim("-")
    if ($slug.Length -gt 40) {
        $slug = $slug.Substring(0, 40).TrimEnd("-")
    }
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return "task"
    }
    return $slug
}

$inside = $false
try {
    $inside = ((git rev-parse --is-inside-work-tree 2>$null) -eq "true")
} catch {
    $inside = $false
}

if (-not $inside) {
    Write-Host "TIC Git Advice"
    Write-Host "status: not a git repository"
    Write-Host "action: no git workflow advice available"
    exit 0
}

$repoRoot = git rev-parse --show-toplevel
$branch = git branch --show-current 2>$null
if ([string]::IsNullOrWhiteSpace($branch)) {
    $branch = "DETACHED_HEAD"
}

$upstream = ""
try {
    $upstream = git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
} catch {
    $upstream = ""
}

$statusLines = @(git status --porcelain)
$changedCount = @($statusLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
$taskText = ($Task -join " ")
$slug = Slugify $taskText

switch ($Type) {
    { $_ -in @("fix", "bug") } {
        $branchPrefix = "fix"
        $commitType = "fix"
        break
    }
    { $_ -in @("docs", "doc") } {
        $branchPrefix = "docs"
        $commitType = "docs"
        break
    }
    "chore" {
        $branchPrefix = "chore"
        $commitType = "chore"
        break
    }
    "refactor" {
        $branchPrefix = "refactor"
        $commitType = "refactor"
        break
    }
    default {
        $branchPrefix = "feature"
        $commitType = "feat"
    }
}

$longLived = "no"
if ($branch -in @("main", "master", "develop", "dev") -or $branch -like "release/*" -or $branch -like "hotfix/*") {
    $longLived = "yes"
}

$scope = $slug
if ($scope -eq "task") {
    $scope = "core"
}

$suggestedBranch = "$branchPrefix/$slug"
$suggestedCommit = "$commitType($scope): describe change in Chinese"

Write-Host "TIC Git Advice"
Write-Host "repo: $repoRoot"
Write-Host "branch: $branch"
if ([string]::IsNullOrWhiteSpace($upstream)) {
    Write-Host "upstream: none"
} else {
    Write-Host "upstream: $upstream"
}
Write-Host "changed_files: $changedCount"
Write-Host "long_lived_branch: $longLived"
Write-Host "suggested_branch: $suggestedBranch"
Write-Host "suggested_commit: $suggestedCommit"
Write-Host ""
Write-Host "Read-only recommendations:"
if ($longLived -eq "yes") {
    Write-Host "- Consider creating a short task branch before code changes."
}
if ($changedCount -gt 0) {
    Write-Host "- Review existing working tree changes before editing or staging."
    Write-Host "- Stage explicit paths only; avoid broad add commands."
}
if (($statusLines -join "`n") -match '(^|\s)(\.env|.*\.local|\.DS_Store|\.omx/)') {
    Write-Host "- Local/runtime files are present; do not stage secrets, local config, or runtime state."
}
Write-Host "- This script will not execute git switch, add, commit, push, merge, tag, or branch deletion."

