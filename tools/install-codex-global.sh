#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN=0
YES=0
FORCE=0
RULES_DIR=""
STAMP="$(date +%Y%m%d%H%M%S)"

usage() {
  cat <<'USAGE'
Usage:
  bash tools/install-codex-global.sh [--dry-run] [--yes] [--force] [--codex-home PATH] [--rules-dir PATH]

Installs a small Codex global TIC loader and tic-* skill wrappers.
It does not copy TIC project Skills into global skills.

Options:
  --dry-run, --preview
                  Show planned writes without changing files.
  --yes, -y       Skip interactive confirmation.
  --force         Overwrite existing non-TIC tic-* wrapper files after backup.
  --codex-home PATH
                  Target Codex home. Defaults to $CODEX_HOME or ~/.codex.
  --rules-dir PATH
                  Fallback Team-Intelligence-Center rules source path.
  --help, -h      Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run|--preview)
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
    --codex-home)
      CODEX_HOME="${2:-}"
      if [ -z "$CODEX_HOME" ]; then
        echo "--codex-home requires a path" >&2
        exit 1
      fi
      shift 2
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
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

CODEX_HOME="$(mkdir -p "$CODEX_HOME" && cd "$CODEX_HOME" && pwd)"
RULES_DIR="${RULES_DIR:-$PACKAGE_ROOT}"
RULES_DIR="$(cd "$RULES_DIR" && pwd)"
VERSION="$(tr -d '[:space:]' < "$PACKAGE_ROOT/VERSION" 2>/dev/null || echo unknown)"
BEGIN_MARKER="<!-- TIC_CODEX_GLOBAL_BEGIN -->"
END_MARKER="<!-- TIC_CODEX_GLOBAL_END -->"
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
  local rel="${target#$CODEX_HOME/}"
  local backup="$CODEX_HOME/.tic-backups/codex-global/$STAMP/$rel"
  mkdir -p "$(dirname "$backup")"
  cp "$target" "$backup"
}

merge_global_agents() {
  local template="$PACKAGE_ROOT/templates/codex-global/AGENTS.md"
  local target="$CODEX_HOME/AGENTS.md"
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
    plan "create AGENTS.md global TIC loader"
    if [ "$DRY_RUN" -eq 0 ]; then
      cp "$block" "$target"
    fi
  elif grep -Fq "$BEGIN_MARKER" "$target" && grep -Fq "$END_MARKER" "$target"; then
    plan "replace existing TIC loader block in AGENTS.md"
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
    plan "append TIC loader block to existing AGENTS.md"
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

install_skill_wrappers() {
  local src_dir="$PACKAGE_ROOT/templates/codex-global/skills"
  local src name dst

  for src in "$src_dir"/*/SKILL.md; do
    name="$(basename "$(dirname "$src")")"
    dst="$CODEX_HOME/skills/$name/SKILL.md"

    if [ -e "$dst" ] && ! grep -q 'Codex global wrapper for Team-Intelligence-Center' "$dst" && [ "$FORCE" -eq 0 ]; then
      plan "skip existing non-TIC skill wrapper: skills/$name/SKILL.md"
      continue
    fi

    if [ -e "$dst" ]; then
      plan "replace skills/$name/SKILL.md with backup"
    else
      plan "create skills/$name/SKILL.md"
    fi

    if [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$(dirname "$dst")"
      if [ -e "$dst" ]; then
        backup_file "$dst"
      fi
      render_template "$src" > "$dst"
    fi
  done
}

if [ "$DRY_RUN" -eq 0 ] && [ "$YES" -eq 0 ] && [ -t 0 ]; then
  printf 'Install TIC Codex global loader into %s? [y/N] ' "$CODEX_HOME"
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *)
      echo "Cancelled before writing."
      exit 1
      ;;
  esac
fi

merge_global_agents
install_skill_wrappers

printf 'Team-Intelligence-Center Codex global install plan for %s:\n' "$CODEX_HOME"
for item in "${planned[@]}"; do
  printf '  - %s\n' "$item"
done

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\nDry run only. No files changed.\n'
else
  printf '\nCodex global loader install complete.\n'
fi
