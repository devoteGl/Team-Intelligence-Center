param(
    [switch]$Preview,
    [switch]$Refresh,
    [switch]$Help,
    [string]$RulesDir = "",
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Write-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File tools\install.ps1 [-Preview] [-Refresh] [-RulesDir PATH] [-ProjectRoot PATH]

Defaults:
  Installs Team-Intelligence-Center lightweight rules into the current directory.

Options:
  -Preview      Show planned writes without changing files.
  -Refresh      Refresh generated docs after backing up existing files.
  -RulesDir     Path that the target project should record as the rules source.
  -ProjectRoot  Target project root. Defaults to the current directory.
"@
}

if ($Help) {
    Write-Usage
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$ProjectProvided = $PSBoundParameters.ContainsKey("ProjectRoot")
$validate = Join-Path $ScriptDir "validate-pack.sh"
$bootstrap = Join-Path $ScriptDir "bootstrap-project.ps1"

$ResolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not $ProjectProvided -and $ResolvedProjectRoot -eq $PackageRoot) {
    throw "Refusing to install into the rules package itself. Run this from the target business project, or pass -ProjectRoot C:\path\to\project."
}

if (Get-Command bash -ErrorAction SilentlyContinue) {
    bash $validate | Out-Null
} else {
    Write-Warning "bash not found; skipping validate-pack.sh before install."
}

$bootstrapArgs = @("-Yes", "-ProjectRoot", $ResolvedProjectRoot)
if ($Preview) {
    $bootstrapArgs = @("-DryRun", "-ProjectRoot", $ResolvedProjectRoot)
}
if ($Refresh) {
    $bootstrapArgs += "-Force"
}
if (-not [string]::IsNullOrWhiteSpace($RulesDir)) {
    $bootstrapArgs += @("-RulesDir", $RulesDir)
}

& $bootstrap @bootstrapArgs
