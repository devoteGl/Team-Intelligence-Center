param(
    [Parameter(Position = 0)]
    [string]$Path,
    [string]$Message
)

$ErrorActionPreference = "Stop"

if (-not [string]::IsNullOrWhiteSpace($Message)) {
    $content = $Message
} elseif (-not [string]::IsNullOrWhiteSpace($Path) -and
          (Test-Path -LiteralPath $Path -PathType Leaf)) {
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
} else {
    Write-Error "Usage: validate-commit-msg.ps1 [-Message TEXT] [COMMIT_MSG_FILE]"
}

$lines = @($content -split "`r?`n")
$header = $lines[0]
$pattern = '^(feat|fix|docs|style|refactor|perf|test|chore|ci|revert)\(([a-z0-9]+(?:-[a-z0-9]+)*)\): (.+)$'
if ($header -notmatch $pattern) {
    Write-Error "FAIL: header must match <type>(<lowercase-kebab-scope>): <中文祈使句>"
}

$scope = $Matches[2]
$subject = $Matches[3]
if ($scope -in @("project", "misc", "general", "update", "changes")) {
    Write-Error "FAIL: scope must identify a concrete domain or module"
}
if ($subject -notmatch '\p{IsCJKUnifiedIdeographs}') {
    Write-Error "FAIL: subject must contain concise Chinese wording"
}
if ($subject.Length -gt 50) {
    Write-Error "FAIL: subject exceeds 50 characters"
}
if ($subject -match '[。.]$') {
    Write-Error "FAIL: subject must not end with a period"
}
if ($lines.Count -gt 1 -and -not [string]::IsNullOrEmpty($lines[1])) {
    Write-Error "FAIL: body must be separated from the header by a blank line"
}
foreach ($line in $lines | Select-Object -Skip 2) {
    if ($line.Length -gt 72) {
        Write-Error "FAIL: body lines must not exceed 72 characters"
    }
}

Write-Host "PASS: commit message follows conventional-chinese-v1"
