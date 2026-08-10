#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PACKAGE_ROOT"

failures=0
warnings=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
  warnings=$((warnings + 1))
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
require_file CHANGELOG.md
require_file LICENSE
require_file CONTRIBUTING.md
require_file SECURITY.md
require_file .github/PULL_REQUEST_TEMPLATE.md
require_file .github/ISSUE_TEMPLATE/bug_report.yml
require_file .github/ISSUE_TEMPLATE/feature_request.yml
require_file .github/ISSUE_TEMPLATE/config.yml
require_file Global-Rules/coding-rules.md
require_file Prompts/ai-prd-generator.rules.md
require_file Prompts/ai-prd-editor.rules.md
require_dir Workflow
require_file Workflow/core.md
require_file Workflow/capability-schema.md
require_file Workflow/scenarios.json
require_dir Skills
require_dir Design
require_file templates/AGENTS.md
require_file templates/docs/ai-rules-usage.md
require_file templates/ai-harness/project-adapter.md
require_file templates/ai-harness/agent-session-protocol.md
require_file templates/tool-rules/cursorrules.md
require_file templates/tool-rules/windsurfrules.md
require_file templates/tool-rules/rules/team-intelligence-center.md
require_file templates/codex-global/AGENTS.md
require_file docs/automation.md
require_file docs/sdd/tic-0.2.0-codex-gpt56.md
require_file docs/sdd/tic-0.2.1-project-adapter-preservation.md
require_file docs/sdd/tic-0.2.2-bash32-update.md
require_file docs/sdd/tic-0.3.0-e2e-verification-standardization.md
require_file docs/sdd/tic-0.5.0-workflow-core-redesign.md
require_file docs/sdd/tic-0.5.0-collaboration-intelligence-loop.md
require_file docs/sdd/tic-0.5.1-native-workflow-convergence.md
require_file docs/sdd/tic-0.5.2-skill-capability-convergence.md
require_file docs/releases/0.1.0/README.md
require_file docs/releases/0.2.0/README.md
require_file docs/releases/0.2.1/README.md
require_file docs/releases/0.2.1/evidence.md
require_file docs/releases/0.2.2/README.md
require_file docs/releases/0.2.2/evidence.md
require_file docs/releases/0.2.2/changes/bash32-update/README.md
require_file docs/releases/0.3.0/README.md
require_file docs/releases/0.3.0/evidence.md
require_file docs/releases/0.3.0/changes/e2e-verification-standardization/README.md
require_file docs/releases/0.5.0/README.md
require_file docs/releases/0.5.0/evidence.md
require_file docs/releases/0.5.0/changes/collaboration-intelligence-loop/README.md
require_file docs/releases/0.5.1/README.md
require_file docs/releases/0.5.1/evidence.md
require_file docs/releases/0.5.2/README.md
require_file docs/releases/0.5.2/evidence.md
require_file docs/test-evidence/tic-0.2.0/README.md
require_file docs/test-evidence/tic-0.2.1/README.md
require_file docs/test-evidence/tic-0.2.2/README.md
require_file docs/test-evidence/tic-0.3.0/README.md
require_file docs/test-evidence/tic-0.5.0/README.md
require_file docs/test-evidence/tic-0.5.1/README.md
require_file docs/test-evidence/tic-0.5.2/README.md
require_file docs/walkthroughs/tic-0.2.1-project-adapter-preservation.md
require_file docs/walkthroughs/tic-0.2.2-bash32-update.md
require_file docs/walkthroughs/tic-0.3.0-e2e-verification-standardization.md
require_file docs/walkthroughs/tic-0.5.0-collaboration-intelligence-loop.md
require_file docs/walkthroughs/tic-0.5.1-native-workflow-convergence.md
require_file docs/walkthroughs/tic-0.5.2-skill-capability-convergence.md
require_file Skills/project-adapter-maintainer.md
require_file templates/codex-global/skills/tic-project-adapter-maintainer/SKILL.md
require_file Skills/e2e-verification.md
require_file templates/codex-global/skills/tic-e2e-verification/SKILL.md
require_file Skills/collaboration-memory-maintainer.md
require_file templates/codex-global/skills/tic-collaboration-memory-maintainer/SKILL.md
require_file templates/ai-harness/memory/README.md
require_file templates/ai-harness/memory/project-context.md
require_file templates/ai-harness/memory/decision-log.md
require_file templates/ai-harness/memory/runbooks.md
require_file templates/ai-harness/memory/team-collaboration.md
require_file templates/tic-local/collaboration-profile.md
require_file templates/tic-local/memory-candidates.md
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
require_file tools/update.ps1
require_file tools/update.sh
require_file tools/validate-pack.sh

version_file="$(tr -d '[:space:]' < VERSION 2>/dev/null || true)"
version_manifest="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' manifest.json | head -1)"

if [ -n "$version_file" ] && [ "$version_file" = "$version_manifest" ]; then
  pass "VERSION matches manifest.json ($version_file)"
else
  fail "VERSION ($version_file) does not match manifest.json ($version_manifest)"
fi

if [ -f Workflow/core.md ] &&
   grep -q '`outcome`' Workflow/core.md &&
   grep -q '`boundaries`' Workflow/core.md &&
   grep -q '`done`' Workflow/core.md &&
   grep -q '`verification`' Workflow/core.md &&
   grep -q '`authority`' Workflow/core.md &&
   grep -q '`planning_depth`' Workflow/core.md &&
   grep -q '`execution_authority`' Workflow/core.md &&
   grep -q '`verification_scope`' Workflow/core.md &&
   grep -q '`review_level`' Workflow/core.md &&
   grep -q '`fact_persistence`' Workflow/core.md &&
   ! grep -Eq '三种执行模式|所有任务从 `direct` 开始' Workflow/core.md; then
  pass "workflow core separates task contract, planning, authority, verification, review, and persistence"
else
  fail "workflow core must use the five independent decision dimensions"
fi

scenario_block() {
  awk -v target="\"id\": \"$1\"" '
    /"id"[[:space:]]*:/ {
      if (printing) {
        exit
      }
      if (index($0, target) > 0) {
        printing = 1
      }
    }
    printing {
      print
    }
  ' Workflow/scenarios.json
}

scenario_matches() {
  local scenario_content
  local expected_pattern
  scenario_content="$(scenario_block "$1")"
  shift
  for expected_pattern in "$@"; do
    if ! printf '%s\n' "$scenario_content" | grep -q "$expected_pattern"; then
      return 1
    fi
  done
}

if scenario_matches local-bug-fix \
     '"planning_depth": "inline"' '"execution_authority": "autonomous"' \
     '"verification_scope": "targeted"' '"review_level": "self"' \
     '"fact_persistence": "task-context"' '"checkpoint": false' &&
   scenario_matches large-local-refactor \
     '"planning_depth": "living"' '"execution_authority": "autonomous"' \
     '"verification_scope": "integration"' '"review_level": "independent"' &&
   scenario_matches shared-api-change \
     '"planning_depth": "brief"' '"execution_authority": "autonomous"' \
     '"verification_scope": "integration"' '"review_level": "independent"' \
     '"fact_persistence": "openspec"' &&
   scenario_matches key-user-journey \
     '"verification_scope": "e2e"' '"review_level": "self"' &&
   scenario_matches production-migration \
     '"planning_depth": "living"' '"execution_authority": "confirmation-required"' \
     '"verification_scope": "operational"' '"review_level": "independent"' \
     '"checkpoint": true' &&
   scenario_matches collaboration-memory-candidate \
     '"fact_persistence": "local-candidate"' '"checkpoint": false' &&
   scenario_matches release-branch-push \
     '"execution_authority": "confirmation-required"' \
     '"review_level": "independent"' '"checkpoint": true' &&
   ! grep -Eq '"mode"[[:space:]]*:' Workflow/scenarios.json; then
  pass "workflow scenarios keep planning, authority, verification, review, and persistence independent"
else
  fail "workflow scenarios must exercise the five independent decision dimensions"
fi

if grep -q '`outcome`' templates/AGENTS.md &&
   grep -q '`verification`' templates/AGENTS.md &&
   grep -q '`authority`' templates/AGENTS.md &&
   grep -q '普通任务直接调查、修改和验证' templates/AGENTS.md &&
   grep -q 'Superpowers.*方法库' templates/AGENTS.md &&
   grep -q 'OpenSpec.*长期规格' templates/AGENTS.md &&
   ! grep -Eq 'risk_floor|Skill DAG|single adaptive workflow' templates/AGENTS.md &&
   ! grep -Eq '新任务最多检索|Intake 最多|Closeout' templates/AGENTS.md; then
  pass "project template is outcome-driven without a mandatory workflow controller"
else
  fail "project template must expose the five-dimension native workflow"
fi

if grep -q 'Apache License' LICENSE &&
   grep -q '"license"[[:space:]]*:[[:space:]]*"Apache-2.0"' manifest.json &&
   grep -q '"release_status"[[:space:]]*:[[:space:]]*"public_preview"' manifest.json; then
  pass "open source metadata is declared"
else
  fail "missing Apache-2.0 license or public preview metadata"
fi

private_scan="$(mktemp)"
grep -R -nE '(ycbl|xadazhihui|NexusAI|https://github.com/<owner>|https://your-repo|https://github.com/YOUR_ORG|YOUR_ORG|/Users/ctrlc|Downloads/dczd)' \
  README.md USAGE.md docs Design Skills templates Global-Rules Prompts tools manifest.json CONTRIBUTING.md SECURITY.md .github 2>/dev/null |
  grep -v '^tools/validate-pack.sh:' > "$private_scan" || true
if [ -s "$private_scan" ]; then
  fail "private or placeholder source references remain: $(head -5 "$private_scan" | tr '\n' '; ')"
else
  pass "no private source references in distributable files"
fi
rm -f "$private_scan"

template_stack_scan="$(mktemp)"
grep -R -nE '(go-zero|Unibest|Admin Template|admin-template|项目模板组合|技术栈示例|模板组合|组织推荐模板|推荐模板|业务工程模板)' \
  README.md USAGE.md docs Design Skills templates Global-Rules Prompts manifest.json CONTRIBUTING.md SECURITY.md .github 2>/dev/null > "$template_stack_scan" || true
if [ -s "$template_stack_scan" ]; then
  fail "business stack template references remain: $(head -5 "$template_stack_scan" | tr '\n' '; ')"
else
  pass "no business stack template bundle references in distributable docs"
fi
rm -f "$template_stack_scan"

if grep -q '当前版本为 `0.5.2`' README.md &&
   grep -q '0.1.0.*0.2.0.*0.2.1' README.md &&
   grep -q '`0.2.2`、`0.3.0`、`0.5.0`、`0.5.1` 已归档，当前版本为 `0.5.2`' README.md &&
   grep -q '"previous_version_archive"[[:space:]]*:[[:space:]]*"docs/releases/0.5.1"' manifest.json &&
   [ ! -e docs/releases/0.4.0 ] &&
   [ ! -e docs/test-evidence/tic-0.4.0 ] &&
   grep -q 'd8fe814ad633bd06d6ead7815ad8f7d6d3db5324' docs/releases/0.1.0/README.md; then
  pass "current and archived release records are declared"
else
  fail "README and release archive must identify 0.5.2 and preserve earlier releases"
fi

skill_count="$(find Skills -maxdepth 1 -type f -name '*.md' | wc -l | tr -d '[:space:]')"
if [ "$skill_count" -ge 23 ]; then
  pass "skill count >= 23 ($skill_count)"
else
  fail "expected at least 23 skill files, found $skill_count"
fi

if [ ! -e Skills/sdd-writer.md ] &&
   [ ! -e Skills/tdd-operator.md ] &&
   [ ! -d templates/codex-global/skills/tic-sdd-writer ] &&
   [ ! -d templates/codex-global/skills/tic-tdd-operator ]; then
  pass "SDD/TDD stays workflow semantics, not standalone skill chain"
else
  fail "do not add standalone sdd-writer/tdd-operator skills that bypass OpenSpec or Superpowers"
fi

while IFS= read -r skill_file; do
  if grep -q '^# ' "$skill_file" && grep -q '^## 技能用途' "$skill_file"; then
    pass "skill structure: $skill_file"
  else
    fail "skill missing title or 技能用途 section: $skill_file"
  fi

  skill_header="$(sed -n '1,52p' "$skill_file")"
  if printf '%s\n' "$skill_header" | grep -q '^schema: tic_capability.v1$' &&
     printf '%s\n' "$skill_header" | grep -q '^id: ' &&
     printf '%s\n' "$skill_header" | grep -q '^status: ' &&
     printf '%s\n' "$skill_header" | grep -q '^category: ' &&
     printf '%s\n' "$skill_header" | grep -q '^activation:$' &&
     printf '%s\n' "$skill_header" | grep -q '^  when:$' &&
     printf '%s\n' "$skill_header" | grep -q '^  not_when:$' &&
     printf '%s\n' "$skill_header" | grep -q '^side_effects: ' &&
     printf '%s\n' "$skill_header" | grep -q '^artifacts:$' &&
     printf '%s\n' "$skill_header" | grep -q '^  default: ' &&
     printf '%s\n' "$skill_header" | grep -q '^  when_needed:' &&
     printf '%s\n' "$skill_header" | grep -q '^requires:' &&
     printf '%s\n' "$skill_header" | grep -q '^related:' &&
     ! printf '%s\n' "$skill_header" | grep -q '^risk_min: ' &&
     ! printf '%s\n' "$skill_header" | grep -q '^delegates_to:'; then
    pass "capability contract: $skill_file"
  else
    fail "skill missing tic_capability.v1 contract fields or retains workflow routing: $skill_file"
  fi
done < <(find Skills -maxdepth 1 -type f -name '*.md' | sort)

orchestrator_lines="$(wc -l < Skills/tic-workflow-orchestrator.md | tr -d '[:space:]')"
orchestrator_max_lines=240
if [ "$orchestrator_lines" -le "$orchestrator_max_lines" ] &&
   grep -q '^status: compatibility$' Skills/tic-workflow-orchestrator.md &&
   grep -q '不是普通任务入口' Skills/tic-workflow-orchestrator.md &&
   grep -q 'Workflow/core.md' Skills/tic-workflow-orchestrator.md &&
   grep -q '能力不得自动级联另一个能力' Workflow/core.md &&
   ! sed -n '1,45p' Skills/tic-workflow-orchestrator.md | grep -q '^delegates_to:'; then
  pass "workflow orchestrator is a bounded explicit planning and compatibility capability ($orchestrator_lines/$orchestrator_max_lines lines)"
else
  fail "workflow orchestrator must remain optional, bounded, and free of routing metadata"
fi

if grep -q '以下动作必须暂停确认' Global-Rules/coding-rules.md &&
   grep -q '确认只保护具体动作' Workflow/core.md &&
   grep -q 'execution_authority' Workflow/core.md &&
   grep -q 'checkpoint_policy' manifest.json &&
   grep -q '风险只保护产生风险的具体动作和必要范围' Global-Rules/coding-rules.md; then
  pass "checkpoints are action-triggered rather than stage-triggered"
else
  fail "checkpoint policy must pause on material decisions and high-risk actions, not every phase"
fi

if grep -q 'Capability 是按事实选择的方法库' Workflow/core.md &&
   grep -q 'Capability 之间没有默认' Skills/tic-workflow-orchestrator.md &&
   ! grep -q 'Intake -> Planning -> Discovery' Skills/tic-workflow-orchestrator.md; then
  pass "workflow capabilities have no mandatory phase pipeline"
else
  fail "workflow must not restore a mandatory phase pipeline"
fi

if grep -q '只接入 TIC 轻量入口' Skills/project-governance-bootstrap.md &&
   grep -q '不安装 OpenSpec、Superpowers' Skills/project-governance-bootstrap.md &&
   grep -q 'tools/bootstrap-project' Skills/project-governance-bootstrap.md &&
   ! grep -Eq '自动检测并尽力安装|npm install -g|git submodule add' \
     Skills/project-governance-bootstrap.md; then
  pass "project bootstrap stays cohesive and does not install external workflow systems"
else
  fail "project bootstrap must only install TIC entrypoints and leave external tools explicit"
fi

if grep -q '只有共享契约跨越实现边界' Skills/contract-handoff.md &&
   grep -q '单个内部实现' Skills/contract-handoff.md &&
   ! grep -q '满足任一条件即触发' Skills/contract-handoff.md &&
   ! grep -q '任务需要 FE/BE 并行。' Skills/contract-handoff.md; then
  pass "contract handoff is triggered by shared-contract coordination, not API keywords"
else
  fail "contract handoff must not become an automatic gate for every API or parallel task"
fi

if grep -q '切换任务或' Global-Rules/coding-rules.md &&
   grep -q '跨独立任务、跨工具、长时异步' Skills/agent-session-protocol.md &&
   grep -q '同一 Codex 任务内的原生 subagent' templates/ai-harness/agent-session-protocol.md &&
   ! grep -R -nE '每次 AI 响应结束.*强制|每次响应结束.*强制|每次响应结束时自动执行' Global-Rules Skills README.md USAGE.md templates docs >/dev/null 2>&1; then
  pass "cross-task snapshot and agent artifact policy is conditional"
else
  fail "snapshot and agent artifacts must be conditional, not same-thread mandatory"
fi

alias_ok=1
for alias_file in Skills/api-contract-freezer.md Skills/fe-be-handoff.md Skills/conflict-arbiter.md Skills/release-ops-handoff.md Skills/release-train-handoff.md; do
  alias_lines="$(wc -l < "$alias_file" | tr -d '[:space:]')"
  if [ "$alias_lines" -gt 90 ] ||
     ! sed -n '1,24p' "$alias_file" | grep -q '^status: alias$' ||
     ! grep -q '本文件是兼容入口，不再维护独立正文模板' "$alias_file" ||
     ! grep -q 'canonical Skill' "$alias_file"; then
    alias_ok=0
  fi
done
if [ "$alias_ok" -eq 1 ]; then
  pass "legacy alias skills are thin canonical redirects"
else
  fail "legacy alias skills must stay thin redirects to canonical skills"
fi

for script in tools/bootstrap-project.sh tools/codegraph-helper.sh tools/git-advice.sh tools/install-codex-global.sh tools/install.sh tools/update.sh tools/validate-pack.sh; do
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

if grep -nE '&[[:space:]]+\$[A-Za-z0-9_]+\[0\]|[A-Za-z0-9_]+\[1\.\.\(\$[A-Za-z0-9_]+\.Count[[:space:]]*-[[:space:]]*1\)\]' tools/*.ps1 >/dev/null 2>&1; then
  fail "PowerShell scripts contain brittle direct array invocation or range slicing"
else
  pass "PowerShell command invocation avoids brittle array indexing"
fi

if command -v pwsh >/dev/null 2>&1; then
  powershell_tmp="$(mktemp -d)"
  powershell_project="$powershell_tmp/sample-project"
  mkdir -p "$powershell_project"
  if pwsh -NoProfile -File tools/bootstrap-project.ps1 -Yes -Force \
       -ProjectRoot "$powershell_project" >/dev/null &&
     grep -q 'memory_root: "ai-harness/memory"' \
       "$powershell_project/ai-harness/project-adapter.md" &&
     grep -Fxq '.tic/local/' "$powershell_project/.gitignore" &&
     [ -f "$powershell_project/ai-harness/memory/team-collaboration.md" ] &&
     printf '\nSENTINEL_POWERSHELL_MEMORY\n' >> \
       "$powershell_project/ai-harness/memory/team-collaboration.md" &&
     powershell_memory_before="$(cksum "$powershell_project/ai-harness/memory/team-collaboration.md")" &&
     pwsh -NoProfile -File tools/bootstrap-project.ps1 -Yes -Force \
       -ProjectRoot "$powershell_project" >/dev/null &&
     [ "$powershell_memory_before" = \
       "$(cksum "$powershell_project/ai-harness/memory/team-collaboration.md")" ]; then
    pass "PowerShell bootstrap creates and preserves shared memory"
  else
    fail "PowerShell bootstrap must create and preserve shared memory"
  fi
  rm -rf "$powershell_tmp"
else
  warn "pwsh unavailable; PowerShell runtime fixture is partial and remains a long-term validation item"
fi

if grep -q 'rules_path=' tools/bootstrap-project.sh &&
   grep -q 'local_config=.tic-rules.local' tools/bootstrap-project.sh &&
   grep -q '.tic-rules.local' tools/bootstrap-project.sh &&
   grep -q '.tic-rules.local' tools/bootstrap-project.ps1 &&
   grep -q '非空 `rules_path=`' templates/AGENTS.md &&
   grep -q '非空 `rules_path=`' templates/codex-global/AGENTS.md &&
   ! grep -q '{{TIC_RULES_DIR}}' templates/AGENTS.md &&
   ! grep -q '{{TIC_RULES_DIR}}' templates/docs/ai-rules-usage.md; then
  pass "project install avoids committed absolute rules paths"
else
  fail "project install must keep absolute rules paths out of committed templates"
fi

bootstrap_tmp="$(mktemp -d)"
bootstrap_project="$bootstrap_tmp/sample-project"
mkdir -p "$bootstrap_project"
cat > "$bootstrap_project/.tic-rules.lock" <<'EOF'
managed_by=team-intelligence-center
risk_floor=critical
custom_policy=keep-me
EOF
if bash tools/bootstrap-project.sh --yes --force "$bootstrap_project" >/dev/null &&
   ! grep -Fq "$bootstrap_tmp" "$bootstrap_project/ai-harness/project-adapter.md" &&
   ! grep -q '项目路径：' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q '项目根：当前仓库根' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'artifact_ownership:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'sdd_root:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'prd_draft_root:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'release_registry_root:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'memory_root: "ai-harness/memory"' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q '^verification:$' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q '^  e2e:$' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'test_command:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'auth_state_path:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'auth_state_policy: local-only' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'data_strategy: "待确认"' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'cleanup_command:' "$bootstrap_project/ai-harness/project-adapter.md" &&
   grep -q 'Agent Session Protocol' "$bootstrap_project/ai-harness/agent-session-protocol.md" &&
   [ -f "$bootstrap_project/ai-harness/memory/README.md" ] &&
   [ -f "$bootstrap_project/ai-harness/memory/project-context.md" ] &&
   [ -f "$bootstrap_project/ai-harness/memory/decision-log.md" ] &&
   [ -f "$bootstrap_project/ai-harness/memory/runbooks.md" ] &&
   [ -f "$bootstrap_project/ai-harness/memory/team-collaboration.md" ] &&
   grep -Fxq '.tic/local/' "$bootstrap_project/.gitignore" &&
   [ ! -e "$bootstrap_project/.tic/local/collaboration-profile.md" ] &&
   [ ! -e "$bootstrap_project/.tic/local/memory-candidates.md" ] &&
   grep -q '普通任务直接调查、修改和验证' "$bootstrap_project/.cursorrules" &&
   grep -q '普通任务直接调查、修改和验证' "$bootstrap_project/.windsurfrules" &&
   grep -q '普通任务直接调查、修改和验证' "$bootstrap_project/.rules/team-intelligence-center.md" &&
   grep -q '^risk_floor=critical$' "$bootstrap_project/.tic-rules.lock" &&
   grep -q '^custom_policy=keep-me$' "$bootstrap_project/.tic-rules.lock" &&
   cp "$bootstrap_project/AGENTS.md" "$bootstrap_tmp/AGENTS.first" &&
   printf '\nSENTINEL_TEAM_MEMORY\n' >> "$bootstrap_project/ai-harness/memory/team-collaboration.md" &&
   team_memory_before="$(cksum "$bootstrap_project/ai-harness/memory/team-collaboration.md")" &&
   printf '\n' >> "$bootstrap_project/AGENTS.md" &&
   bash tools/bootstrap-project.sh --yes --force "$bootstrap_project" >/dev/null &&
   cmp -s "$bootstrap_tmp/AGENTS.first" "$bootstrap_project/AGENTS.md" &&
   [ "$team_memory_before" = "$(cksum "$bootstrap_project/ai-harness/memory/team-collaboration.md")" ] &&
   grep -q 'SENTINEL_TEAM_MEMORY' "$bootstrap_project/ai-harness/memory/team-collaboration.md" &&
   bash tools/bootstrap-project.sh --yes --force "$bootstrap_project" >/dev/null &&
   cmp -s "$bootstrap_tmp/AGENTS.first" "$bootstrap_project/AGENTS.md" &&
   [ "$team_memory_before" = "$(cksum "$bootstrap_project/ai-harness/memory/team-collaboration.md")" ]; then
  pass "bootstrap is idempotent and preserves lock, adapter, and shared memory"
else
  fail "bootstrap must be commit-safe, idempotent, and preserve lock and shared memory"
fi
rm -rf "$bootstrap_tmp"

adapter_tmp="$(mktemp -d)"
adapter_project="$adapter_tmp/workspace"
mkdir -p "$adapter_project/ai-harness" "$adapter_project/live-api" "$adapter_project/live-web"
cat > "$adapter_project/.gitmodules" <<'EOF'
[submodule "live-api"]
	path = live-api
	url = ../live-api.git
[submodule "live-web"]
	path = live-web
	url = ../live-web.git
EOF
cat > "$adapter_project/ai-harness/project-adapter.md" <<'EOF'
# Custom Project Adapter

SENTINEL_PROJECT_FACT
EOF
adapter_before="$(cksum "$adapter_project/ai-harness/project-adapter.md")"
preserve_plan="$adapter_tmp/preserve-plan.txt"
if bash tools/bootstrap-project.sh --yes --force "$adapter_project" > "$preserve_plan" &&
   [ "$adapter_before" = "$(cksum "$adapter_project/ai-harness/project-adapter.md")" ] &&
   grep -q 'preserve existing ai-harness/project-adapter.md' "$preserve_plan"; then
  pass "refresh preserves the existing project adapter byte-for-byte"
else
  fail "refresh and force must preserve the existing project adapter"
fi

if bash tools/bootstrap-project.sh --yes --force --regenerate-adapter "$adapter_project" >/dev/null &&
   ! grep -q 'SENTINEL_PROJECT_FACT' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -R -q 'SENTINEL_PROJECT_FACT' "$adapter_project/.tic-backups" --include='project-adapter.md' &&
   grep -q 'owner_type: workspace' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -q '^verification:$' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -q 'policy: risk-based' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -q '    - "live-api"' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -q '    - "live-web"' "$adapter_project/ai-harness/project-adapter.md"; then
  pass "explicit adapter regeneration backs up content and detects submodule workspace ownership"
else
  fail "explicit adapter regeneration must back up content and detect submodule workspaces"
fi
rm -rf "$adapter_tmp"

update_tmp="$(mktemp -d)"
mkdir -p "$update_tmp/tools"
cp tools/update.sh "$update_tmp/tools/update.sh"
cp VERSION "$update_tmp/VERSION"
cat > "$update_tmp/tools/validate-pack.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$update_tmp/tools/install-codex-global.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "${TIC_TEST_GLOBAL_ARGS:?}"
EOF
update_default_args="$update_tmp/default-global-args.txt"
update_default_expected="$update_tmp/default-global-args.expected"
update_explicit_args="$update_tmp/explicit-global-args.txt"
update_explicit_expected="$update_tmp/explicit-global-args.expected"
printf '%s\n' --yes --rules-dir "$update_tmp" > "$update_default_expected"
printf '%s\n' --yes --rules-dir "$update_tmp" --codex-home "$update_tmp/codex" > "$update_explicit_expected"
if bash "$update_tmp/tools/update.sh" --preview --no-pull --no-project >/dev/null &&
   TIC_TEST_GLOBAL_ARGS="$update_default_args" \
     bash "$update_tmp/tools/update.sh" --no-pull --no-project >/dev/null &&
   cmp -s "$update_default_expected" "$update_default_args" &&
   TIC_TEST_GLOBAL_ARGS="$update_explicit_args" \
     bash "$update_tmp/tools/update.sh" --no-pull --no-project \
       --codex-home "$update_tmp/codex" >/dev/null &&
   cmp -s "$update_explicit_expected" "$update_explicit_args"; then
  pass "Shell update refreshes the default global loader on Bash 3.2 and forwards explicit Codex home"
else
  fail "Shell update must support empty and explicit Codex home paths on Bash 3.2"
fi
rm -rf "$update_tmp"

if grep -q 'REGENERATE_ADAPTER' tools/bootstrap-project.sh &&
   grep -q -- '--regenerate-adapter' tools/install.sh &&
   grep -q 'RegenerateAdapter' tools/bootstrap-project.ps1 &&
   grep -q -- '-RegenerateAdapter' tools/install.ps1 &&
   grep -q 'project_adapter_lifecycle' manifest.json &&
   grep -q '普通安装与升级不会覆盖' templates/docs/ai-rules-usage.md; then
  pass "Shell, PowerShell, manifest, and project docs declare preservation-first adapter lifecycle"
else
  fail "adapter preservation lifecycle must be consistent across Shell, PowerShell, manifest, and docs"
fi

if grep -q '"git_write_policy".*no_write_without_explicit_authorization' manifest.json &&
   grep -q 'git fetch, switch, add, commit, push, merge, tag' tools/git-advice.ps1 &&
   grep -q 'git fetch, switch, add, commit, push, merge, tag' tools/git-advice.sh; then
  pass "Git advice scripts are read-only by policy"
else
  fail "Git advice scripts or manifest do not record read-only policy"
fi

if grep -q 'feature/<business-slug>' Skills/git-flow-operator.md &&
   grep -q '使用 SemVer' Skills/git-flow-operator.md &&
   grep -q 'preserve-existing' Skills/git-flow-operator.md &&
   grep -q '该授权已经充分' Skills/git-flow-operator.md &&
   grep -q 'version_format: semver' templates/ai-harness/project-adapter.md &&
   grep -q 'branch_strategy: project-defined' tools/bootstrap-project.sh &&
   grep -q 'feature_branch_policy' tools/git-advice.sh &&
   grep -q 'release_hotfix_version_policy' tools/git-advice.ps1 &&
   grep -q 'suggested_tag' tools/git-advice.sh; then
  pass "Git strategy resolves project policy and reuses explicit authorization"
else
  fail "Git strategy must use project policy, safe defaults, and non-redundant authorization"
fi

if grep -q 'git fetch <authoritative-remote> --prune --tags' Skills/git-flow-operator.md &&
   grep -q 'git_branch_creation_remote_freshness_gate' manifest.json &&
   grep -q 'git_advice_reports_remote_freshness_gap' manifest.json &&
   grep -q 'refs/heads/<branch>' Skills/git-flow-operator.md &&
   grep -q 'refs/remotes/<remote>/<branch>' Skills/git-flow-operator.md &&
   grep -q '基线新鲜度' Skills/git-flow-operator.md &&
   grep -q 'git fetch <authoritative-remote> --prune --tags' Global-Rules/coding-rules.md &&
   grep -q '检查基线、同名分支' templates/AGENTS.md &&
   grep -q '不默认执行分支、提交、推送、合并、tag、发布' templates/codex-global/AGENTS.md &&
   grep -q 'remote_fetch_status' tools/git-advice.sh &&
   grep -q 'remote_fetch_status' tools/git-advice.ps1 &&
   grep -q 'base_branch_sync_status' tools/git-advice.sh &&
   grep -q 'base_branch_sync_status' tools/git-advice.ps1 &&
   grep -q 'base_policy_source' tools/git-advice.sh &&
   grep -q 'base_policy_source' tools/git-advice.ps1 &&
   grep -q 'git_advice_resolves_project_declared_branch_bases' manifest.json &&
   grep -q 'suggested_branch_exists_remote' tools/git-advice.sh &&
   grep -q 'suggested_branch_exists_remote' tools/git-advice.ps1 &&
   grep -q 'suggested_branch_diverged' tools/git-advice.sh &&
   grep -q 'suggested_branch_diverged' tools/git-advice.ps1 &&
   grep -q 'not_run_by_git_advice' tools/git-advice.sh &&
   grep -q 'not_run_by_git_advice' tools/git-advice.ps1; then
  pass "Git Flow branch creation checks remote freshness, base sync, and local/remote branch occupancy"
else
  fail "Git Flow branch creation must fetch, check base freshness, and inspect local/remote same-name branches"
fi

if grep -q '项目要求 release/hotfix tag 后回灌' Skills/git-flow-operator.md &&
   grep -q '项目集成分支回灌状态' Skills/git-flow-operator.md &&
   grep -q '项目要求的发布证据' Skills/git-flow-operator.md &&
   grep -q '回灌未完成' Skills/git-flow-operator.md &&
   grep -q 'release/hotfix tag 后继续记录' Global-Rules/coding-rules.md &&
   grep -q 'project-required back-merge or closeout evidence' templates/codex-global/skills/tic-git-flow-operator/SKILL.md &&
   grep -q '没有回灌政策的项目不发明该步骤' Skills/git-flow-operator.md; then
  pass "Git tag closeout requires project-defined back-merge or closeout evidence"
else
  fail "Git tag closeout must keep project-defined back-merge or closeout as a completion gate"
fi

if grep -q 'Get-ReleaseRegistryRoots' tools/git-advice.ps1 &&
   grep -q 'release_registry_root' tools/git-advice.ps1 &&
   grep -q 'release_registry_roots' tools/git-advice.sh; then
  pass "Git advice scans default and project-declared release registry roots"
else
  fail "Git advice must scan default and project-declared release registry roots"
fi

if grep -q 'release_owner_type' Skills/release-handoff.md &&
   grep -q 'release_registry_root' Skills/release-handoff.md &&
   grep -q 'release_tag' Skills/release-handoff.md &&
   grep -q 'tag_target_commit' Skills/release-handoff.md &&
   grep -q 'SDD / TDD / PRD' Skills/release-handoff.md &&
   grep -q '已 push 的发布 tag 默认不可移动' Skills/release-handoff.md; then
  pass "Release handoff records owner, tag evidence, registry root, and landing status"
else
  fail "Release handoff must record owner, tag evidence, registry root, and landing status"
fi

if grep -q 'artifact_ownership' templates/ai-harness/project-adapter.md &&
   grep -q 'tdd_evidence_root' templates/ai-harness/project-adapter.md &&
   grep -q 'prd_draft_root' Skills/post-dev-prd-sync.md &&
   grep -q '创建额外 artifact 前必须能回答' Workflow/core.md &&
   grep -q 'artifact_policy' manifest.json; then
  pass "artifact roots are preserved and additional artifacts are consumer-driven"
else
  fail "artifact roots and consumer-driven creation policy must both be declared"
fi

if grep -q 'workflow_core' manifest.json &&
   grep -q 'native_outcome_driven_five_dimensions' manifest.json &&
   grep -q '普通任务直接调查、修改和验证' templates/AGENTS.md &&
   grep -q '总控型外部 Skill 不得成为项目默认入口' Workflow/core.md; then
  pass "native outcome-driven workflow core is declared"
else
  fail "missing native outcome-driven five-dimension workflow declaration"
fi

if grep -q '规划、授权、验证、Review 和持久化分别判断' templates/docs/ai-rules-usage.md &&
   grep -q 'openspec_integration' manifest.json &&
   grep -q 'verification_policy' manifest.json &&
   grep -q '验证不是收尾阶段' Workflow/core.md &&
   grep -q 'Review 不是固定关卡' Workflow/core.md &&
   grep -q '普通任务不因 OpenSpec 存在而强制创建 change' Global-Rules/coding-rules.md; then
  pass "planning, authority, verification, review, and specification persistence are independent"
else
  fail "workflow dimensions and specification persistence must remain independently triggered"
fi

if grep -q 'project_tool_rule_entries' manifest.json &&
   grep -q 'templates/tool-rules/cursorrules.md' manifest.json &&
   grep -q 'templates/tool-rules/windsurfrules.md' manifest.json &&
   grep -q 'templates/tool-rules/rules/team-intelligence-center.md' manifest.json &&
   grep -q '\.cursorrules' tools/bootstrap-project.sh &&
   grep -q '\.windsurfrules' tools/bootstrap-project.sh &&
   grep -q '\.rules/team-intelligence-center.md' tools/bootstrap-project.sh &&
   grep -q '\.cursorrules' tools/bootstrap-project.ps1 &&
   grep -q '\.windsurfrules' tools/bootstrap-project.ps1 &&
   grep -q 'team-intelligence-center.md' tools/bootstrap-project.ps1 &&
   grep -q '先读取项目根目录 `AGENTS.md`' templates/tool-rules/cursorrules.md &&
   grep -q '先读取项目根目录 `AGENTS.md`' templates/tool-rules/windsurfrules.md &&
   grep -q '先读取项目根目录 `AGENTS.md`' templates/tool-rules/rules/team-intelligence-center.md; then
  pass "project-level tool rule entries point back to AGENTS.md"
else
  fail "project-level tool rule entries must be installed and point back to AGENTS.md"
fi

if grep -q 'post_dev_prd_sync' manifest.json &&
   grep -q '开发后 PRD 同步' Skills/post-dev-prd-sync.md &&
   grep -q '本能力不因任务完成自动触发' Skills/post-dev-prd-sync.md &&
   grep -q 'post-dev-prd-sync' templates/AGENTS.md; then
  pass "post-development PRD sync is declared"
else
  fail "missing post-development PRD sync policy"
fi

if grep -q 'delivery_walkthrough' manifest.json &&
   grep -q '交付走查' Skills/delivery-walkthrough.md &&
   grep -q '明确消费者需要异步' Skills/delivery-walkthrough.md &&
   grep -q 'delivery-walkthrough' templates/AGENTS.md &&
   grep -q 'delivery-walkthrough' templates/codex-global/skills/tic-delivery-walkthrough/SKILL.md; then
  pass "delivery walkthrough is declared"
else
  fail "missing delivery walkthrough policy"
fi

if grep -q 'auto_project_profile' manifest.json &&
   grep -q 'project_adapter_lifecycle' manifest.json &&
   grep -q 'package.json' tools/bootstrap-project.sh &&
   grep -q 'package.json' tools/bootstrap-project.ps1 &&
   grep -q '.gitmodules' tools/bootstrap-project.sh &&
   grep -q '.gitmodules' tools/bootstrap-project.ps1 &&
   grep -q 'project-adapter-maintainer' Skills/tic-workflow-orchestrator.md; then
  pass "bootstrap scaffolds project adapter profiles and routes later maintenance safely"
else
  fail "bootstrap must scaffold adapter profiles, detect workspaces, and route later maintenance safely"
fi

if grep -q 'skills_reference_only_by_default' manifest.json &&
   grep -q 'skill_contract_schema' manifest.json &&
   grep -q 'skill_lifecycle' manifest.json &&
   grep -q 'Skills 默认从解析出的规则源读取' templates/docs/ai-rules-usage.md &&
   grep -q '不自动差量复制到项目本地 skills' templates/docs/ai-rules-usage.md; then
  pass "skills distribution is reference-only by default"
else
  fail "skills distribution policy must avoid automatic local/global copying and declare lifecycle contracts"
fi

if grep -q '"api-contract-freezer"[[:space:]]*:[[:space:]]*"contract-handoff"' manifest.json &&
   grep -q '"fe-be-handoff"[[:space:]]*:[[:space:]]*"contract-handoff"' manifest.json &&
   grep -q '"conflict-arbiter"[[:space:]]*:[[:space:]]*"shared-domain-arbiter"' manifest.json &&
   grep -q '"release-ops-handoff"[[:space:]]*:[[:space:]]*"release-handoff"' manifest.json &&
   grep -q '"release-train-handoff"[[:space:]]*:[[:space:]]*"release-handoff"' manifest.json &&
   grep -q 'candidate-rule-extractor' manifest.json &&
   grep -q '"checklists"' manifest.json &&
   grep -q 'prd-review-checklist' manifest.json &&
   grep -q '"rule_templates"' manifest.json &&
   grep -q 'session-snapshot-manager' manifest.json &&
   grep -q '"compatibility_removal_target"[[:space:]]*:[[:space:]]*"0.6.0"' manifest.json; then
  pass "skill lifecycle aliases, subflows, checklists, and rule templates are declared"
else
  fail "missing skill lifecycle classification or compatibility removal target"
fi

if grep -q 'one_command_user_update' manifest.json &&
   grep -q 'stable_update_policy' manifest.json &&
   grep -q 'UPDATE_CHANNEL="stable"' tools/update.sh &&
   grep -q 'latest_semver_tag' tools/update.sh &&
   grep -q 'TargetRef' tools/update.ps1 &&
   grep -q -- '--channel current' USAGE.md &&
   grep -q -- '--ref 0.5.2' USAGE.md &&
   grep -q -- '--ref 0.5.2' docs/automation.md &&
   grep -q 'install-codex-global.sh' tools/update.sh &&
   grep -q 'install.sh' tools/update.sh; then
  pass "stable, current, and explicit-ref update paths are declared"
else
  fail "update path must support stable, current, and explicit-ref sources before refreshing wrappers and projects"
fi

codex_wrapper_count="$(find templates/codex-global/skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d '[:space:]')"
if [ "$codex_wrapper_count" -ge 15 ] && grep -q 'codex_global_loader' manifest.json && grep -q '优先遵守当前项目' templates/codex-global/AGENTS.md && grep -q 'rules_path=' templates/codex-global/AGENTS.md && grep -q '.tic-rules.local' templates/codex-global/AGENTS.md && grep -q 'Do not copy TIC Skills' templates/codex-global/skills/tic-post-dev-prd-sync/SKILL.md && grep -q 'tic-delivery-walkthrough' templates/codex-global/skills/tic-delivery-walkthrough/SKILL.md && grep -q 'tic-git-flow-operator' templates/codex-global/skills/tic-git-flow-operator/SKILL.md && grep -q 'tic-workflow-orchestrator' templates/codex-global/skills/tic-workflow-orchestrator/SKILL.md && grep -q 'tic-contract-handoff' templates/codex-global/skills/tic-contract-handoff/SKILL.md && grep -q 'tic-release-handoff' templates/codex-global/skills/tic-release-handoff/SKILL.md && grep -q 'tic-shared-domain-arbiter' templates/codex-global/skills/tic-shared-domain-arbiter/SKILL.md && grep -q 'project-adapter-maintainer' templates/codex-global/skills/tic-project-adapter-maintainer/SKILL.md && grep -q '<rules_dir>/Skills/e2e-verification.md' templates/codex-global/skills/tic-e2e-verification/SKILL.md && grep -q '<rules_dir>/Skills/collaboration-memory-maintainer.md' templates/codex-global/skills/tic-collaboration-memory-maintainer/SKILL.md && grep -q 'TIC_CODEX_GLOBAL_BEGIN' tools/install-codex-global.sh; then
  pass "Codex global loader is wrapper-only and project-first"
else
  fail "Codex global loader must stay wrapper-only and project-first"
fi

codex_install_tmp="$(mktemp -d)"
if bash tools/install-codex-global.sh --yes --rules-dir "$PACKAGE_ROOT" \
     --codex-home "$codex_install_tmp" >/dev/null &&
   grep -q '规则版本：`0.5.2`' "$codex_install_tmp/AGENTS.md" &&
   grep -q 'TIC_CODEX_GLOBAL_BEGIN' "$codex_install_tmp/AGENTS.md" &&
   grep -q '<rules_dir>/Skills/collaboration-memory-maintainer.md' \
     "$codex_install_tmp/skills/tic-collaboration-memory-maintainer/SKILL.md" &&
   ! grep -q '{{TIC_RULES_DIR}}' \
     "$codex_install_tmp/skills/tic-collaboration-memory-maintainer/SKILL.md"; then
  pass "Codex global install renders the collaboration memory wrapper"
else
  fail "Codex global install must render the current loader and collaboration memory wrapper"
fi
rm -rf "$codex_install_tmp"

if grep -q 'e2e_verification' manifest.json &&
   grep -q 'e2e-verification' manifest.json &&
   grep -q 'e2e-verification' templates/AGENTS.md &&
   grep -q '局部测试不足以证明关键旅程' Global-Rules/coding-rules.md &&
   grep -q '^verification:$' templates/ai-harness/project-adapter.md &&
   grep -q '^  e2e:$' templates/ai-harness/project-adapter.md &&
   grep -q 'auth_state_path:' templates/ai-harness/project-adapter.md &&
   grep -q 'auth_state_policy: local-only' templates/ai-harness/project-adapter.md &&
   grep -q 'cleanup_command:' tools/bootstrap-project.sh &&
   grep -q 'cleanup_command:' tools/bootstrap-project.ps1 &&
   grep -q '项目原生优先' Skills/e2e-verification.md &&
   grep -q 'partial.*blocked.*waived' Skills/e2e-verification.md &&
   grep -q 'E2E gate' Skills/release-handoff.md &&
   grep -q 'UI 改动在环境可运行时核对真实界面' templates/AGENTS.md; then
  pass "risk-based E2E verification gate is tool-neutral, adapter-driven, and evidence-aware"
else
  fail "E2E verification policy, routing, adapter schema, wrapper, or safety evidence contract is incomplete"
fi

if grep -q 'Memory 不默认参与每个任务' templates/AGENTS.md &&
   grep -q 'mode=extract' Skills/collaboration-memory-maintainer.md &&
   grep -q '提取 0～5 条候选' Skills/collaboration-memory-maintainer.md &&
   ! grep -q '3～5 条候选' Skills/collaboration-memory-maintainer.md &&
   grep -q 'mode=reconcile' Skills/collaboration-memory-maintainer.md &&
   grep -q 'review_after' Skills/collaboration-memory-maintainer.md &&
   grep -q '原始聊天' Skills/collaboration-memory-maintainer.md &&
   grep -q '明确授权' Skills/collaboration-memory-maintainer.md &&
   grep -q 'memory_root:' templates/ai-harness/project-adapter.md &&
   grep -q '.tic/local/' tools/bootstrap-project.sh &&
   grep -q '.tic/local/' tools/bootstrap-project.ps1; then
  pass "collaboration memory lifecycle is explicit, scoped, expiring, and preserved"
else
  fail "collaboration memory skill, privacy boundary, lifecycle, adapter root, or explicit activation is incomplete"
fi

if grep -q 'codegraph_optional' manifest.json &&
   grep -q 'does not install CodeGraph' tools/codegraph-helper.sh &&
   grep -q '不会通过 npx 自动下载或安装 CodeGraph' tools/codegraph-helper.sh &&
   grep -q '不会通过 npx 自动下载或安装 CodeGraph' tools/codegraph-helper.ps1 &&
   grep -q '不替代 SDD + TDD' tools/codegraph-helper.sh &&
   grep -q '不替代 SDD + TDD' tools/codegraph-helper.ps1 &&
   ! grep -q 'npx codegraph' tools/codegraph-helper.sh tools/codegraph-helper.ps1 docs/automation.md; then
  pass "CodeGraph helper is optional and non-core"
else
  fail "CodeGraph helper must remain optional, non-core, and avoid implicit npx installation"
fi

if grep -q 'ui_visual_verification' manifest.json &&
   grep -q 'ui_design_skill_routing' manifest.json &&
   grep -q 'UI 改动在环境可运行时核对真实界面' templates/AGENTS.md &&
   grep -q 'UI 改动在本地应用可运行时核对真实界面' Global-Rules/coding-rules.md; then
  pass "UI changes require real interface verification when risk warrants"
else
  fail "missing capability-based UI design routing or real interface verification policy"
fi

if grep -q '轻量规则' templates/AGENTS.md && grep -q 'AI 规则使用说明' templates/docs/ai-rules-usage.md && grep -q '项目适配说明' templates/ai-harness/project-adapter.md && grep -q '轻量自动化设计' docs/automation.md; then
  pass "generated Markdown templates are Chinese-first"
else
  fail "generated Markdown templates must be Chinese-first"
fi

if grep -q 'no_git_hooks_by_default' manifest.json &&
   grep -q 'task_context_has_no_mandatory_artifacts' manifest.json &&
   grep -q 'external_method_skills' manifest.json &&
   grep -q 'umbrella_workflow_skills_are_not_default_entrypoints' manifest.json; then
  pass "manifest records lightweight exclusions"
else
  fail "manifest does not record lightweight exclusions"
fi

if grep -Fxq '.omx/' .gitignore &&
   grep -Fxq '.superpowers/' .gitignore &&
   grep -Fxq '.tic/agent-runs/' .gitignore &&
   grep -Fxq '.tic/local/' .gitignore; then
  pass "agent runtime and personal collaboration memory are gitignored"
else
  fail ".omx, .superpowers, .tic/agent-runs, and .tic/local must remain local-only"
fi

canonical_skill_files=(
  Skills/task-decomposer.md
  Skills/code-investigator.md
  Skills/contract-handoff.md
  Skills/shared-domain-arbiter.md
  Skills/agent-session-protocol.md
  Skills/e2e-verification.md
  Skills/delivery-walkthrough.md
  Skills/release-handoff.md
  Skills/post-dev-prd-sync.md
  Skills/changelog-writer.md
  Skills/git-flow-operator.md
  Skills/project-governance-bootstrap.md
  Skills/project-adapter-maintainer.md
  Skills/collaboration-memory-maintainer.md
)

legacy_skill_scan="$(mktemp)"
grep -nE 'effective_tier|Effective tier|CP-[0-9]|CI → PM|PM → CI|PM 拆解|QA → DS|DS → main-prd|推荐链路|总控 Agent' \
  "${canonical_skill_files[@]}" > "$legacy_skill_scan" || true
if [ -s "$legacy_skill_scan" ]; then
  fail "canonical skills retain legacy tier, phase, or role-pipeline language: $(head -8 "$legacy_skill_scan" | tr '\n' '; ')"
else
  pass "canonical skills are capability methods rather than a role or phase pipeline"
fi
rm -f "$legacy_skill_scan"

oversized_skill_scan="$(mktemp)"
for skill_file in "${canonical_skill_files[@]}"; do
  skill_lines="$(wc -l < "$skill_file" | tr -d '[:space:]')"
  if [ "$skill_lines" -gt 180 ]; then
    printf '%s:%s\n' "$skill_file" "$skill_lines" >> "$oversized_skill_scan"
  fi
done
if [ -s "$oversized_skill_scan" ]; then
  fail "canonical skills exceed the 180-line progressive-disclosure budget: $(tr '\n' '; ' < "$oversized_skill_scan")"
else
  pass "canonical skills keep their primary instructions within the progressive-disclosure budget"
fi
rm -f "$oversized_skill_scan"

wrapper_description_scan="$(mktemp)"
grep -nE '^description: (Compatibility wrapper|Use before|Use after)|before non-trivial changes|needs to modify shared domains|requires .*user confirmation' \
  templates/codex-global/skills/*/SKILL.md > "$wrapper_description_scan" || true
if [ -s "$wrapper_description_scan" ]; then
  fail "Codex wrapper descriptions over-trigger or encode workflow order: $(head -8 "$wrapper_description_scan" | tr '\n' '; ')"
else
  pass "Codex wrapper descriptions mirror activation facts without workflow ordering"
fi
rm -f "$wrapper_description_scan"

wrapper_description_count="$(grep -h '^description: Use when ' templates/codex-global/skills/*/SKILL.md | wc -l | tr -d '[:space:]')"
if [ "$wrapper_description_count" -eq "$codex_wrapper_count" ] &&
   ! grep -R -nE 'continue with an evidence-based PRD update draft: collect|git fetch --all --prune --tags' \
     templates/codex-global/skills Skills Global-Rules/coding-rules.md README.md USAGE.md >/dev/null 2>&1; then
  pass "every global wrapper exposes a fact-shaped trigger and avoids legacy artifact or fetch-all fallbacks"
else
  fail "all global wrapper descriptions must start with a fact-shaped trigger and avoid legacy fallbacks"
fi

if scenario_matches explicit-git-release \
     '"capabilities": \["git-flow-operator", "release-handoff"\]' \
     '"additional_confirmation": false' &&
   scenario_matches shared-file-single-owner \
     '"capabilities": \[\]' &&
   scenario_matches implementation-summary-enough \
     '"capabilities": \[\]' &&
   scenario_matches product-fact-without-prd-consumer \
     '"capabilities": \[\]' &&
   scenario_matches focused-code-investigation \
     '"capabilities": \["code-investigator"\]'; then
  pass "capability scenarios cover positive triggers and keyword-shaped non-triggers"
else
  fail "capability scenarios must prove exact triggers, non-triggers, and non-redundant Git authorization"
fi

if [ "$failures" -eq 0 ]; then
  printf '\nValidation passed.\n'
  if [ "$warnings" -gt 0 ]; then
    printf 'Validation warnings: %s.\n' "$warnings"
  fi
else
  printf '\nValidation failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi
