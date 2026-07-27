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
require_file docs/releases/0.1.0/README.md
require_file docs/releases/0.2.0/README.md
require_file docs/releases/0.2.1/README.md
require_file docs/releases/0.2.1/evidence.md
require_file docs/test-evidence/tic-0.2.0/README.md
require_file docs/test-evidence/tic-0.2.1/README.md
require_file docs/walkthroughs/tic-0.2.1-project-adapter-preservation.md
require_file Skills/project-adapter-maintainer.md
require_file templates/codex-global/skills/tic-project-adapter-maintainer/SKILL.md
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

if grep -q '当前版本为 `0.2.1`' README.md &&
   grep -q '0.1.0.*0.2.0.*已归档' README.md &&
   grep -q 'd8fe814ad633bd06d6ead7815ad8f7d6d3db5324' docs/releases/0.1.0/README.md; then
  pass "current and archived release records are declared"
else
  fail "README and release archive must identify 0.2.1 and archived 0.1.0/0.2.0 releases"
fi

skill_count="$(find Skills -maxdepth 1 -type f -name '*.md' | wc -l | tr -d '[:space:]')"
if [ "$skill_count" -ge 20 ]; then
  pass "skill count >= 20 ($skill_count)"
else
  fail "expected at least 20 skill files, found $skill_count"
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

  if sed -n '1,40p' "$skill_file" | grep -q '^schema: tic_skill.v1$' &&
     sed -n '1,40p' "$skill_file" | grep -q '^id: ' &&
     sed -n '1,40p' "$skill_file" | grep -q '^status: ' &&
     sed -n '1,40p' "$skill_file" | grep -q '^phase: ' &&
     sed -n '1,40p' "$skill_file" | grep -q '^risk_min: '; then
    pass "skill contract: $skill_file"
  else
    fail "skill missing tic_skill.v1 contract fields: $skill_file"
  fi
done < <(find Skills -maxdepth 1 -type f -name '*.md' | sort)

orchestrator_lines="$(wc -l < Skills/tic-workflow-orchestrator.md | tr -d '[:space:]')"
orchestrator_max_lines=280
if [ "$orchestrator_lines" -le "$orchestrator_max_lines" ] &&
   grep -q '只做路由' Skills/tic-workflow-orchestrator.md &&
   grep -q 'risk_floor' Skills/tic-workflow-orchestrator.md &&
   grep -q 'Capability First, Governance on Risk' Skills/tic-workflow-orchestrator.md &&
   ! grep -q '任务拆解自检清单' Skills/tic-workflow-orchestrator.md; then
  pass "workflow orchestrator is clarity-bounded router ($orchestrator_lines/$orchestrator_max_lines lines)"
else
  fail "workflow orchestrator must stay clarity-bounded, route-only, and risk_floor aware"
fi

if grep -q 'CP-1 范围决策' Global-Rules/coding-rules.md &&
   grep -q 'CP-4 高危动作' Global-Rules/coding-rules.md &&
   grep -q 'CP-5 发布动作' Global-Rules/coding-rules.md &&
   grep -q 'checkpoint_policy' manifest.json &&
   grep -q '检查点不再按阶段机械暂停' README.md; then
  pass "checkpoints are action-triggered rather than stage-triggered"
else
  fail "checkpoint policy must pause on material decisions and high-risk actions, not every phase"
fi

if grep -q 'Intake → Planning → Discovery(按需)' Global-Rules/coding-rules.md &&
   grep -q 'Intake -> Planning -> Discovery(按需)' Skills/tic-workflow-orchestrator.md &&
   grep -q 'Intake -> Planning -> Discovery(按需)' USAGE.md &&
   ! grep -q 'Intake → Discovery → Planning' Global-Rules/coding-rules.md; then
  pass "standard workflow phase order matches orchestrator"
else
  fail "standard workflow phase order must match tic-workflow-orchestrator"
fi

if grep -q '切换 Codex 任务或工具、跨人接力、长时异步执行' Global-Rules/coding-rules.md &&
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
   grep -q 'Agent Session Protocol' "$bootstrap_project/ai-harness/agent-session-protocol.md" &&
   grep -q '主线边界' "$bootstrap_project/.cursorrules" &&
   grep -q '主线边界' "$bootstrap_project/.windsurfrules" &&
   grep -q '主线边界' "$bootstrap_project/.rules/team-intelligence-center.md" &&
   grep -q '^risk_floor=critical$' "$bootstrap_project/.tic-rules.lock" &&
   grep -q '^custom_policy=keep-me$' "$bootstrap_project/.tic-rules.lock"; then
  pass "bootstrap output is commit-safe and preserves lock custom fields"
else
  fail "bootstrap must not write absolute project paths and must preserve lock custom fields"
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
   grep -q '    - "live-api"' "$adapter_project/ai-harness/project-adapter.md" &&
   grep -q '    - "live-web"' "$adapter_project/ai-harness/project-adapter.md"; then
  pass "explicit adapter regeneration backs up content and detects submodule workspace ownership"
else
  fail "explicit adapter regeneration must back up content and detect submodule workspaces"
fi
rm -rf "$adapter_tmp"

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

if grep -q 'git_workflow_advice_only' manifest.json &&
   grep -q 'git fetch, switch, add, commit, push, merge, tag' tools/git-advice.ps1 &&
   grep -q 'git fetch, switch, add, commit, push, merge, tag' tools/git-advice.sh; then
  pass "Git advice scripts are read-only by policy"
else
  fail "Git advice scripts or manifest do not record read-only policy"
fi

if grep -q 'feature/<business-slug>' Skills/git-flow-operator.md &&
   grep -q '默认.*SemVer' Skills/git-flow-operator.md &&
   grep -q 'preserve-existing' Skills/git-flow-operator.md &&
   grep -q '等待用户确认' Skills/git-flow-operator.md &&
   grep -q 'version_format: semver' templates/ai-harness/project-adapter.md &&
   grep -q 'branch_strategy: project-defined' tools/bootstrap-project.sh &&
   grep -q 'feature_branch_policy' tools/git-advice.sh &&
   grep -q 'release_hotfix_version_policy' tools/git-advice.ps1 &&
   grep -q 'suggested_tag' tools/git-advice.sh; then
  pass "Git strategy resolves project policy with SemVer defaults"
else
  fail "Git strategy must use project branch/version/tag policy with SemVer defaults and confirmation gates"
fi

if grep -q 'git fetch --all --prune --tags' Skills/git-flow-operator.md &&
   grep -q 'git_branch_creation_remote_freshness_gate' manifest.json &&
   grep -q 'git_advice_reports_remote_freshness_gap' manifest.json &&
   grep -q 'refs/heads/<branch>' Skills/git-flow-operator.md &&
   grep -q 'refs/remotes/\*/<branch>' Skills/git-flow-operator.md &&
   grep -q '基线新鲜度' Skills/git-flow-operator.md &&
   grep -q 'git fetch --all --prune --tags' Global-Rules/coding-rules.md &&
   grep -q '本地/远端同名分支' templates/AGENTS.md &&
   grep -q '基线同步状态' templates/codex-global/AGENTS.md &&
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

if grep -q 'Tag 后回灌门禁' Skills/git-flow-operator.md &&
   grep -q '项目集成分支回灌状态' Skills/git-flow-operator.md &&
   grep -q '发版目录证据' Skills/git-flow-operator.md &&
   grep -q '回灌未完成' Skills/git-flow-operator.md &&
   grep -q '回灌或收尾状态' templates/AGENTS.md &&
   grep -q '回灌或收尾状态' templates/codex-global/AGENTS.md &&
   grep -q 'project-required back-merge or closeout evidence' templates/codex-global/skills/tic-git-flow-operator/SKILL.md &&
   grep -q 'release/hotfix 创建 tag 后不得把 Git Flow 任务标记为完成' Global-Rules/coding-rules.md; then
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
   grep -q 'Artifact / release roots' Skills/tic-workflow-orchestrator.md &&
   grep -q 'project_adapter_declares_owner_and_roots' manifest.json; then
  pass "SDD/TDD/PRD artifact ownership and landing roots are declared"
else
  fail "SDD/TDD/PRD artifact ownership and landing roots must be declared"
fi

if grep -q 'adaptive workflow' templates/AGENTS.md && grep -q 'workflow_orchestrator' manifest.json && grep -q 'single_adaptive_with_risk_floor' manifest.json && grep -q 'risk_floor' manifest.json && grep -q 'tic-workflow-orchestrator.md' README.md && grep -q 'tic-workflow-orchestrator.md' USAGE.md; then
  pass "adaptive workflow orchestrator and risk_floor are declared"
else
  fail "missing adaptive workflow orchestrator or risk_floor declaration"
fi

if grep -q '规格驱动与验收驱动流程' templates/AGENTS.md &&
   grep -q 'openspec_integration' manifest.json &&
   grep -q 'specification_and_verification_required_for_standard_and_critical' manifest.json &&
   grep -q 'sdd_tdd_as_workflow_semantics' manifest.json &&
   grep -q 'OpenSpec 是规格事实源；Superpowers 是执行方法层' templates/AGENTS.md &&
   grep -q 'OpenSpec 是规格事实源，Superpowers 是执行方法层' Skills/tic-workflow-orchestrator.md &&
   grep -q '不是独立 Skill 链' USAGE.md &&
   grep -q '不是独立 Skill 链' docs/automation.md; then
  pass "specification and verification semantics preserve the OpenSpec mainline"
else
  fail "specification and verification must remain workflow semantics with OpenSpec as source"
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

if grep -q 'skills_reference_only_by_default' manifest.json && grep -q 'skill_contract_schema' manifest.json && grep -q 'skill_lifecycle' manifest.json && grep -q 'Skills 默认从解析出的规则源读取' templates/docs/ai-rules-usage.md && grep -q '不自动差量复制到项目本地 skills 或开发者全局 skills' templates/docs/ai-rules-usage.md; then
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
   grep -q 'session-snapshot-manager' manifest.json; then
  pass "skill lifecycle aliases and subflows are declared"
else
  fail "missing skill lifecycle aliases or subflows"
fi

if grep -q 'one_command_user_update' manifest.json &&
   grep -q 'stable_update_policy' manifest.json &&
   grep -q 'UPDATE_CHANNEL="stable"' tools/update.sh &&
   grep -q 'latest_semver_tag' tools/update.sh &&
   grep -q 'TargetRef' tools/update.ps1 &&
   grep -q -- '--channel current' USAGE.md &&
   grep -q -- '--ref 0.2.1' docs/automation.md &&
   grep -q 'install-codex-global.sh' tools/update.sh &&
   grep -q 'install.sh' tools/update.sh; then
  pass "stable, current, and explicit-ref update paths are declared"
else
  fail "update path must support stable, current, and explicit-ref sources before refreshing wrappers and projects"
fi

codex_wrapper_count="$(find templates/codex-global/skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d '[:space:]')"
if [ "$codex_wrapper_count" -ge 13 ] && grep -q 'codex_global_loader' manifest.json && grep -q '优先读取并遵守当前项目' templates/codex-global/AGENTS.md && grep -q 'rules_path=' templates/codex-global/AGENTS.md && grep -q '.tic-rules.local' templates/codex-global/AGENTS.md && grep -q 'Do not copy TIC Skills' templates/codex-global/skills/tic-post-dev-prd-sync/SKILL.md && grep -q 'tic-delivery-walkthrough' templates/codex-global/skills/tic-delivery-walkthrough/SKILL.md && grep -q 'tic-git-flow-operator' templates/codex-global/skills/tic-git-flow-operator/SKILL.md && grep -q 'tic-workflow-orchestrator' templates/codex-global/skills/tic-workflow-orchestrator/SKILL.md && grep -q 'tic-contract-handoff' templates/codex-global/skills/tic-contract-handoff/SKILL.md && grep -q 'tic-release-handoff' templates/codex-global/skills/tic-release-handoff/SKILL.md && grep -q 'tic-shared-domain-arbiter' templates/codex-global/skills/tic-shared-domain-arbiter/SKILL.md && grep -q 'project-adapter-maintainer' templates/codex-global/skills/tic-project-adapter-maintainer/SKILL.md && grep -q 'TIC_CODEX_GLOBAL_BEGIN' tools/install-codex-global.sh; then
  pass "Codex global loader is wrapper-only and project-first"
else
  fail "Codex global loader must stay wrapper-only and project-first"
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
   grep -q 'UI 验证规则' templates/AGENTS.md &&
   grep -q '当前环境可用的设计与 UI/UX 专业能力' templates/AGENTS.md &&
   grep -q 'design-taste-frontend' templates/AGENTS.md &&
   grep -q '同一 Codex 任务内的原生 subagent' templates/AGENTS.md &&
   grep -q 'UI 变更验证' docs/automation.md; then
  pass "UI changes require real interface verification when risk warrants"
else
  fail "missing capability-based UI design routing or real interface verification policy"
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

if grep -q '^.omx/$' .gitignore && grep -q '^.superpowers/$' .gitignore && grep -q '^.tic/agent-runs/$' .gitignore; then
  pass "agent runtime directories are gitignored"
else
  fail ".omx, .superpowers, and .tic/agent-runs runtime directories must remain local-only"
fi

if [ "$failures" -eq 0 ]; then
  printf '\nValidation passed.\n'
else
  printf '\nValidation failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi
