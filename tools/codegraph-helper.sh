#!/usr/bin/env bash
set -euo pipefail

COMMAND="status"
PROJECT_ROOT="$PWD"
QUERY=""

usage() {
  cat <<'USAGE'
Usage:
  bash tools/codegraph-helper.sh [status|init|context|impact|affected] [--project PATH] [query-or-file]

CodeGraph is optional. This helper does not install CodeGraph and does not run init unless you explicitly pass "init".
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    status|init|context|impact|affected)
      COMMAND="$1"
      shift
      ;;
    --project)
      PROJECT_ROOT="${2:-}"
      if [ -z "$PROJECT_ROOT" ]; then
        echo "--project requires a path" >&2
        exit 1
      fi
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [ -z "$QUERY" ]; then
        QUERY="$1"
      else
        QUERY="$QUERY $1"
      fi
      shift
      ;;
  esac
done

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "项目目录不存在: $PROJECT_ROOT" >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

codegraph_bin=""
if command -v codegraph >/dev/null 2>&1; then
  codegraph_bin="$(command -v codegraph)"
fi

has_project_graph="no"
if [ -d "$PROJECT_ROOT/.codegraph" ]; then
  has_project_graph="yes"
fi

print_status() {
  echo "TIC CodeGraph Helper"
  echo "project: $PROJECT_ROOT"
  if [ -n "$codegraph_bin" ]; then
    echo "codegraph_cli: $codegraph_bin"
  else
    echo "codegraph_cli: not found"
  fi
  echo "project_graph: $has_project_graph"
  echo
  echo "建议:"
  if [ -z "$codegraph_bin" ]; then
    echo "- 未检测到 CodeGraph CLI。需要时请按官方文档安装 colbymchenry/codegraph。"
    echo "- 本 helper 不会通过 npx 自动下载或安装 CodeGraph。"
  fi
  if [ "$has_project_graph" = "no" ]; then
    echo "- 如本项目是老项目、monorepo 或跨模块改动，可显式运行 init 初始化 .codegraph。"
  fi
  echo "- CodeGraph 只作为上下文增强层，不替代 SDD + TDD。"
  echo "- 原始 .codegraph 是否提交由业务项目决定；不确定时先加入本地忽略或只保留摘要。"
}

run_codegraph() {
  if [ -z "$codegraph_bin" ]; then
    echo "未检测到 CodeGraph CLI，无法执行 $COMMAND。" >&2
    echo "请先按官方文档安装 colbymchenry/codegraph。" >&2
    exit 1
  fi

  cd "$PROJECT_ROOT"
  case "$COMMAND" in
    init)
      # Explicitly requested by the user; this may create .codegraph in the target project.
      $codegraph_bin init -i
      ;;
    context)
      if [ -z "$QUERY" ]; then
        echo "context 需要 query 参数" >&2
        exit 1
      fi
      $codegraph_bin context "$QUERY"
      ;;
    impact)
      if [ -z "$QUERY" ]; then
        echo "impact 需要文件或符号参数" >&2
        exit 1
      fi
      $codegraph_bin impact "$QUERY"
      ;;
    affected)
      if [ -n "$QUERY" ]; then
        $codegraph_bin affected "$QUERY"
      else
        $codegraph_bin affected
      fi
      ;;
    *)
      print_status
      ;;
  esac
}

case "$COMMAND" in
  status)
    print_status
    ;;
  init|context|impact|affected)
    run_codegraph
    ;;
  *)
    usage
    exit 1
    ;;
esac
