param(
    [ValidateSet("status", "init", "context", "impact", "affected")]
    [string]$Command = "status",
    [string]$ProjectRoot = (Get-Location).Path,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Query
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "项目目录不存在: $ProjectRoot"
}

$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$queryText = ($Query -join " ")
$codegraphCommand = $null

$codegraph = Get-Command codegraph -ErrorAction SilentlyContinue
if ($codegraph) {
    $codegraphCommand = @($codegraph.Source)
}

$hasProjectGraph = Test-Path -LiteralPath (Join-Path $ProjectRoot ".codegraph") -PathType Container

function Write-CodeGraphStatus {
    Write-Host "TIC CodeGraph Helper"
    Write-Host "project: $ProjectRoot"
    if ($codegraphCommand) {
        Write-Host "codegraph_cli: $($codegraphCommand -join ' ')"
    } else {
        Write-Host "codegraph_cli: not found"
    }
    if ($hasProjectGraph) {
        Write-Host "project_graph: yes"
    } else {
        Write-Host "project_graph: no"
    }
    Write-Host ""
    Write-Host "建议:"
    if (-not $codegraphCommand) {
        Write-Host "- 未检测到 CodeGraph CLI。需要时请按官方文档安装 colbymchenry/codegraph。"
        Write-Host "- 本 helper 不会通过 npx 自动下载或安装 CodeGraph。"
    }
    if (-not $hasProjectGraph) {
        Write-Host "- 如本项目是老项目、monorepo 或跨模块改动，可显式运行 init 初始化 .codegraph。"
    }
    Write-Host "- CodeGraph 只作为上下文增强层，不替代 SDD + TDD。"
    Write-Host "- 原始 .codegraph 是否提交由业务项目决定；不确定时先加入本地忽略或只保留摘要。"
}

function Invoke-CodeGraph {
    param([string[]]$Arguments)
    if (-not $codegraphCommand) {
        Write-Error "未检测到 CodeGraph CLI，无法执行 $Command。请先按官方文档安装 colbymchenry/codegraph。"
        exit 1
    }
    Push-Location $ProjectRoot
    try {
        $executable = $codegraphCommand[0]
        $baseArgs = @()
        if ($codegraphCommand.Count -gt 1) {
            $baseArgs = @($codegraphCommand | Select-Object -Skip 1)
        }
        $allArgs = @($baseArgs + $Arguments)
        & $executable @allArgs
    } finally {
        Pop-Location
    }
}

switch ($Command) {
    "status" {
        Write-CodeGraphStatus
    }
    "init" {
        Invoke-CodeGraph @("init", "-i")
    }
    "context" {
        if ([string]::IsNullOrWhiteSpace($queryText)) {
            throw "context 需要 query 参数"
        }
        Invoke-CodeGraph @("context", $queryText)
    }
    "impact" {
        if ([string]::IsNullOrWhiteSpace($queryText)) {
            throw "impact 需要文件或符号参数"
        }
        Invoke-CodeGraph @("impact", $queryText)
    }
    "affected" {
        if ([string]::IsNullOrWhiteSpace($queryText)) {
            Invoke-CodeGraph @("affected")
        } else {
            Invoke-CodeGraph @("affected", $queryText)
        }
    }
}
