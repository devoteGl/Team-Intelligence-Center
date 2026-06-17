#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PACKAGE_ROOT"

failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$1"
}

require_file() {
  if [ -f "$1" ]; then
    pass "file exists: $1"
  else
    fail "missing file: $1"
  fi
}

require_dir() {
  if [ -d "$1" ]; then
    pass "dir exists: $1"
  else
    fail "missing dir: $1"
  fi
}

require_file VERSION
require_file manifest.json
require_file README.md
require_file USAGE.md
require_file Global-Rules/coding-rules.md
require_file Prompts/ai-prd-generator.rules.md
require_file Prompts/ai-prd-editor.rules.md
require_dir Skills
require_dir Design
require_file templates/AGENTS.md
require_file templates/docs/ai-rules-usage.md
require_file templates/ai-harness/project-adapter.md
require_file templates/codex-global/AGENTS.md
require_file docs/automation.md
require_file tools/bootstrap-project.ps1
require_file tools/bootstrap-project.sh
require_file tools/codegraph-helper.ps1
require_file tools/codegraph-helper.sh
require_file tools/git-advice.ps1
require_file tools/git-advice.sh
require_file tools/install-codex-global.ps1
require_file tools/install-codex-global.sh
require_file tools/install.ps1
require_file tools/install.sh
require_file tools/validate-pack.sh

version_file="$(tr -d '[:space:]' < VERSION 2>/dev/null || true)"
version_manifest="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' manifest.json | head -1)"

if [ -n "$version_file" ] && [ "$version_file" = "$version_manifest" ]; then
  pass "VERSION matches manifest.json ($version_file)"
else
  fail "VERSION ($version_file) does not match manifest.json ($version_manifest)"
fi

skill_count="$(find Skills -maxdepth 1 -type f -name '*.md' | wc -l | tr -d '[:space:]')"
if [ "$skill_count" -ge 15 ]; then
  pass "skill count >= 15 ($skill_count)"
else
  fail "expected at least 15 skill files, found $skill_count"
fi

while IFS= read -r skill_file; do
  if grep -q '^# ' "$skill_file" && grep -q '^## 技能用途' "$skill_file"; then
    pass "skill structure: $skill_file"
  else
    fail "skill missing title or 技能用途 section: $skill_file"
  fi
done < <(find Skills -maxdepth 1 -type f -name '*.md' | sort)

for script in tools/bootstrap-project.sh tools/codegraph-helper.sh tools/git-advice.sh tools/install-codex-global.sh tools/install.sh tools/validate-pack.sh; do
  if [ -x "$script" ]; then
    pass "script executable: $script"
  else
    fail "script is not executable: $script"
  fi
done

if grep -q 'TIC_LIGHT_AUTOMATION_BEGIN' tools/bootstrap-project.ps1 && grep -q '.tic-rules.lock' tools/bootstrap-project.ps1; then
  pass "PowerShell bootstrap has TIC markers and lock writer"
else
  fail "PowerShell bootstrap missing TIC markers or lock writer"
fi

if grep -q 'rules_path=' tools/bootstrap-project.sh && grep -q 'local_config=.tic-rules.local' tools/bootstrap-project.sh && grep -q '.tic-rules.local' tools/bootstrap-project.sh && grep -q '.tic-rules.local' tools/bootstrap-project.ps1 && ! grep -q '{{TIC_RULES_DIR}}' templates/AGENTS.md && ! grep -q '{{TIC_RULES_DIR}}' templates/docs/ai-rules-usage.md; then
  pass "project install avoids committed absolute rules paths"
else
  fail "project install must keep absolute rules paths out of committed templates"
fi

if grep -q 'git_workflow_advice_only' manifest.json && grep -q 'git switch, add, commit, push, merge, tag' tools/git-advice.ps1 && grep -q 'git switch, add, commit, push, merge, tag' tools/git-advice.sh; then
  pass "Git advice scripts are read-only by policy"
else
  fail "Git advice scripts or manifest do not record read-only policy"
fi

if grep -q 'SDD + TDD' templates/AGENTS.md && grep -q 'openspec_integration' manifest.json && grep -q 'sdd_tdd_required_for_standard_and_critical' manifest.json; then
  pass "SDD + TDD principle and OpenSpec integration are declared"
else
  fail "missing SDD + TDD principle or OpenSpec integration declaration"
fi

if grep -q 'post_dev_prd_sync' manifest.json && grep -q '开发后 PRD 同步' Skills/post-dev-prd-sync.md && grep -q '交付同步模式' Prompts/ai-prd-editor.rules.md && grep -q 'post-dev-prd-sync.md' templates/AGENTS.md; then
  pass "post-development PRD sync is declared"
else
  fail "missing post-development PRD sync policy"
fi

if grep -q 'delivery_walkthrough' manifest.json && grep -q '交付走查' Skills/delivery-walkthrough.md && grep -q 'delivery-walkthrough.md' templates/AGENTS.md && grep -q 'delivery-walkthrough' templates/codex-global/skills/tic-delivery-walkthrough/SKILL.md; then
  pass "delivery walkthrough is declared"
else
  fail "missing delivery walkthrough policy"
fi

if grep -q 'auto_project_profile' manifest.json && grep -q 'package.json' tools/bootstrap-project.sh && grep -q 'package.json' tools/bootstrap-project.ps1 && grep -q '项目画像' tools/bootstrap-project.sh && grep -q '项目画像' tools/bootstrap-project.ps1; then
  pass "bootstrap generates project adapter profile"
else
  fail "bootstrap must generate project adapter profile"
fi

if grep -q 'skills_reference_only_by_default' manifest.json && grep -q 'Skills 默认从解析出的规则源读取' templates/docs/ai-rules-usage.md && grep -q '不自动差量复制到项目本地 skills 或开发者全局 skills' templates/docs/ai-rules-usage.md; then
  pass "skills distribution is reference-only by default"
else
  fail "skills distribution policy must avoid automatic local/global copying"
fi

codex_wrapper_count="$(find templates/codex-global/skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d '[:space:]')"
if [ "$codex_wrapper_count" -ge 7 ] && grep -q 'codex_global_loader' manifest.json && grep -q '优先读取并遵守当前项目' templates/codex-global/AGENTS.md && grep -q 'rules_path=' templates/codex-global/AGENTS.md && grep -q '.tic-rules.local' templates/codex-global/AGENTS.md && grep -q 'Do not copy TIC Skills' templates/codex-global/skills/tic-post-dev-prd-sync/SKILL.md && grep -q 'tic-delivery-walkthrough' templates/codex-global/skills/tic-delivery-walkthrough/SKILL.md && grep -q 'TIC_CODEX_GLOBAL_BEGIN' tools/install-codex-global.sh; then
  pass "Codex global loader is wrapper-only and project-first"
else
  fail "Codex global loader must stay wrapper-only and project-first"
fi

if grep -q 'codegraph_optional' manifest.json && grep -q 'does not install CodeGraph' tools/codegraph-helper.sh && grep -q '不替代 SDD + TDD' tools/codegraph-helper.sh && grep -q '不替代 SDD + TDD' tools/codegraph-helper.ps1; then
  pass "CodeGraph helper is optional and non-core"
else
  fail "CodeGraph helper must remain optional and non-core"
fi

if grep -q 'ui_visual_verification' manifest.json && grep -q 'UI 验证规则' templates/AGENTS.md && grep -q 'Playwright' templates/AGENTS.md && grep -q 'Computer Use' templates/AGENTS.md && grep -q 'UI 变更验证' docs/automation.md; then
  pass "UI changes require real interface verification when risk warrants"
else
  fail "missing UI visual verification policy"
fi

if grep -q '轻量规则' templates/AGENTS.md && grep -q 'AI 规则使用说明' templates/docs/ai-rules-usage.md && grep -q '项目适配说明' templates/ai-harness/project-adapter.md && grep -q '轻量自动化设计' docs/automation.md; then
  pass "generated Markdown templates are Chinese-first"
else
  fail "generated Markdown templates must be Chinese-first"
fi

if grep -q 'no_git_hooks_by_default' manifest.json && grep -q 'no_forced_full_flow_for_readonly_or_micro_tasks' manifest.json; then
  pass "manifest records lightweight exclusions"
else
  fail "manifest does not record lightweight exclusions"
fi

if [ "$failures" -eq 0 ]; then
  printf '\nValidation passed.\n'
else
  printf '\nValidation failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi
