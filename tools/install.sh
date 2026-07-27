#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$PWD"
PROJECT_PROVIDED=0
PREVIEW=0
FORCE=0
REGENERATE_ADAPTER=0
RULES_DIR=""

usage() {
  cat <<'USAGE'
Usage:
  bash tools/install.sh [--preview] [--refresh] [--regenerate-adapter] [--rules-dir PATH] [PROJECT_ROOT]

Defaults:
  Installs Team-Intelligence-Center lightweight rules into the current directory.

Options:
  --preview       Show planned writes without changing files.
  --refresh       Refresh generated entrypoint docs after backup; preserve the project adapter.
  --regenerate-adapter
                  Explicitly replace the project adapter with a newly detected profile after backup.
  --rules-dir PATH
                  Path to Team-Intelligence-Center. Project-local paths are committed as relative; external paths stay local.
  --help, -h      Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --preview|--dry-run)
      PREVIEW=1
      shift
      ;;
    --refresh|--force)
      FORCE=1
      shift
      ;;
    --regenerate-adapter)
      REGENERATE_ADAPTER=1
      shift
      ;;
    --rules-dir)
      RULES_DIR="${2:-}"
      if [ -z "$RULES_DIR" ]; then
        echo "--rules-dir requires a path" >&2
        exit 1
      fi
      shift 2
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

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
if [ "$PROJECT_PROVIDED" -eq 0 ] && [ "$PROJECT_ROOT" = "$PACKAGE_ROOT" ]; then
  cat >&2 <<'EOF'
Refusing to install into the rules package itself.
Run this from the target business project, or pass the project path:
  bash tools/install.sh /path/to/project
EOF
  exit 1
fi

args=("--yes")
if [ "$PREVIEW" -eq 1 ]; then
  args=("--dry-run")
fi
if [ "$FORCE" -eq 1 ]; then
  args+=("--force")
fi
if [ "$REGENERATE_ADAPTER" -eq 1 ]; then
  args+=("--regenerate-adapter")
fi
if [ -n "$RULES_DIR" ]; then
  args+=("--rules-dir" "$RULES_DIR")
fi
args+=("$PROJECT_ROOT")

bash "$SCRIPT_DIR/validate-pack.sh" >/dev/null
exec bash "$SCRIPT_DIR/bootstrap-project.sh" "${args[@]}"
