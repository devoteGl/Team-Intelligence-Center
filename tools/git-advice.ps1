param(
    [ValidateSet("feature", "feat", "release", "hotfix", "fix", "bug", "docs", "doc", "chore", "refactor")]
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
        return ""
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
$slugStatus = "ok"
if ([string]::IsNullOrWhiteSpace($slug)) {
    $slug = "business-slug-required"
    $slugStatus = "needs_business_slug"
}

switch ($Type) {
    "release" {
        $branchPrefix = "release"
        $commitType = "chore"
        break
    }
    "hotfix" {
        $branchPrefix = "hotfix"
        $commitType = "fix"
        break
    }
    { $_ -in @("fix", "bug") } {
        $branchPrefix = "feature"
        $commitType = "fix"
        break
    }
    { $_ -in @("docs", "doc") } {
        $branchPrefix = "feature"
        $commitType = "docs"
        break
    }
    "chore" {
        $branchPrefix = "feature"
        $commitType = "chore"
        break
    }
    "refactor" {
        $branchPrefix = "feature"
        $commitType = "refactor"
        break
    }
    default {
        $branchPrefix = "feature"
        $commitType = "feat"
    }
}

function Get-ReleaseRegistryRoots {
    $roots = New-Object System.Collections.Generic.List[string]
    $roots.Add("docs/releases")
    $adapter = Join-Path $repoRoot "ai-harness/project-adapter.md"
    if (Test-Path -LiteralPath $adapter -PathType Leaf) {
        foreach ($line in Get-Content -LiteralPath $adapter) {
            if ($line -match '^\s*release_registry_root:\s*["'']?([^"#'']+)["'']?.*$') {
                $custom = $Matches[1].Trim()
                if (-not [string]::IsNullOrWhiteSpace($custom) -and -not $roots.Contains($custom)) {
                    $roots.Add($custom)
                }
                break
            }
        }
    }
    return @($roots)
}

function Get-MaxReleaseVersion {
    $maxKey = -1
    $maxVersion = ""
    $refs = @()
    try {
        $refs = @(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>$null)
    } catch {
        $refs = @()
    }
    foreach ($ref in $refs) {
        if ($ref -match '^(?:[^/]+/)?(?:release|hotfix)/([0-9]+)\.([0-9]+)\.([0-9]{3})$') {
            $key = ([int]$Matches[1] * 1000000) + ([int]$Matches[2] * 1000) + [int]$Matches[3]
            if ($key -gt $maxKey) {
                $maxKey = $key
                $maxVersion = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
            }
        }
    }

    $tags = @()
    try {
        $tags = @(git tag -l 2>$null)
    } catch {
        $tags = @()
    }
    foreach ($tag in $tags) {
        if ($tag -match '^v?([0-9]+)\.([0-9]+)\.([0-9]{3})$') {
            $key = ([int]$Matches[1] * 1000000) + ([int]$Matches[2] * 1000) + [int]$Matches[3]
            if ($key -gt $maxKey) {
                $maxKey = $key
                $maxVersion = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
            }
        }
    }

    foreach ($releaseRoot in Get-ReleaseRegistryRoots) {
        $releaseDir = Join-Path $repoRoot $releaseRoot
        if (Test-Path -LiteralPath $releaseDir -PathType Container) {
            foreach ($dir in Get-ChildItem -LiteralPath $releaseDir -Directory) {
                if ($dir.Name -match '^([0-9]+)\.([0-9]+)\.([0-9]{3})$') {
                    $key = ([int]$Matches[1] * 1000000) + ([int]$Matches[2] * 1000) + [int]$Matches[3]
                    if ($key -gt $maxKey) {
                        $maxKey = $key
                        $maxVersion = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
                    }
                }
            }
        }
    }

    return $maxVersion
}

function Get-NextReleaseVersion {
    param([string]$Current)
    if ([string]::IsNullOrWhiteSpace($Current)) {
        return "1.0.001"
    }
    if ($Current -notmatch '^([0-9]+)\.([0-9]+)\.([0-9]{3})$') {
        return "1.0.001"
    }
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3] + 1
    if ($patch -gt 999) {
        $minor += 1
        $patch = 0
    }
    return ("{0}.{1}.{2:D3}" -f $major, $minor, $patch)
}

function Get-VisibleTagStyle {
    $hasV = $false
    $hasPlain = $false
    $tags = @()
    try {
        $tags = @(git tag -l 2>$null)
    } catch {
        $tags = @()
    }
    foreach ($tag in $tags) {
        if ($tag -match '^v[0-9]+\.[0-9]+\.[0-9]{3}$') {
            $hasV = $true
        } elseif ($tag -match '^[0-9]+\.[0-9]+\.[0-9]{3}$') {
            $hasPlain = $true
        }
    }
    if ($hasV -and $hasPlain) {
        return "mixed"
    }
    if ($hasV) {
        return "legacy-v-prefix"
    }
    if ($hasPlain) {
        return "no-v"
    }
    return "none"
}

$maxVersion = Get-MaxReleaseVersion
$nextVersion = Get-NextReleaseVersion $maxVersion
$tagStyle = Get-VisibleTagStyle
$releaseRegistryRoots = Get-ReleaseRegistryRoots

$longLived = "no"
if ($branch -in @("main", "master", "develop", "dev") -or $branch -like "release/*" -or $branch -like "hotfix/*") {
    $longLived = "yes"
}

$scope = $slug
if ($scope -eq "business-slug-required") {
    $scope = "core"
}

if ($branchPrefix -in @("release", "hotfix")) {
    $suggestedBranch = "$branchPrefix/$nextVersion"
    $suggestedTag = $nextVersion
} else {
    $suggestedBranch = "$branchPrefix/$slug"
    $suggestedTag = "n/a"
}
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
Write-Host "feature_branch_policy: business slug or issue-business slug"
Write-Host "release_hotfix_version_policy: version-style *.*.*** max + patch increment"
Write-Host "tag_policy: pure version *.*.*** without v prefix"
Write-Host "release_registry_roots: $($releaseRegistryRoots -join ',')"
if ([string]::IsNullOrWhiteSpace($maxVersion)) {
    Write-Host "max_visible_release_version: none"
} else {
    Write-Host "max_visible_release_version: $maxVersion"
}
Write-Host "visible_tag_style: $tagStyle"
Write-Host "suggested_branch: $suggestedBranch"
Write-Host "suggested_tag: $suggestedTag"
Write-Host "suggested_commit: $suggestedCommit"
if ($branchPrefix -eq "feature") {
    Write-Host "branch_slug_status: $slugStatus"
}
Write-Host ""
Write-Host "Read-only recommendations:"
if ($longLived -eq "yes") {
    Write-Host "- Prepare a branch creation confirmation card before code changes."
}
if ($branchPrefix -in @("release", "hotfix")) {
    Write-Host "- Confirm the version-style branch and no-v tag candidate with the user before running git switch -c."
} else {
    Write-Host "- Confirm the business-named feature branch candidate with the user before running git switch -c."
}
if ($branchPrefix -eq "feature" -and $slugStatus -eq "needs_business_slug") {
    Write-Host "- Provide an issue id or short English business slug before creating the feature branch."
}
if ($tagStyle -eq "mixed") {
    Write-Host "- Existing tags mix v-prefix and no-v styles; pause and ask the user to decide the tag policy."
} elseif ($tagStyle -eq "legacy-v-prefix") {
    Write-Host "- Existing tags use v-prefix style; confirm migration before creating a no-v tag."
}
if ($changedCount -gt 0) {
    Write-Host "- Review existing working tree changes before editing or staging."
    Write-Host "- Stage explicit paths only; avoid broad add commands."
}
if (($statusLines -join "`n") -match '(^|\s)(\.env|.*\.local|\.DS_Store|\.omx/)') {
    Write-Host "- Local/runtime files are present; do not stage secrets, local config, or runtime state."
}
Write-Host "- This script will not execute git switch, add, commit, push, merge, tag, or branch deletion."
