#!/usr/bin/env bash
set -euo pipefail

TASK_TYPE="feature"
TASK_TEXT=""

usage() {
  cat <<'USAGE'
Usage:
  bash tools/git-advice.sh [--type feature|release|hotfix|fix|docs|chore|refactor] [task description]

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
slug_status="ok"
if [ -z "$slug" ]; then
  slug="business-slug-required"
  slug_status="needs_business_slug"
fi

case "$TASK_TYPE" in
  release)
    branch_prefix="release"
    commit_type="chore"
    ;;
  hotfix)
    branch_prefix="hotfix"
    commit_type="fix"
    ;;
  fix|bug)
    branch_prefix="feature"
    commit_type="fix"
    ;;
  docs|doc)
    branch_prefix="feature"
    commit_type="docs"
    ;;
  chore)
    branch_prefix="feature"
    commit_type="chore"
    ;;
  refactor)
    branch_prefix="feature"
    commit_type="refactor"
    ;;
  feature|feat|*)
    branch_prefix="feature"
    commit_type="feat"
    ;;
esac

release_registry_roots() {
  local adapter="$repo_root/ai-harness/project-adapter.md" custom=""
  printf '%s\n' "docs/releases"
  if [ -f "$adapter" ]; then
    custom="$(
      sed -nE "s/^[[:space:]]*release_registry_root:[[:space:]]*['\"]?([^'\"#]+)['\"]?.*$/\\1/p" "$adapter" |
        head -n 1 |
        sed -E 's/[[:space:]]+$//; s#/*$##'
    )"
    if [ -n "$custom" ] && [ "$custom" != "docs/releases" ]; then
      printf '%s\n' "$custom"
    fi
  fi
}

max_release_version() {
  local max_key=-1 max_version="" version major minor patch key release_root release_dir
  while IFS= read -r version; do
    [ -n "$version" ] || continue
    IFS='.' read -r major minor patch <<EOF
$version
EOF
    key=$((10#$major * 1000000 + 10#$minor * 1000 + 10#$patch))
    if [ "$key" -gt "$max_key" ]; then
      max_key="$key"
      max_version="$version"
    fi
  done < <(
    {
      git for-each-ref --format='%(refname)' refs/heads refs/remotes 2>/dev/null |
        sed -nE 's#^refs/heads/(release|hotfix)/([0-9]+\.[0-9]+\.[0-9]{3})$#\2#p; s#^refs/remotes/[^/]+/(release|hotfix)/([0-9]+\.[0-9]+\.[0-9]{3})$#\2#p'
      git tag -l 2>/dev/null |
        sed -nE 's#^v?([0-9]+\.[0-9]+\.[0-9]{3})$#\1#p'
      while IFS= read -r release_root; do
        release_dir="$repo_root/$release_root"
        if [ -d "$release_dir" ]; then
          find "$release_dir" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null |
            sed -nE 's#^.*/([0-9]+\.[0-9]+\.[0-9]{3})$#\1#p'
        fi
      done < <(release_registry_roots)
    } | sort -u
  )
  printf '%s' "$max_version"
}

next_release_version() {
  local current="$1" major minor patch
  if [ -z "$current" ]; then
    printf '1.0.001'
    return
  fi
  IFS='.' read -r major minor patch <<EOF
$current
EOF
  if [ "$((10#$patch))" -ge 999 ]; then
    printf 'needs-user-decision'
    return
  fi
  patch=$((10#$patch + 1))
  printf '%s.%s.%03d' "$major" "$minor" "$patch"
}

visible_tag_style() {
  local has_v="no" has_plain="no" tag
  while IFS= read -r tag; do
    case "$tag" in
      v[0-9]*.[0-9]*.[0-9][0-9][0-9])
        if printf '%s\n' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]{3}$'; then
          has_v="yes"
        fi
        ;;
      [0-9]*.[0-9]*.[0-9][0-9][0-9])
        if printf '%s\n' "$tag" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]{3}$'; then
          has_plain="yes"
        fi
        ;;
    esac
  done < <(git tag -l 2>/dev/null || true)

  if [ "$has_v" = "yes" ] && [ "$has_plain" = "yes" ]; then
    printf 'mixed'
  elif [ "$has_v" = "yes" ]; then
    printf 'legacy-v-prefix'
  elif [ "$has_plain" = "yes" ]; then
    printf 'no-v'
  else
    printf 'none'
  fi
}

branch_exists_local() {
  git show-ref --verify --quiet "refs/heads/$1" && printf 'yes' || printf 'no'
}

remote_branch_refs() {
  git for-each-ref --format='%(refname:short)' "refs/remotes/*/$1" 2>/dev/null || true
}

branch_exists_remote() {
  if [ -n "$(remote_branch_refs "$1")" ]; then
    printf 'yes'
  else
    printf 'no'
  fi
}

branch_divergence_status() {
  local target="$1" local_sha="" unique_remote_shas="" count=0 sha
  local_sha="$(git rev-parse --verify "refs/heads/$target" 2>/dev/null || true)"
  unique_remote_shas="$(git for-each-ref --format='%(objectname)' "refs/remotes/*/$target" 2>/dev/null | sort -u || true)"
  [ -n "$unique_remote_shas" ] || {
    printf 'no'
    return
  }
  if [ -n "$local_sha" ]; then
    while IFS= read -r sha; do
      [ -n "$sha" ] || continue
      if [ "$sha" != "$local_sha" ]; then
        printf 'yes'
        return
      fi
    done <<EOF
$unique_remote_shas
EOF
    printf 'no'
    return
  fi
  count="$(printf '%s\n' "$unique_remote_shas" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
  if [ "$count" -gt 1 ]; then
    printf 'yes'
  else
    printf 'no'
  fi
}

first_remote_base_ref() {
  git for-each-ref --format='%(refname:short)' "refs/remotes/*/$1" 2>/dev/null | head -n 1 || true
}

base_sync_status() {
  local base="$1" remote="$2" local_ref="" remote_ref=""
  local_ref="$(git rev-parse --verify "$base" 2>/dev/null || true)"
  [ -n "$local_ref" ] || {
    printf 'local-missing'
    return
  }
  [ -n "$remote" ] || {
    printf 'no-upstream'
    return
  }
  remote_ref="$(git rev-parse --verify "$remote" 2>/dev/null || true)"
  [ -n "$remote_ref" ] || {
    printf 'remote-missing'
    return
  }
  if [ "$local_ref" = "$remote_ref" ]; then
    printf 'up-to-date'
  elif git merge-base --is-ancestor "$base" "$remote" >/dev/null 2>&1; then
    printf 'behind'
  elif git merge-base --is-ancestor "$remote" "$base" >/dev/null 2>&1; then
    printf 'ahead'
  else
    printf 'diverged'
  fi
}

max_version="$(max_release_version)"
next_version="$(next_release_version "$max_version")"
tag_style="$(visible_tag_style)"
release_roots="$(release_registry_roots | paste -sd ',' -)"
remote_fetch_status="not_run_by_git_advice"
remote_fetch_required="git fetch --all --prune --tags"
version_rollover_status="ok"
if [ "$next_version" = "needs-user-decision" ]; then
  version_rollover_status="needs-user-decision"
fi

long_lived="no"
case "$branch" in
  main|master|develop|dev|release/*|hotfix/*)
    long_lived="yes"
    ;;
esac

scope="$slug"
if [ "$scope" = "business-slug-required" ]; then
  scope="core"
fi
if [ "$branch_prefix" = "release" ] || [ "$branch_prefix" = "hotfix" ]; then
  suggested_branch="$branch_prefix/$next_version"
  suggested_tag="$next_version"
  if [ "$tag_style" = "mixed" ] || [ "$tag_style" = "legacy-v-prefix" ]; then
    suggested_tag="needs-user-decision:$tag_style"
  fi
else
  suggested_branch="$branch_prefix/$slug"
  suggested_tag="n/a"
fi
suggested_commit="$commit_type($scope): describe change in Chinese"

expected_base="develop"
if [ "$branch_prefix" = "hotfix" ]; then
  expected_base="master"
fi
base_upstream="$(git rev-parse --abbrev-ref --symbolic-full-name "$expected_base@{u}" 2>/dev/null || true)"
if [ -z "$base_upstream" ]; then
  base_upstream="$(first_remote_base_ref "$expected_base")"
fi
base_branch_sync_status="$(base_sync_status "$expected_base" "$base_upstream")"
suggested_branch_exists_local="$(branch_exists_local "$suggested_branch")"
suggested_branch_remote_refs="$(remote_branch_refs "$suggested_branch" | paste -sd ',' -)"
if [ -z "$suggested_branch_remote_refs" ]; then
  suggested_branch_remote_refs="none"
fi
suggested_branch_exists_remote="$(branch_exists_remote "$suggested_branch")"
suggested_branch_diverged="$(branch_divergence_status "$suggested_branch")"

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
echo "remote_fetch_status: $remote_fetch_status"
echo "remote_fetch_required: $remote_fetch_required"
echo "expected_base_branch: $expected_base"
echo "base_upstream: ${base_upstream:-none}"
echo "base_branch_sync_status: $base_branch_sync_status"
echo "feature_branch_policy: business slug or issue-business slug"
echo "release_hotfix_version_policy: version-style *.*.*** max + patch increment"
echo "version_rollover_status: $version_rollover_status"
echo "tag_policy: pure version *.*.*** without v prefix"
echo "release_registry_roots: $release_roots"
if [ -n "$max_version" ]; then
  echo "max_visible_release_version: $max_version"
else
  echo "max_visible_release_version: none"
fi
echo "visible_tag_style: $tag_style"
echo "suggested_branch: $suggested_branch"
echo "suggested_branch_exists_local: $suggested_branch_exists_local"
echo "suggested_branch_exists_remote: $suggested_branch_exists_remote"
echo "suggested_branch_remote_refs: $suggested_branch_remote_refs"
echo "suggested_branch_diverged: $suggested_branch_diverged"
echo "suggested_tag: $suggested_tag"
echo "suggested_commit: $suggested_commit"
if [ "$branch_prefix" = "feature" ]; then
  echo "branch_slug_status: $slug_status"
fi
echo
echo "Read-only recommendations:"
echo "- Run git fetch --all --prune --tags before creating any feature/release/hotfix branch or trusting version/tag advice."
if [ "$long_lived" = "yes" ]; then
  echo "- Prepare a branch creation confirmation card before code changes."
fi
if [ "$base_branch_sync_status" != "up-to-date" ]; then
  echo "- Resolve base branch sync status before creating a branch: $expected_base is $base_branch_sync_status against ${base_upstream:-upstream}."
fi
if [ "$suggested_branch_exists_local" = "yes" ] || [ "$suggested_branch_exists_remote" = "yes" ] || [ "$suggested_branch_diverged" = "yes" ]; then
  echo "- Suggested branch is already present or diverged locally/remotely; pause for user decision."
fi
if [ "$branch_prefix" = "release" ] || [ "$branch_prefix" = "hotfix" ]; then
  echo "- Confirm the version-style branch and no-v tag candidate with the user before running git switch -c."
else
  echo "- Confirm the business-named feature branch candidate with the user before running git switch -c."
fi
if [ "$branch_prefix" = "feature" ] && [ "$slug_status" = "needs_business_slug" ]; then
  echo "- Provide an issue id or short English business slug before creating the feature branch."
fi
if [ "$tag_style" = "mixed" ]; then
  echo "- Existing tags mix v-prefix and no-v styles; pause and ask the user to decide the tag policy."
elif [ "$tag_style" = "legacy-v-prefix" ]; then
  echo "- Existing tags use v-prefix style; confirm migration before creating a no-v tag."
fi
if [ "$version_rollover_status" = "needs-user-decision" ]; then
  echo "- Release patch version reached 999; pause and ask the user to decide the next version line."
fi
if [ "$changed_count" -gt 0 ]; then
  echo "- Review existing working tree changes before editing or staging."
  echo "- Stage explicit paths only; avoid broad add commands."
fi
if printf '%s\n' "$status" | grep -Eq '(^|\s)(\.env|.*\.local|\.DS_Store|\.omx/)'; then
  echo "- Local/runtime files are present; do not stage secrets, local config, or runtime state."
fi
echo "- This script will not execute git fetch, switch, add, commit, push, merge, tag, or branch deletion."
