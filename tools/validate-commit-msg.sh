#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash tools/validate-commit-msg.sh COMMIT_MSG_FILE
  bash tools/validate-commit-msg.sh --message "type(scope): 中文祈使句"

Validates a commit message against conventional-chinese-v1.
USAGE
}

if [ "$#" -eq 1 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
  usage
  exit 0
elif [ "$#" -eq 2 ] && [ "$1" = "--message" ]; then
  content="$2"
elif [ "$#" -eq 1 ] && [ -f "$1" ]; then
  content="$(cat "$1")"
else
  usage >&2
  exit 2
fi

header="$(printf '%s\n' "$content" | sed -n '1p')"
pattern='^(feat|fix|docs|style|refactor|perf|test|chore|ci|revert)\([a-z0-9]+(-[a-z0-9]+)*\): .+$'
if ! printf '%s\n' "$header" | grep -Eq "$pattern"; then
  echo "FAIL: header must match <type>(<lowercase-kebab-scope>): <中文祈使句>" >&2
  exit 1
fi

scope="$(printf '%s\n' "$header" | sed -E 's/^[^(]+\(([^)]+)\):.*$/\1/')"
case "$scope" in
  project|misc|general|update|changes)
    echo "FAIL: scope must identify a concrete domain or module" >&2
    exit 1
    ;;
esac

subject="${header#*: }"
if ! printf '%s\n' "$subject" | grep -Eq '[一-龥]'; then
  echo "FAIL: subject must contain concise Chinese wording" >&2
  exit 1
fi
if [ "$(printf '%s' "$subject" | awk '{ print length($0) }')" -gt 50 ]; then
  echo "FAIL: subject exceeds 50 characters" >&2
  exit 1
fi
case "$subject" in
  *.|*。)
    echo "FAIL: subject must not end with a period" >&2
    exit 1
    ;;
esac

line_count="$(printf '%s\n' "$content" | awk 'END { print NR }')"
if [ "$line_count" -gt 1 ]; then
  second_line="$(printf '%s\n' "$content" | sed -n '2p')"
  if [ -n "$second_line" ]; then
    echo "FAIL: body must be separated from the header by a blank line" >&2
    exit 1
  fi
  if ! printf '%s\n' "$content" | awk 'NR > 2 && length($0) > 72 { exit 1 }'; then
    echo "FAIL: body lines must not exceed 72 characters" >&2
    exit 1
  fi
fi

printf 'PASS: commit message follows conventional-chinese-v1\n'
