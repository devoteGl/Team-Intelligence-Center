#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$PWD"
DRY_RUN=0
YES=0
FORCE=0
RULES_DIR=""
STAMP="$(date +%Y%m%d%H%M%S)"

usage() {
  cat <<'USAGE'
Usage:
  bash tools/bootstrap-project.sh [--dry-run] [--yes] [--force] [--rules-dir PATH] [PROJECT_ROOT]

Options:
  --dry-run        Show planned writes without changing files.
  --yes, -y        Skip interactive confirmation.
  --force          Overwrite existing docs/ai-rules-usage.md and ai-harness/project-adapter.md after backing them up.
  --rules-dir PATH Path that the target project should use to find Team-Intelligence-Center.
  --help, -h       Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes|-y)
      YES=1
      shift
      ;;
    --force)
      FORCE=1
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
      shift
      ;;
  esac
done

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "Project root does not exist: $PROJECT_ROOT" >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
RULES_DIR="${RULES_DIR:-$PACKAGE_ROOT}"
VERSION="$(tr -d '[:space:]' < "$PACKAGE_ROOT/VERSION" 2>/dev/null || echo unknown)"
PACKAGE_ID="Team_Intelligence_Center_${VERSION}"
BEGIN_MARKER="<!-- TIC_LIGHT_AUTOMATION_BEGIN -->"
END_MARKER="<!-- TIC_LIGHT_AUTOMATION_END -->"

if [ "$DRY_RUN" -eq 0 ] && [ "$YES" -eq 0 ] && [ -t 0 ]; then
  printf 'Install Team-Intelligence-Center lightweight rules into %s? [y/N] ' "$PROJECT_ROOT"
  read -r answer
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Cancelled before writing."
      exit 1
      ;;
  esac
fi

planned=()

plan() {
  planned+=("$1")
}

render_template() {
  local src="$1"
  TIC_RULES_DIR="$RULES_DIR" TIC_VERSION="$VERSION" perl -pe '
    s/\{\{TIC_RULES_DIR\}\}/$ENV{TIC_RULES_DIR}/g;
    s/\{\{TIC_VERSION\}\}/$ENV{TIC_VERSION}/g;
  ' "$src"
}

backup_file() {
  local target="$1"
  local rel="${target#$PROJECT_ROOT/}"
  local backup="$PROJECT_ROOT/.tic-backups/$STAMP/$rel"
  mkdir -p "$(dirname "$backup")"
  cp "$target" "$backup"
}

merge_agents() {
  local template="$PACKAGE_ROOT/templates/AGENTS.md"
  local target="$PROJECT_ROOT/AGENTS.md"
  local rendered block tmp

  rendered="$(mktemp)"
  block="$(mktemp)"
  tmp="$(mktemp)"
  render_template "$template" > "$rendered"
  {
    printf '%s\n' "$BEGIN_MARKER"
    cat "$rendered"
    printf '%s\n' "$END_MARKER"
  } > "$block"

  if [ ! -e "$target" ]; then
    plan "create AGENTS.md"
    if [ "$DRY_RUN" -eq 0 ]; then
      cp "$block" "$target"
    fi
  elif grep -Fq "$BEGIN_MARKER" "$target" && grep -Fq "$END_MARKER" "$target"; then
    plan "replace TIC block in AGENTS.md"
    if [ "$DRY_RUN" -eq 0 ]; then
      backup_file "$target"
      BLOCK_FILE="$block" BEGIN="$BEGIN_MARKER" END="$END_MARKER" perl -0pi -e '
        my $block_file = $ENV{"BLOCK_FILE"};
        my $begin = quotemeta($ENV{"BEGIN"});
        my $end = quotemeta($ENV{"END"});
        open my $fh, "<", $block_file or die $!;
        local $/;
        my $block = <$fh>;
        s/$begin.*?$end/$block/s;
      ' "$target"
    fi
  else
    plan "append TIC block to AGENTS.md"
    if [ "$DRY_RUN" -eq 0 ]; then
      backup_file "$target"
      {
        cat "$target"
        printf '\n\n'
        cat "$block"
      } > "$tmp"
      mv "$tmp" "$target"
    fi
  fi

  rm -f "$rendered" "$block" "$tmp"
}

install_template_file() {
  local src="$1"
  local dst="$2"
  local rel="${dst#$PROJECT_ROOT/}"

  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    plan "skip existing $rel"
    return
  fi

  if [ -e "$dst" ]; then
    plan "overwrite $rel with backup"
  else
    plan "create $rel"
  fi

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
      backup_file "$dst"
    fi
    render_template "$src" > "$dst"
  fi
}

write_lock() {
  local target="$PROJECT_ROOT/.tic-rules.lock"
  plan "write .tic-rules.lock"
  if [ "$DRY_RUN" -eq 0 ]; then
    cat > "$target" <<EOF
managed_by=team-intelligence-center
version=1
rules_version=$VERSION
package_id=$PACKAGE_ID
install_mode=minimal
rules_dir=$RULES_DIR
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
  fi
}

merge_agents
install_template_file "$PACKAGE_ROOT/templates/docs/ai-rules-usage.md" "$PROJECT_ROOT/docs/ai-rules-usage.md"
install_template_file "$PACKAGE_ROOT/templates/ai-harness/project-adapter.md" "$PROJECT_ROOT/ai-harness/project-adapter.md"
write_lock

printf 'Team-Intelligence-Center bootstrap plan for %s:\n' "$PROJECT_ROOT"
for item in "${planned[@]}"; do
  printf '  - %s\n' "$item"
done

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\nDry run only. No files changed.\n'
  exit 0
fi

printf '\nBootstrap complete.\n'
