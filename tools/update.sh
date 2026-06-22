#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$PWD"
PROJECT_PROVIDED=0
PREVIEW=0
SKIP_PULL=0
SKIP_GLOBAL=0
SKIP_PROJECT=0
CODEX_HOME_ARG=()

usage() {
  cat <<'USAGE'
Usage:
  bash tools/update.sh [--preview] [--project PATH] [--codex-home PATH] [--no-pull] [--no-global] [--no-project]

Defaults:
  One-command update for Team-Intelligence-Center users.
  Pulls the rules source, refreshes Codex global wrappers, and refreshes the current project entrypoint.

Options:
  --preview, --dry-run
                  Show planned actions without changing files.
  --project PATH  Target business project root. Defaults to the current directory.
  --codex-home PATH
                  Target Codex home for global loader refresh.
  --no-pull       Do not update the rules source from Git.
  --no-global     Do not refresh Codex global loader and tic-* wrappers.
  --no-project    Do not refresh the business project entrypoint.
  --help, -h      Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --preview|--dry-run)
      PREVIEW=1
      shift
      ;;
    --project)
      PROJECT_ROOT="${2:-}"
      if [ -z "$PROJECT_ROOT" ]; then
        echo "--project requires a path" >&2
        exit 1
      fi
      PROJECT_PROVIDED=1
      shift 2
      ;;
    --codex-home)
      codex_home="${2:-}"
      if [ -z "$codex_home" ]; then
        echo "--codex-home requires a path" >&2
        exit 1
      fi
      CODEX_HOME_ARG=("--codex-home" "$codex_home")
      shift 2
      ;;
    --no-pull)
      SKIP_PULL=1
      shift
      ;;
    --no-global)
      SKIP_GLOBAL=1
      shift
      ;;
    --no-project)
      SKIP_PROJECT=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      PROJECT_ROOT="$1"
      PROJECT_PROVIDED=1
      shift
      ;;
  esac
done

if [ "$SKIP_PROJECT" -eq 0 ]; then
  if [ ! -d "$PROJECT_ROOT" ]; then
    echo "Project root does not exist: $PROJECT_ROOT" >&2
    exit 1
  fi
  PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
  if [ "$PROJECT_PROVIDED" -eq 0 ] && [ "$PROJECT_ROOT" = "$PACKAGE_ROOT" ]; then
    SKIP_PROJECT=1
  fi
fi

run_or_print() {
  if [ "$PREVIEW" -eq 1 ]; then
    printf '  - would run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

relative_to_project() {
  case "$PACKAGE_ROOT/" in
    "$PROJECT_ROOT/"*)
      printf '%s' "${PACKAGE_ROOT#$PROJECT_ROOT/}"
      ;;
    *)
      return 1
      ;;
  esac
}

update_rules_source() {
  if [ "$SKIP_PULL" -eq 1 ]; then
    printf 'Rules source update skipped by --no-pull.\n'
    return
  fi

  if ! git -C "$PACKAGE_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Rules source is not a Git repository; skipping pull: %s\n' "$PACKAGE_ROOT"
    return
  fi

  local branch rel_path
  branch="$(git -C "$PACKAGE_ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [ -n "$branch" ]; then
    printf 'Updating rules source on branch %s...\n' "$branch"
    run_or_print git -C "$PACKAGE_ROOT" pull --ff-only
    return
  fi

  if [ "$SKIP_PROJECT" -eq 0 ] && rel_path="$(relative_to_project)" && git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Rules source appears to be a detached submodule; updating from project root...\n'
    run_or_print git -C "$PROJECT_ROOT" submodule update --remote -- "$rel_path"
    printf 'If the submodule pointer changed, review and commit it in the business project.\n'
    return
  fi

  printf 'Rules source is detached and no project submodule context was found; skipping pull: %s\n' "$PACKAGE_ROOT"
}

printf 'Team-Intelligence-Center one-command update\n'
printf 'rules_dir: %s\n' "$PACKAGE_ROOT"
if [ "$SKIP_PROJECT" -eq 0 ]; then
  printf 'project: %s\n' "$PROJECT_ROOT"
else
  printf 'project: skipped\n'
fi
printf 'mode: %s\n\n' "$([ "$PREVIEW" -eq 1 ] && printf preview || printf apply)"

update_rules_source

printf '\nValidating rules package...\n'
run_or_print bash "$SCRIPT_DIR/validate-pack.sh"

if [ "$SKIP_GLOBAL" -eq 0 ]; then
  printf '\nRefreshing Codex global loader...\n'
  if [ "$PREVIEW" -eq 1 ]; then
    run_or_print bash "$SCRIPT_DIR/install-codex-global.sh" --dry-run --rules-dir "$PACKAGE_ROOT" "${CODEX_HOME_ARG[@]}"
  else
    run_or_print bash "$SCRIPT_DIR/install-codex-global.sh" --yes --rules-dir "$PACKAGE_ROOT" "${CODEX_HOME_ARG[@]}"
  fi
else
  printf '\nCodex global loader refresh skipped by --no-global.\n'
fi

if [ "$SKIP_PROJECT" -eq 0 ]; then
  printf '\nRefreshing project entrypoint...\n'
  if [ "$PREVIEW" -eq 1 ]; then
    run_or_print bash "$SCRIPT_DIR/install.sh" --preview --rules-dir "$PACKAGE_ROOT" "$PROJECT_ROOT"
  else
    run_or_print bash "$SCRIPT_DIR/install.sh" --refresh --rules-dir "$PACKAGE_ROOT" "$PROJECT_ROOT"
  fi
else
  printf '\nProject refresh skipped. Run from a business project or pass --project PATH.\n'
fi

if [ "$PREVIEW" -eq 1 ]; then
  printf '\nDry run only. No files changed.\n'
else
  printf '\nTIC update complete.\n'
fi
