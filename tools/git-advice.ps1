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
                $custom = $Matches[1].Trim().TrimEnd("/")
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
        $refs = @(git for-each-ref --format='%(refname)' refs/heads refs/remotes 2>$null)
    } catch {
        $refs = @()
    }
    foreach ($ref in $refs) {
        if ($ref -match '^refs/(?:heads|remotes/[^/]+)/(?:release|hotfix)/([0-9]+)\.([0-9]+)\.([0-9]{3})$') {
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
    $patch = [int]$Matches[3]
    if ($patch -ge 999) {
        return "needs-user-decision"
    }
    $patch += 1
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

function Test-LocalBranchExists {
    param([string]$Name)
    try {
        git show-ref --verify --quiet "refs/heads/$Name"
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Get-RemoteBranchRefs {
    param([string]$Name)
    try {
        return @(git for-each-ref --format='%(refname:short)' "refs/remotes/*/$Name" 2>$null)
    } catch {
        return @()
    }
}

function Get-BranchDivergenceStatus {
    param([string]$Name)
    $localSha = ""
    try {
        $localSha = git rev-parse --verify "refs/heads/$Name" 2>$null
    } catch {
        $localSha = ""
    }
    $remoteShas = @()
    try {
        $remoteShas = @(git for-each-ref --format='%(objectname)' "refs/remotes/*/$Name" 2>$null | Sort-Object -Unique)
    } catch {
        $remoteShas = @()
    }
    if ($remoteShas.Count -eq 0) {
        return "no"
    }
    if (-not [string]::IsNullOrWhiteSpace($localSha)) {
        foreach ($sha in $remoteShas) {
            if ($sha -ne $localSha) {
                return "yes"
            }
        }
        return "no"
    }
    if ($remoteShas.Count -gt 1) {
        return "yes"
    }
    return "no"
}

function Get-FirstRemoteBaseRef {
    param([string]$Name)
    try {
        $refs = @(git for-each-ref --format='%(refname:short)' "refs/remotes/*/$Name" 2>$null)
        if ($refs.Count -gt 0) {
            return $refs[0]
        }
    } catch {
    }
    return ""
}

function Get-BaseSyncStatus {
    param([string]$Base, [string]$Remote)
    $localRef = ""
    try {
        $localRef = git rev-parse --verify $Base 2>$null
    } catch {
        $localRef = ""
    }
    if ([string]::IsNullOrWhiteSpace($localRef)) {
        return "local-missing"
    }
    if ([string]::IsNullOrWhiteSpace($Remote)) {
        return "no-upstream"
    }
    $remoteRef = ""
    try {
        $remoteRef = git rev-parse --verify $Remote 2>$null
    } catch {
        $remoteRef = ""
    }
    if ([string]::IsNullOrWhiteSpace($remoteRef)) {
        return "remote-missing"
    }
    if ($localRef -eq $remoteRef) {
        return "up-to-date"
    }
    git merge-base --is-ancestor $Base $Remote 2>$null
    if ($LASTEXITCODE -eq 0) {
        return "behind"
    }
    git merge-base --is-ancestor $Remote $Base 2>$null
    if ($LASTEXITCODE -eq 0) {
        return "ahead"
    }
    return "diverged"
}

$maxVersion = Get-MaxReleaseVersion
$nextVersion = Get-NextReleaseVersion $maxVersion
$tagStyle = Get-VisibleTagStyle
$releaseRegistryRoots = Get-ReleaseRegistryRoots
$remoteFetchStatus = "not_run_by_git_advice"
$remoteFetchRequired = "git fetch --all --prune --tags"
$versionRolloverStatus = "ok"
if ($nextVersion -eq "needs-user-decision") {
    $versionRolloverStatus = "needs-user-decision"
}

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
    if ($tagStyle -in @("mixed", "legacy-v-prefix")) {
        $suggestedTag = "needs-user-decision:$tagStyle"
    }
} else {
    $suggestedBranch = "$branchPrefix/$slug"
    $suggestedTag = "n/a"
}
$suggestedCommit = "$commitType($scope): describe change in Chinese"

$expectedBase = "develop"
if ($branchPrefix -eq "hotfix") {
    $expectedBase = "master"
}
$baseUpstream = ""
try {
    $baseUpstream = git rev-parse --abbrev-ref --symbolic-full-name "$expectedBase@{u}" 2>$null
} catch {
    $baseUpstream = ""
}
if ([string]::IsNullOrWhiteSpace($baseUpstream)) {
    $baseUpstream = Get-FirstRemoteBaseRef $expectedBase
}
$baseBranchSyncStatus = Get-BaseSyncStatus $expectedBase $baseUpstream
$suggestedBranchExistsLocal = if (Test-LocalBranchExists $suggestedBranch) { "yes" } else { "no" }
$suggestedBranchRemoteRefs = @(Get-RemoteBranchRefs $suggestedBranch)
$suggestedBranchExistsRemote = if ($suggestedBranchRemoteRefs.Count -gt 0) { "yes" } else { "no" }
$suggestedBranchRemoteRefsText = if ($suggestedBranchRemoteRefs.Count -gt 0) { $suggestedBranchRemoteRefs -join "," } else { "none" }
$suggestedBranchDiverged = Get-BranchDivergenceStatus $suggestedBranch

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
Write-Host "remote_fetch_status: $remoteFetchStatus"
Write-Host "remote_fetch_required: $remoteFetchRequired"
Write-Host "expected_base_branch: $expectedBase"
if ([string]::IsNullOrWhiteSpace($baseUpstream)) {
    Write-Host "base_upstream: none"
} else {
    Write-Host "base_upstream: $baseUpstream"
}
Write-Host "base_branch_sync_status: $baseBranchSyncStatus"
Write-Host "feature_branch_policy: business slug or issue-business slug"
Write-Host "release_hotfix_version_policy: version-style *.*.*** max + patch increment"
Write-Host "version_rollover_status: $versionRolloverStatus"
Write-Host "tag_policy: pure version *.*.*** without v prefix"
Write-Host "release_registry_roots: $($releaseRegistryRoots -join ',')"
if ([string]::IsNullOrWhiteSpace($maxVersion)) {
    Write-Host "max_visible_release_version: none"
} else {
    Write-Host "max_visible_release_version: $maxVersion"
}
Write-Host "visible_tag_style: $tagStyle"
Write-Host "suggested_branch: $suggestedBranch"
Write-Host "suggested_branch_exists_local: $suggestedBranchExistsLocal"
Write-Host "suggested_branch_exists_remote: $suggestedBranchExistsRemote"
Write-Host "suggested_branch_remote_refs: $suggestedBranchRemoteRefsText"
Write-Host "suggested_branch_diverged: $suggestedBranchDiverged"
Write-Host "suggested_tag: $suggestedTag"
Write-Host "suggested_commit: $suggestedCommit"
if ($branchPrefix -eq "feature") {
    Write-Host "branch_slug_status: $slugStatus"
}
Write-Host ""
Write-Host "Read-only recommendations:"
Write-Host "- Run git fetch --all --prune --tags before creating any feature/release/hotfix branch or trusting version/tag advice."
if ($longLived -eq "yes") {
    Write-Host "- Prepare a branch creation confirmation card before code changes."
}
if ($baseBranchSyncStatus -ne "up-to-date") {
    $baseLabel = if ([string]::IsNullOrWhiteSpace($baseUpstream)) { "upstream" } else { $baseUpstream }
    Write-Host "- Resolve base branch sync status before creating a branch: $expectedBase is $baseBranchSyncStatus against $baseLabel."
}
if ($suggestedBranchExistsLocal -eq "yes" -or $suggestedBranchExistsRemote -eq "yes" -or $suggestedBranchDiverged -eq "yes") {
    Write-Host "- Suggested branch is already present or diverged locally/remotely; pause for user decision."
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
if ($versionRolloverStatus -eq "needs-user-decision") {
    Write-Host "- Release patch version reached 999; pause and ask the user to decide the next version line."
}
if ($changedCount -gt 0) {
    Write-Host "- Review existing working tree changes before editing or staging."
    Write-Host "- Stage explicit paths only; avoid broad add commands."
}
if (($statusLines -join "`n") -match '(^|\s)(\.env|.*\.local|\.DS_Store|\.omx/)') {
    Write-Host "- Local/runtime files are present; do not stage secrets, local config, or runtime state."
}
Write-Host "- This script will not execute git fetch, switch, add, commit, push, merge, tag, or branch deletion."
