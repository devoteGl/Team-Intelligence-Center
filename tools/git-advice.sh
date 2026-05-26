#!/usr/bin/env bash
set -euo pipefail

TASK_TYPE="feature"
TASK_TEXT=""

usage() {
  cat <<'USAGE'
Usage:
  bash tools/git-advice.sh [--type feature|fix|docs|chore|refactor] [task description]

This script is read-only. It does not create branches, stage files, commit, push, merge, or install hooks.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --type)
      TASK_TYPE="${2:-}"
      if [ -z "$TASK_TYPE" ]; then
        echo "--type requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [ -z "$TASK_TEXT" ]; then
        TASK_TEXT="$1"
      else
        TASK_TEXT="$TASK_TEXT $1"
      fi
      shift
      ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "TIC Git Advice"
  echo "status: not a git repository"
  echo "action: no git workflow advice available"
  exit 0
fi

repo_root="$(git rev-parse --show-toplevel)"
branch="$(git branch --show-current 2>/dev/null || true)"
if [ -z "$branch" ]; then
  branch="DETACHED_HEAD"
fi

upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
status="$(git status --porcelain)"
changed_count="$(printf '%s\n' "$status" | sed '/^$/d' | wc -l | tr -d '[:space:]')"

slugify() {
  printf '%s' "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' |
    cut -c1-40 |
    sed -E 's/-+$//'
}

slug="$(slugify "$TASK_TEXT")"
if [ -z "$slug" ]; then
  slug="task"
fi

case "$TASK_TYPE" in
  fix|bug)
    branch_prefix="fix"
    commit_type="fix"
    ;;
  docs|doc)
    branch_prefix="docs"
    commit_type="docs"
    ;;
  chore)
    branch_prefix="chore"
    commit_type="chore"
    ;;
  refactor)
    branch_prefix="refactor"
    commit_type="refactor"
    ;;
  feature|feat|*)
    branch_prefix="feature"
    commit_type="feat"
    ;;
esac

long_lived="no"
case "$branch" in
  main|master|develop|dev|release/*|hotfix/*)
    long_lived="yes"
    ;;
esac

scope="$slug"
if [ "$scope" = "task" ]; then
  scope="core"
fi
suggested_branch="$branch_prefix/$slug"
suggested_commit="$commit_type($scope): describe change in Chinese"

echo "TIC Git Advice"
echo "repo: $repo_root"
echo "branch: $branch"
if [ -n "$upstream" ]; then
  echo "upstream: $upstream"
else
  echo "upstream: none"
fi
echo "changed_files: $changed_count"
echo "long_lived_branch: $long_lived"
echo "suggested_branch: $suggested_branch"
echo "suggested_commit: $suggested_commit"
echo
echo "Read-only recommendations:"
if [ "$long_lived" = "yes" ]; then
  echo "- Consider creating a short task branch before code changes."
fi
if [ "$changed_count" -gt 0 ]; then
  echo "- Review existing working tree changes before editing or staging."
  echo "- Stage explicit paths only; avoid broad add commands."
fi
if printf '%s\n' "$status" | grep -Eq '(^|\s)(\.env|.*\.local|\.DS_Store|\.omx/)'; then
  echo "- Local/runtime files are present; do not stage secrets, local config, or runtime state."
fi
echo "- This script will not execute git switch, add, commit, push, merge, tag, or branch deletion."

