param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Branch
)

$ErrorActionPreference = "Stop"

if ($Branch -in @("master", "develop")) {
    Write-Host "PASS: protected branch name $Branch"
    exit 0
}
if ($Branch.Length -gt 80) {
    Write-Error "FAIL: branch name exceeds 80 characters"
}
if ($Branch -match '^(release|hotfix)/[0-9]+\.[0-9]+\.[0-9]{3}$') {
    Write-Host "PASS: version branch name $Branch"
    exit 0
}
if ($Branch -notmatch '^(feature|fix|docs|style|refactor|perf|test|chore|ci|revert)/[a-z0-9]+(-[a-z0-9]+)*$') {
    Write-Error "FAIL: branch must use <type>/<lowercase-kebab-slug> or <release|hotfix>/<x.y.zzz>"
}

$slug = $Branch.Split('/', 2)[1]
if ($slug -in @("project", "misc", "general", "update", "changes", "temp", "tmp")) {
    Write-Error "FAIL: branch slug must identify a concrete business change"
}
if ($slug.Length -lt 2 -or $slug.Length -gt 40) {
    Write-Error "FAIL: branch slug must contain 2-40 characters"
}

Write-Host "PASS: task branch name $Branch"
