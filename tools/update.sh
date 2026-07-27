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
UPDATE_CHANNEL="stable"
REQUESTED_REF=""
REMOTE_NAME="origin"
CODEX_HOME_PATH=""

usage() {
  cat <<'USAGE'
Usage:
  bash tools/update.sh [--preview] [--channel stable|current] [--ref REF] [--remote NAME]
                       [--project PATH] [--codex-home PATH] [--no-pull] [--no-global] [--no-project]

Defaults:
  One-command update for Team-Intelligence-Center users.
  Updates the rules source, validates it, refreshes Codex global wrappers, and refreshes the current project entrypoint.

Options:
  --preview, --dry-run
                  Show planned actions without changing files.
  --project PATH  Target business project root. Defaults to the current directory.
  --codex-home PATH
                  Target Codex home for global loader refresh.
  --channel stable|current
                  stable selects the highest SemVer release tag (default).
                  current fast-forwards the currently checked-out branch.
  --ref REF       Pin an explicit tag, branch, or commit. Overrides --channel.
  --remote NAME   Git remote used for stable/ref updates. Defaults to origin.
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
      CODEX_HOME_PATH="${2:-}"
      if [ -z "$CODEX_HOME_PATH" ]; then
        echo "--codex-home requires a path" >&2
        exit 1
      fi
      shift 2
      ;;
    --channel)
      UPDATE_CHANNEL="${2:-}"
      case "$UPDATE_CHANNEL" in
        stable|current) ;;
        *)
          echo "--channel must be stable or current" >&2
          exit 1
          ;;
      esac
      shift 2
      ;;
    --ref)
      REQUESTED_REF="${2:-}"
      if [ -z "$REQUESTED_REF" ]; then
        echo "--ref requires a Git ref" >&2
        exit 1
      fi
      shift 2
      ;;
    --remote)
      REMOTE_NAME="${2:-}"
      if [ -z "$REMOTE_NAME" ]; then
        echo "--remote requires a name" >&2
        exit 1
      fi
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
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      PROJECT_ROOT="$1"
      PROJECT_PROVIDED=1
      shift
      ;;
  esac
done

case "$REQUESTED_REF" in
  -*) echo "--ref must not start with '-'" >&2; exit 1 ;;
esac
case "$REMOTE_NAME" in
  -*) echo "--remote must not start with '-'" >&2; exit 1 ;;
esac

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

refresh_codex_global() {
  local install_mode="$1"
  if [ -n "$CODEX_HOME_PATH" ]; then
    run_or_print bash "$SCRIPT_DIR/install-codex-global.sh" \
      "$install_mode" --rules-dir "$PACKAGE_ROOT" \
      --codex-home "$CODEX_HOME_PATH"
  else
    run_or_print bash "$SCRIPT_DIR/install-codex-global.sh" \
      "$install_mode" --rules-dir "$PACKAGE_ROOT"
  fi
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

  local branch latest_tag remote_ref remote_tags superproject
  branch="$(git -C "$PACKAGE_ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"

  if [ "$PREVIEW" -eq 0 ] && [ -n "$(git -C "$PACKAGE_ROOT" status --porcelain)" ]; then
    printf 'Rules source has uncommitted changes; refusing to switch or pull: %s\n' "$PACKAGE_ROOT" >&2
    printf 'Commit, stash, or rerun with --no-pull to refresh wrappers from the current worktree.\n' >&2
    exit 1
  fi

  if [ -n "$REQUESTED_REF" ]; then
    printf 'Pinning rules source to ref %s from %s...\n' "$REQUESTED_REF" "$REMOTE_NAME"
    run_or_print git -C "$PACKAGE_ROOT" fetch "$REMOTE_NAME" --prune --tags
    if [ "$PREVIEW" -eq 1 ]; then
      run_or_print git -C "$PACKAGE_ROOT" checkout --detach "$REQUESTED_REF"
    elif remote_ref="refs/remotes/$REMOTE_NAME/$REQUESTED_REF" &&
         git -C "$PACKAGE_ROOT" rev-parse --verify --quiet "$remote_ref^{commit}" >/dev/null; then
      git -C "$PACKAGE_ROOT" checkout --detach "$remote_ref"
    elif git -C "$PACKAGE_ROOT" rev-parse --verify --quiet "$REQUESTED_REF^{commit}" >/dev/null; then
      git -C "$PACKAGE_ROOT" checkout --detach "$REQUESTED_REF"
    else
      git -C "$PACKAGE_ROOT" fetch "$REMOTE_NAME" "$REQUESTED_REF"
      git -C "$PACKAGE_ROOT" checkout --detach FETCH_HEAD
    fi
  elif [ "$UPDATE_CHANNEL" = "current" ]; then
    if [ -z "$branch" ]; then
      printf 'Current channel requires a checked-out branch; use --channel stable or --ref REF.\n' >&2
      exit 1
    fi
    printf 'Updating rules source on current branch %s...\n' "$branch"
    run_or_print git -C "$PACKAGE_ROOT" pull --ff-only
  else
    printf 'Updating rules source from latest stable SemVer tag on %s...\n' "$REMOTE_NAME"
    run_or_print git -C "$PACKAGE_ROOT" fetch "$REMOTE_NAME" --prune --tags
    if ! remote_tags="$(
      git -C "$PACKAGE_ROOT" ls-remote --tags --refs "$REMOTE_NAME" |
        sed -nE 's#^[^[:space:]]+[[:space:]]+refs/tags/(.+)$#\1#p'
    )"; then
      printf 'Unable to read release tags from remote %s.\n' "$REMOTE_NAME" >&2
      exit 1
    fi
    latest_tag="$(printf '%s\n' "$remote_tags" | latest_semver_tag)"
    if [ -z "$latest_tag" ]; then
      if [ "$PREVIEW" -eq 1 ]; then
        printf '  - stable tag will be resolved after fetch\n'
      else
        printf 'No SemVer release tag is available. Use --channel current for a development branch or --ref REF to pin explicitly.\n' >&2
        exit 1
      fi
    else
      printf 'Selected stable tag: %s\n' "$latest_tag"
      run_or_print git -C "$PACKAGE_ROOT" checkout --detach "$latest_tag"
    fi
  fi

  superproject="$(git -C "$PACKAGE_ROOT" rev-parse --show-superproject-working-tree 2>/dev/null || true)"
  if [ -n "$superproject" ]; then
    printf 'Rules source is a submodule. Review and commit the parent project submodule pointer after validation: %s\n' "$superproject"
  fi
}

latest_semver_tag() {
  local tag version major minor patch selected=""
  local selected_major=-1 selected_minor=-1 selected_patch=-1
  while IFS= read -r tag; do
    version="${tag#v}"
    case "$version" in
      *[!0-9.]*|*.*.*.*) continue ;;
    esac
    if ! printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      continue
    fi
    IFS='.' read -r major minor patch <<EOF
$version
EOF
    major=$((10#$major))
    minor=$((10#$minor))
    patch=$((10#$patch))
    if [ "$major" -gt "$selected_major" ] ||
       { [ "$major" -eq "$selected_major" ] && [ "$minor" -gt "$selected_minor" ]; } ||
       { [ "$major" -eq "$selected_major" ] && [ "$minor" -eq "$selected_minor" ] && [ "$patch" -gt "$selected_patch" ]; }; then
      selected_major="$major"
      selected_minor="$minor"
      selected_patch="$patch"
      selected="$tag"
    elif [ "$major" -eq "$selected_major" ] &&
         [ "$minor" -eq "$selected_minor" ] &&
         [ "$patch" -eq "$selected_patch" ] &&
         [ "${selected#v}" = "$version" ] &&
         [ "$selected" != "$version" ]; then
      selected="$version"
    fi
  done
  printf '%s' "$selected"
}

printf 'Team-Intelligence-Center one-command update\n'
printf 'rules_dir: %s\n' "$PACKAGE_ROOT"
if [ "$SKIP_PROJECT" -eq 0 ]; then
  printf 'project: %s\n' "$PROJECT_ROOT"
else
  printf 'project: skipped\n'
fi
printf 'mode: %s\n\n' "$([ "$PREVIEW" -eq 1 ] && printf preview || printf apply)"
if [ -n "$REQUESTED_REF" ]; then
  printf 'update_ref: %s\n\n' "$REQUESTED_REF"
else
  printf 'update_channel: %s\n\n' "$UPDATE_CHANNEL"
fi

update_rules_source

printf 'active_rules_version: %s\n' "$(tr -d '[:space:]' < "$PACKAGE_ROOT/VERSION" 2>/dev/null || printf unknown)"

printf '\nValidating rules package...\n'
run_or_print bash "$SCRIPT_DIR/validate-pack.sh"

if [ "$SKIP_GLOBAL" -eq 0 ]; then
  printf '\nRefreshing Codex global loader...\n'
  if [ "$PREVIEW" -eq 1 ]; then
    refresh_codex_global --dry-run
  else
    refresh_codex_global --yes
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
