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
  --force          Overwrite existing docs/ai-rules-usage.md and ai-harness/*.md after backing them up.
  --rules-dir PATH Path to Team-Intelligence-Center. Project-local paths are recorded as relative; external paths are written only to .tic-rules.local.
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
RULES_DIR="$(cd "$RULES_DIR" && pwd)"
VERSION="$(tr -d '[:space:]' < "$PACKAGE_ROOT/VERSION" 2>/dev/null || echo unknown)"
PACKAGE_ID="Team_Intelligence_Center_${VERSION}"
BEGIN_MARKER="<!-- TIC_LIGHT_AUTOMATION_BEGIN -->"
END_MARKER="<!-- TIC_LIGHT_AUTOMATION_END -->"

RULES_SOURCE_MODE="local_config"
RULES_PROJECT_PATH=""
if [ "$RULES_DIR" = "$PROJECT_ROOT" ]; then
  RULES_SOURCE_MODE="project_relative"
  RULES_PROJECT_PATH="."
else
  case "$RULES_DIR/" in
    "$PROJECT_ROOT/"*)
      RULES_SOURCE_MODE="project_relative"
      RULES_PROJECT_PATH="${RULES_DIR#$PROJECT_ROOT/}"
      ;;
  esac
fi

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

detect_package_manager() {
  if [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then
    printf 'pnpm'
  elif [ -f "$PROJECT_ROOT/yarn.lock" ]; then
    printf 'yarn'
  elif [ -f "$PROJECT_ROOT/package-lock.json" ]; then
    printf 'npm'
  elif [ -f "$PROJECT_ROOT/bun.lockb" ] || [ -f "$PROJECT_ROOT/bun.lock" ]; then
    printf 'bun'
  elif [ -f "$PROJECT_ROOT/package.json" ]; then
    printf 'npm 或项目约定'
  else
    printf '未检测到 Node 包管理器'
  fi
}

detect_stack_files() {
  local files=(
    "package.json"
    "pnpm-workspace.yaml"
    "turbo.json"
    "vite.config.ts"
    "vite.config.js"
    "next.config.js"
    "nuxt.config.ts"
    "tsconfig.json"
    "pyproject.toml"
    "requirements.txt"
    "go.mod"
    "pom.xml"
    "build.gradle"
    "Cargo.toml"
    "Dockerfile"
    "docker-compose.yml"
  )
  local found=()
  local file
  for file in "${files[@]}"; do
    if [ -e "$PROJECT_ROOT/$file" ]; then
      found+=("\`$file\`")
    fi
  done
  if [ "${#found[@]}" -eq 0 ]; then
    printf '未检测到常见技术栈文件'
  else
    local IFS='、'
    printf '%s' "${found[*]}"
  fi
}

detect_common_dirs() {
  local dirs=(src app apps packages components pages router routes api server backend frontend web admin miniapp tests test docs config scripts)
  local found=()
  local dir
  for dir in "${dirs[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
      found+=("\`$dir/\`")
    fi
  done
  if [ "${#found[@]}" -eq 0 ]; then
    printf '未检测到常见模块目录'
  else
    local IFS='、'
    printf '%s' "${found[*]}"
  fi
}

node_version_summary() {
  local parts=()
  if [ -f "$PROJECT_ROOT/.nvmrc" ]; then
    parts+=(".nvmrc=$(tr -d '[:space:]' < "$PROJECT_ROOT/.nvmrc")")
  fi
  if [ -f "$PROJECT_ROOT/.node-version" ]; then
    parts+=(".node-version=$(tr -d '[:space:]' < "$PROJECT_ROOT/.node-version")")
  fi
  if command -v node >/dev/null 2>&1 && [ -f "$PROJECT_ROOT/package.json" ]; then
    local engines
    engines="$(PROJECT_ROOT="$PROJECT_ROOT" node <<'NODE'
const fs = require('fs');
const path = require('path');
try {
  const pkg = JSON.parse(fs.readFileSync(path.join(process.env.PROJECT_ROOT, 'package.json'), 'utf8'));
  process.stdout.write(pkg.engines && pkg.engines.node ? `package.json engines.node=${pkg.engines.node}` : '');
} catch (_) {}
NODE
)"
    if [ -n "$engines" ]; then
      parts+=("$engines")
    fi
  fi
  if [ "${#parts[@]}" -eq 0 ]; then
    printf '未声明；请在项目中补充 .nvmrc、.node-version 或 package.json engines.node'
  else
    local IFS='；'
    printf '%s' "${parts[*]}"
  fi
}

package_json_section() {
  if [ ! -f "$PROJECT_ROOT/package.json" ]; then
    cat <<'EOF'
未检测到 `package.json`。如果本项目不是 Node 项目，请在“常用命令”和“模块地图”中补充真实技术栈信息。
EOF
    return
  fi

  if ! command -v node >/dev/null 2>&1; then
    cat <<'EOF'
检测到 `package.json`，但当前环境没有可用 `node` 命令，bootstrap 未解析依赖详情。请研发手工补充 scripts、dependencies 和工作区关系。
EOF
    return
  fi

  PROJECT_ROOT="$PROJECT_ROOT" node <<'NODE'
const fs = require('fs');
const path = require('path');
const root = process.env.PROJECT_ROOT;
const pkg = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8'));
const names = (obj, limit = 40) => {
  const list = Object.keys(obj || {}).sort();
  if (!list.length) return '无';
  const shown = list.slice(0, limit).map((name) => `\`${name}\``).join('、');
  return list.length > limit ? `${shown} 等 ${list.length} 项` : shown;
};
const scripts = Object.entries(pkg.scripts || {});
const scriptLines = scripts.length
  ? scripts.map(([name, value]) => `| \`${name}\` | \`${value}\` |`).join('\n')
  : '| 未声明 |  |';
let workspaces = '未声明';
if (Array.isArray(pkg.workspaces)) {
  workspaces = pkg.workspaces.map((item) => `\`${item}\``).join('、') || '未声明';
} else if (pkg.workspaces && Array.isArray(pkg.workspaces.packages)) {
  workspaces = pkg.workspaces.packages.map((item) => `\`${item}\``).join('、') || '未声明';
}
const packageManager = pkg.packageManager ? `\`${pkg.packageManager}\`` : '未声明';
const name = pkg.name ? `\`${pkg.name}\`` : '未声明';
const version = pkg.version ? `\`${pkg.version}\`` : '未声明';
const type = pkg.type ? `\`${pkg.type}\`` : '未声明';
console.log(`- package name：${name}`);
console.log(`- package version：${version}`);
console.log(`- package type：${type}`);
console.log(`- packageManager 字段：${packageManager}`);
console.log(`- workspaces：${workspaces}`);
console.log('');
console.log('### package scripts');
console.log('');
console.log('| script | command |');
console.log('| --- | --- |');
console.log(scriptLines);
console.log('');
console.log('### dependencies');
console.log('');
console.log(`- dependencies：${names(pkg.dependencies)}`);
console.log(`- devDependencies：${names(pkg.devDependencies)}`);
console.log(`- peerDependencies：${names(pkg.peerDependencies)}`);
NODE
}

generate_project_adapter_content() {
  local package_manager stack_files common_dirs node_versions generated_at project_name
  package_manager="$(detect_package_manager)"
  stack_files="$(detect_stack_files)"
  common_dirs="$(detect_common_dirs)"
  node_versions="$(node_version_summary)"
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  project_name="$(basename "$PROJECT_ROOT")"

  cat <<EOF
# 项目适配说明

本文件由 Team-Intelligence-Center bootstrap 自动生成，用于让 AI 快速了解当前项目。请研发按真实情况补充业务背景、风险边界和缺失命令。

生成时间：$generated_at
项目标识：\`$project_name\`
项目根：当前仓库根（安装脚本不写入本机绝对路径）

## 项目画像

- 产品 / 服务：待补充
- 主要用户：待补充
- 技术栈文件：$stack_files
- 主要模块目录：$common_dirs
- 包管理器推断：$package_manager
- Node 版本声明：$node_versions
- 部署目标：待补充

## Node / 前端项目详情

$(package_json_section)

## 项目关系

- OpenSpec：$([ -d "$PROJECT_ROOT/openspec" ] && printf '已检测到 `openspec/`' || printf '未检测到 `openspec/`')
- Monorepo 线索：$([ -f "$PROJECT_ROOT/pnpm-workspace.yaml" ] && printf '检测到 `pnpm-workspace.yaml`；' || true)$([ -d "$PROJECT_ROOT/apps" ] && printf '检测到 `apps/`；' || true)$([ -d "$PROJECT_ROOT/packages" ] && printf '检测到 `packages/`；' || true)
- 规则入口：bootstrap 会生成或更新项目根 \`AGENTS.md\`

## 产物归属与落盘

请按真实情况维护。父工作区、多子项目、独立项目或多仓联动时，AI 以这里的归属为准；未确认项写“待确认”。

\`\`\`yaml
artifact_ownership:
  owner_type: project # workspace | project | subproject | external
  owner_id: "$project_name"
  parent_workspace: ""
  child_projects: []
  related_repositories: []
artifact_roots:
  sdd_root: "$([ -d "$PROJECT_ROOT/openspec" ] && printf 'openspec/changes' || printf 'docs/sdd')"
  tdd_evidence_root: "docs/test-evidence"
  prd_root: "docs/PRD"
  prd_draft_root: "docs/PRD/drafts"
  walkthrough_root: "docs/walkthroughs"
release_ownership:
  owner_type: project # workspace | project | subproject | external
  owner_id: "$project_name"
  release_registry_root: "docs/releases"
  version_policy: independent # shared | independent | external
  version_format: semver # semver | three-digit-patch | calendar | custom
  branch_strategy: project-defined # trunk | gitflow | project-defined
  feature_base: "待确认"
  release_base: "待确认"
  hotfix_base: "待确认"
  tag_policy: "preserve-existing" # preserve-existing | no-v-prefix | v-prefix | custom
  deployment_trigger: "tag-push" # tag-push | manual-pipeline | external | 待确认
\`\`\`

## 常用命令

请以项目真实命令为准。若上方 package scripts 已列出命令，优先使用其中的 lint、typecheck、test、build。

\`\`\`bash
# 安装依赖

# lint

# 类型检查

# 测试

# 构建
\`\`\`

## 模块地图

| 区域 | 路径 | 说明 |
| --- | --- | --- |
| 前端 | 待补充 |  |
| 后端 | 待补充 |  |
| 测试 | 待补充 |  |
| 文档 | 待补充 |  |

## 风险边界

列出需要额外谨慎、人工确认或回滚方案的区域：

- 认证 / 权限：待补充
- 支付 / 资金：待补充
- 数据迁移：待补充
- 生产配置：待补充
- 外部集成：待补充

## 本地决策

记录未来 AI 会话必须延续的项目级决策：

-
EOF
}

install_project_adapter() {
  local dst="$PROJECT_ROOT/ai-harness/project-adapter.md"
  local rel="${dst#$PROJECT_ROOT/}"

  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    plan "skip existing $rel"
    return
  fi

  if [ -e "$dst" ]; then
    plan "overwrite $rel with detected project profile and backup"
  else
    plan "create $rel with detected project profile"
  fi

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
      backup_file "$dst"
    fi
    generate_project_adapter_content > "$dst"
  fi
}

write_lock() {
  local target="$PROJECT_ROOT/.tic-rules.lock"
  plan "write .tic-rules.lock"
  if [ "$DRY_RUN" -eq 0 ]; then
    local tmp line
    tmp="$(mktemp)"
    cat > "$tmp" <<EOF
managed_by=team-intelligence-center
version=2
rules_version=$VERSION
package_id=$PACKAGE_ID
install_mode=minimal
rules_source=$RULES_SOURCE_MODE
rules_path=$RULES_PROJECT_PATH
local_config=.tic-rules.local
EOF
    if [ -f "$target" ]; then
      while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
          managed_by=*|version=*|rules_version=*|package_id=*|install_mode=*|rules_source=*|rules_path=*|local_config=*|"")
            ;;
          *)
            printf '%s\n' "$line" >> "$tmp"
            ;;
        esac
      done < "$target"
    fi
    mv "$tmp" "$target"
  fi
}

write_local_config() {
  local target="$PROJECT_ROOT/.tic-rules.local"
  plan "write .tic-rules.local"
  if [ "$DRY_RUN" -eq 0 ]; then
    cat > "$target" <<EOF
# Local Team-Intelligence-Center resolver.
# This file is machine-specific and must not be committed.
rules_dir=$RULES_DIR
rules_source=$RULES_SOURCE_MODE
rules_path=$RULES_PROJECT_PATH
updated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
  fi
}

ensure_gitignore_local_config() {
  local target="$PROJECT_ROOT/.gitignore"
  local needs_header=1
  local needs_local=1
  local needs_backups=1
  local needs_agent_runs=1

  if [ -f "$target" ]; then
    if grep -Fxq "# Team-Intelligence-Center local files" "$target" ||
       grep -Fxq ".tic-rules.local" "$target" ||
       grep -Fxq ".tic-backups/" "$target"; then
      needs_header=0
    fi
    if grep -Fxq ".tic-rules.local" "$target"; then
      needs_local=0
    fi
    if grep -Fxq ".tic-backups/" "$target"; then
      needs_backups=0
    fi
    if grep -Fxq ".tic/agent-runs/" "$target"; then
      needs_agent_runs=0
    fi
  fi

  if [ "$needs_local" -eq 0 ] && [ "$needs_backups" -eq 0 ] && [ "$needs_agent_runs" -eq 0 ]; then
    plan "skip .gitignore TIC local entries"
    return
  fi

  if [ -f "$target" ]; then
    plan "append TIC local entries to .gitignore"
  else
    plan "create .gitignore with TIC local entries"
  fi

  if [ "$DRY_RUN" -eq 0 ]; then
    if [ -f "$target" ]; then
      backup_file "$target"
    fi
    {
      if [ -f "$target" ]; then
        cat "$target"
        printf '\n'
      fi
      if [ "$needs_header" -eq 1 ]; then
        printf '# Team-Intelligence-Center local files\n'
      fi
      if [ "$needs_local" -eq 1 ]; then
        printf '.tic-rules.local\n'
      fi
      if [ "$needs_backups" -eq 1 ]; then
        printf '.tic-backups/\n'
      fi
      if [ "$needs_agent_runs" -eq 1 ]; then
        printf '.tic/agent-runs/\n'
      fi
    } > "$target.tmp"
    mv "$target.tmp" "$target"
  fi
}

merge_agents
install_template_file "$PACKAGE_ROOT/templates/docs/ai-rules-usage.md" "$PROJECT_ROOT/docs/ai-rules-usage.md"
install_template_file "$PACKAGE_ROOT/templates/tool-rules/cursorrules.md" "$PROJECT_ROOT/.cursorrules"
install_template_file "$PACKAGE_ROOT/templates/tool-rules/windsurfrules.md" "$PROJECT_ROOT/.windsurfrules"
install_template_file "$PACKAGE_ROOT/templates/tool-rules/rules/team-intelligence-center.md" "$PROJECT_ROOT/.rules/team-intelligence-center.md"
install_project_adapter
install_template_file "$PACKAGE_ROOT/templates/ai-harness/agent-session-protocol.md" "$PROJECT_ROOT/ai-harness/agent-session-protocol.md"
write_lock
write_local_config
ensure_gitignore_local_config

printf 'Team-Intelligence-Center bootstrap plan for %s:\n' "$PROJECT_ROOT"
for item in "${planned[@]}"; do
  printf '  - %s\n' "$item"
done

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\nDry run only. No files changed.\n'
  exit 0
fi

printf '\nBootstrap complete.\n'
