---
schema: tic_capability.v1
id: project-governance-bootstrap
status: canonical
category: governance
activation:
  when:
    - 用户明确要求项目接入或刷新 TIC
  not_when:
    - 普通研发任务或项目入口已经满足当前需求
side_effects: local-reversible
artifacts:
  default: project-governance-entrypoints
  when_needed:
    - 项目需要规则入口、adapter、memory 骨架或工具接入说明
requires: []
related:
  - project-adapter-maintainer
---

# Project Governance Bootstrap（项目治理接入技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Project Maintainer**
- 触发时机：用户明确要求把项目接入 TIC，或刷新 TIC 管理的入口
- 输出物：轻量规则入口、Project Adapter、工具入口和共享 memory 骨架
- 适用场景：新项目首次接入、旧项目补齐入口、规则源迁移、模板安全刷新

本能力只接入 TIC 轻量入口。它不接管业务技术栈、规格工具、插件系统、
Git 生命周期或发布流程。

## 0. 核心边界

必须遵守：

- 默认使用规则包提供的 `tools/install.*` 或 `tools/bootstrap-project.*`，
  不复制另一套生成逻辑。
- 先预览写入计划，再执行项目内可逆变更。
- 普通安装和刷新保留已有 Project Adapter、shared memory 和自定义内容。
- 只创建缺失的 memory 模板，不创建个人画像或本地候选。
- 项目文件只记录相对规则路径；本机绝对路径只进入 gitignored
  `.tic-rules.local`。
- 生成后验证入口、幂等和保留性。

绝对禁止：

- 覆盖已有 `ai-harness/project-adapter.md` 或 `ai-harness/memory/`。
- 自动修改业务代码、技术栈、依赖、数据库或生产配置。
- 自动创建 Git 分支、提交、submodule、push、merge 或 tag。
- 不安装 OpenSpec、Superpowers 或其他外部插件与 CLI。
- 把 TIC 接入解释成必须创建 PRD、SDD、OpenSpec change 或 session
  artifact。
- 把个人偏好、原始聊天、秘密或认证状态写进项目资产。

如果用户还要求 Git 接入、外部工具安装或规格系统初始化，把它们视为独立
动作，分别确认边界；不得由本能力隐式执行。

## 1. 输入

执行前确认：

```yaml
project_root: ""
rules_dir: ""
operation: install | refresh | regenerate-adapter
preview_first: true
```

能从当前目录和项目文件确定的字段直接调查。只有目标项目或规则源存在多个
合理候选且结果会明显不同，才询问用户。

`regenerate-adapter` 会替换项目维护的事实文件，即使脚本会备份，也必须是
用户明确要求的操作。

## 2. 只读盘点

确认：

- 项目根目录；
- 当前 `AGENTS.md`、`.tic-rules.lock`、`.tic-rules.local`；
- `.cursorrules`、`.windsurfrules`、`.rules/`；
- `ai-harness/project-adapter.md` 和 `ai-harness/memory/`；
- 规则包中 `VERSION`、`manifest.json` 和安装脚本；
- 项目是否为单仓、workspace 或含子项目。

盘点不修改业务代码，也不因检测到某个外部工具就安装或初始化它。

## 3. 执行

### 3.1 Shell

预览：

```bash
bash <rules_dir>/tools/install.sh \
  --preview \
  --rules-dir <rules_dir> \
  <project_root>
```

首次安装：

```bash
bash <rules_dir>/tools/install.sh \
  --rules-dir <rules_dir> \
  <project_root>
```

刷新：

```bash
bash <rules_dir>/tools/install.sh \
  --refresh \
  --rules-dir <rules_dir> \
  <project_root>
```

只有用户明确要求重建 adapter 时追加：

```text
--regenerate-adapter
```

### 3.2 PowerShell

使用 `tools/install.ps1` 的等价参数：

```text
-Preview
-RulesDir <rules_dir>
-ProjectRoot <project_root>
-Refresh
-RegenerateAdapter
```

`-RegenerateAdapter` 与 Shell 版本遵守同一确认边界。

### 3.3 生成资产

脚本可管理：

```text
AGENTS.md
.tic-rules.lock
.tic-rules.local
.cursorrules
.windsurfrules
.rules/team-intelligence-center.md
docs/ai-rules-usage.md
ai-harness/project-adapter.md
ai-harness/agent-session-protocol.md
ai-harness/memory/README.md
ai-harness/memory/project-context.md
ai-harness/memory/decision-log.md
ai-harness/memory/runbooks.md
ai-harness/memory/team-collaboration.md
```

`.tic-rules.local`、`.tic-backups/`、`.tic/agent-runs/` 和 `.tic/local/`
必须保持 gitignored。

## 4. 保留性契约

### Project Adapter

- 文件不存在：允许首次生成。
- 文件已存在：普通 install、refresh、force 都逐字节保留。
- 需要补全、审计、迁移或修复：显式使用
  `project-adapter-maintainer`。
- 需要完整重生成：先确认，再使用 `regenerate-adapter`，并保留备份。

### Shared Memory

- 只创建缺失文件。
- 已有文件逐字节保留，不用模板覆盖。
- `.tic/local/` 的个人画像和候选由
  `collaboration-memory-maintainer` 在明确需要时创建。

### AGENTS 与工具入口

- 只更新 TIC marker 管理的区块或受管理模板。
- 保留 marker 外的人工内容。
- 重复刷新不得累积重复区块或无意义空白。

### Lock 与本地配置

- `.tic-rules.lock` 保留未知项目字段。
- 项目内规则源使用相对 `rules_path=`。
- 项目外绝对规则源只写 `.tic-rules.local`。

## 5. 外部系统边界

OpenSpec、Superpowers、CodeGraph、浏览器 runner 和其他插件都是独立能力或
项目工具，不是 TIC bootstrap 的依赖。

允许：

- 只读报告项目是否已经存在这些工具；
- 在最终摘要中列出可选后续动作；
- 用户另行明确要求后，按对应工具自己的安装和安全流程处理。

不允许：

- 因发现命令可用就执行安装；
- 因项目没有规格目录就自动创建一套；
- 因接入 TIC 就修改全局插件状态；
- 把外部工具安装失败写成 TIC 接入失败。

## 6. 验证

至少验证：

1. 目标入口文件存在；
2. `.tic-rules.lock` 能解析到规则源；
3. 提交文件不包含本机绝对路径；
4. Project Adapter 未被普通刷新覆盖；
5. 已有 shared memory 未被覆盖；
6. `.tic/local/` 被 gitignore；
7. 第二次相同刷新不产生额外差异；
8. 未修改业务代码或外部工具状态。

规则包维护者使用：

```bash
bash <rules_dir>/tools/validate-pack.sh
```

如果 PowerShell runtime 不可用，明确记录为未执行，不把静态对齐描述为
runtime 通过。

## 7. 输出

```markdown
## TIC 项目接入结果

- Operation:
- Project root:
- Rules source:
- Created:
- Refreshed:
- Preserved:
- Local-only:
- Validation:
- External tools changed: no
- Git operations: none
- Remaining decisions:
```

没有明确后续消费者时，不额外创建接入 Walkthrough、PRD 或 Release
Handoff。当前摘要和脚本输出足以作为普通接入结果。
