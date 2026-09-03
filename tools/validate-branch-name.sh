#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash tools/validate-branch-name.sh BRANCH

Validates a branch name against tic-gitflow-v1. It does not modify Git state.
USAGE
}

if [ "$#" -ne 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  [ "$#" -eq 1 ] && exit 0
  exit 2
fi

branch="$1"
case "$branch" in
  master|develop)
    printf 'PASS: protected branch name %s\n' "$branch"
    exit 0
    ;;
esac

if [ "${#branch}" -gt 80 ]; then
  echo "FAIL: branch name exceeds 80 characters" >&2
  exit 1
fi

if printf '%s\n' "$branch" | grep -Eq \
  '^(release|hotfix)/[0-9]+\.[0-9]+\.[0-9]+$'; then
  printf 'PASS: version branch name %s\n' "$branch"
  exit 0
fi

if ! printf '%s\n' "$branch" | grep -Eq \
  '^(feature|fix|docs|style|refactor|perf|test|chore|ci|revert)/[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "FAIL: branch must use <type>/<lowercase-kebab-slug> or <release|hotfix>/<x.y.z>" >&2
  exit 1
fi

slug="${branch#*/}"
case "$slug" in
  project|misc|general|update|changes|temp|tmp)
    echo "FAIL: branch slug must identify a concrete business change" >&2
    exit 1
    ;;
esac

if [ "${#slug}" -lt 2 ] || [ "${#slug}" -gt 40 ]; then
  echo "FAIL: branch slug must contain 2-40 characters" >&2
  exit 1
fi

printf 'PASS: task branch name %s\n' "$branch"
