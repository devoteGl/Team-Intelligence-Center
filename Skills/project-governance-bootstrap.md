---
schema: tic_skill.v1
id: project-governance-bootstrap
status: canonical
phase: bootstrap
role: PM / DS / Tech Lead
risk_min: consulting
inputs:
  - project_root
  - rules_source
outputs:
  - agents_entrypoint
  - ai_rules_usage
  - project_adapter
  - openspec_workspace
requires: []
delegates_to: []
---

# Project Governance Bootstrap（项目治理接入技能）

## 技能用途

- 服务角色：**PM / DS / Tech Lead**
- 触发时机：业务项目首次以 submodule 引入 `Team-Intelligence-Center` 后
- 输出物：项目根目录 `AGENTS.md`、`docs/ai-rules-usage.md`、`ai-harness/`、`openspec/` 基础治理文件，以及 Superpowers 协作边界说明
- 适用场景：新项目接入组织研发范式、老项目补齐 AI 规则入口、不同编辑器统一 OpenSpec / OPSX 使用方式、声明 Superpowers 与 OpenSpec 的协作边界

> 目标：让开发只关注业务需求和架构内实现，把规则入口、规格层、执行方法层、项目记忆层、文档层的初始化尽量自动化。

---

## 0. 核心原则

**只迁开发范式，不强行迁技术栈。**

本技能不要求项目使用 go-zero、admin-template 或 Unibest；这些模板只是新项目推荐基座。老项目接入时，应保留现有技术栈和目录结构。

**绝对禁止**：

- 覆盖已有 `AGENTS.md`、`docs/`、`ai-harness/`、`openspec/` 中的人写内容。
- 为了接入组织范式而重构业务代码。
- 把 AI 推测写成稳定规格。
- 未冻结契约就推动跨端接口实现。
- 把 `opsx` 当成终端命令；终端入口是 `openspec`。
- 把 Superpowers 的临时 spec 或 brainstorm 材料当成 OpenSpec 主规格。
- 未建立 OpenSpec change 就用 Superpowers 绕过跨端、跨模块或接口契约变更流程。

---

## 1. 使用方式

在业务项目根目录中，先以 submodule 引入组织规则：

```bash
git submodule add <Team-Intelligence-Center-repo-url> ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

然后对 AI 说：

```text
请读取 ai-rules/Team-Intelligence-Center/Skills/project-governance-bootstrap.md，
按该技能初始化本项目的 AI 治理入口。
```

如果已经安装 OpenSpec CLI，可同时执行：

```bash
openspec init --tools codex,cursor,qoder,opencode --force
```

如果团队计划使用 Superpowers，本技能应在接入过程中自动检测并尽力安装；无法静默安装的图形插件市场或交互式命令，需要写入最终报告的人工待办。Superpowers 不由 OpenSpec CLI 初始化。

---

## 2. 执行流程

### Step 1：确认项目根目录

确认当前目录是业务项目根目录，应至少满足以下之一：

- 有 `.git/`。
- 有业务工程入口，例如 `package.json`、`go.mod`、`pom.xml`、`build.gradle`、`composer.json`、`Cargo.toml`。
- 有多端子目录，例如 `backend/`、`admin/`、`client/`、`server/`、`web/`、`app/`。

如果当前目录明显不是项目根目录，先切换到正确根目录。

### Step 2：确认组织规则路径

优先识别以下路径：

```text
ai-rules/Team-Intelligence-Center/
.ai-rules/Team-Intelligence-Center/
Team-Intelligence-Center/
```

如果路径不同，记录实际路径，并在生成文件中使用真实路径。

### Step 3：盘点项目现状

只读扫描项目结构，识别：

- 后端目录。
- 前端 / H5 / App / 小程序目录。
- 管理后台目录。
- 文档目录。
- 现有 AI 规则入口，例如 `AGENTS.md`、`.cursor/`、`.codex/`、`.qoder/`、`.opencode/`。
- 现有 OpenSpec 目录。
- 现有 Superpowers 安装痕迹或运行态目录，例如 `.superpowers/`、`docs/superpowers/`。

不得在此阶段修改业务代码。

### Step 4：生成或补齐治理文件

必需产物：

```text
AGENTS.md
docs/ai-rules-usage.md
ai-harness/project-adapter.md
ai-harness/memory/README.md
ai-harness/memory/project-context.md
ai-harness/memory/decision-log.md
ai-harness/memory/runbooks.md
openspec/config.yaml
openspec/README.md
openspec/changes/README.md
openspec/changes/archive/README.md
openspec/specs/README.md
openspec/specs/workspace/spec.md
```

可选产物：

```text
docs/README.md
docs/api-contracts/README.md
docs/PRD/README.md
docs/design/README.md
.gitignore
```

生成规则：

- 文件不存在：创建完整文件。
- 文件已存在：追加或更新 `<!-- TIC:PROJECT-GOVERNANCE:START -->` 到 `<!-- TIC:PROJECT-GOVERNANCE:END -->` 区块。
- 如果已有同类人工内容但没有 marker：先保留原文，再新增“组织 AI 研发范式”章节。
- 所有 `TODO` 必须明确标出，不伪造事实。

### Step 5：初始化 OpenSpec 工具入口

如果 `openspec` 命令存在，执行：

```bash
openspec init --tools codex,cursor,qoder,opencode --force
openspec validate --all --no-interactive
```

如果 `openspec` 不存在，在最终报告中提示：

```bash
npm install -g @fission-ai/openspec@latest
openspec init --tools codex,cursor,qoder,opencode --force
```

### Step 6：自动检测并尽力安装 Superpowers

目标：能自动安装就自动安装，不能自动安装就留下明确、可执行的人工步骤；不得因为 Superpowers 安装失败阻塞项目治理接入。

先检测是否已安装：

```bash
test -d "$HOME/.codex/plugins/cache/openai-curated/superpowers" || \
test -d "$HOME/.codex/plugins/cache/openai-bundled/superpowers" || \
test -d "$HOME/.config/superpowers" || \
test -d ".superpowers"
```

如果已安装或已存在运行态目录：

- 记录为“已检测到 Superpowers”。
- 确认 `.superpowers/` 是否需要加入 `.gitignore`。

如果未检测到，按可用命令尽力安装：

| 环境 | 自动动作 | 失败或不可用时 |
| --- | --- | --- |
| Gemini CLI | 如果存在 `gemini`，可执行 `gemini extensions install https://github.com/obra/superpowers` | 报告中提示手动执行该命令 |
| Factory Droid | 如果存在 `droid`，可执行 `droid plugin marketplace add https://github.com/obra/superpowers` 和 `droid plugin install superpowers@superpowers` | 报告中提示手动执行两条命令 |
| GitHub Copilot CLI | 如果存在 `copilot`，可执行 `copilot plugin marketplace add obra/superpowers-marketplace` 和 `copilot plugin install superpowers@superpowers-marketplace` | 报告中提示手动执行两条命令 |
| Claude Code | 通常需要在 Claude Code 内执行 `/plugin install superpowers@claude-plugins-official` | 写入人工待办 |
| Codex CLI | 通常需要打开 `/plugins`，搜索 `superpowers` 并安装 | 写入人工待办 |
| Codex App | 需要在插件市场搜索 `Superpowers` 并点击安装 | 写入人工待办 |
| Cursor | 需要在 Agent chat 执行 `/add-plugin superpowers` 或插件市场安装 | 写入人工待办 |
| OpenCode | 需要按 OpenCode 插件机制读取官方安装说明 | 写入人工待办 |

安装规则：

- 只执行当前环境中明确存在的 CLI 命令。
- 不猜测用户使用哪个 AI 工具；检测到多个命令时，可按团队实际工具逐项尝试。
- 不用破坏性命令，不覆盖已有插件配置。
- 任一安装失败都不终止 bootstrap；记录失败命令、原因摘要和人工补救步骤。
- 在 `AGENTS.md`、`docs/ai-rules-usage.md`、`openspec/config.yaml` 中始终写明：OpenSpec 是规格事实源，Superpowers 是执行方法层。

建议 `.gitignore` 处理：

- 如果 `.gitignore` 不存在，可创建并加入 `.superpowers/`。
- 如果 `.gitignore` 已存在且没有 `.superpowers/`，追加到 `<!-- TIC:PROJECT-GOVERNANCE:START -->` marker 区块；没有 marker 时保留原文并新增小节。
- 如果团队明确要提交某些 Superpowers 产物，只保留 `.superpowers/` 的忽略说明，不擅自调整保留策略。

### Step 7：输出接入报告

最终报告必须包含：

- 生成或更新的文件清单。
- 识别到的项目目录和端类型。
- 是否已执行 OpenSpec 初始化。
- Superpowers 检测、自动安装、失败原因或人工待办。
- 验证结果。
- 仍需人工补齐的 TODO。

---

## 3. `AGENTS.md` 标准模板

````markdown
# AGENTS.md

本项目使用组织统一 AI 研发范式。

<!-- TIC:PROJECT-GOVERNANCE:START -->
## 组织规则入口

必须优先阅读：

- `ai-rules/Team-Intelligence-Center/Global-Rules/coding-rules.md`
- `ai-rules/Team-Intelligence-Center/Design/development-paradigm-openspec-guide.md`
- `docs/ai-rules-usage.md`
- `ai-harness/project-adapter.md`
- `openspec/config.yaml`

## 工作方式

- 普通小修、错字、局部 bug：可直接处理。
- 新需求、中大型改动、跨端改动、接口契约变化：先走 OpenSpec。
- AI 工具中使用 `/opsx:*`，终端中使用 `openspec`。
- 不要把 `opsx` 当成终端命令。
- 如已启用 Superpowers：它只负责计划、TDD、调试、review、子代理执行；OpenSpec 仍是规格事实源。

推荐链路：

```text
/opsx:explore -> /opsx:propose -> 契约冻结 -> /opsx:apply -> Superpowers 执行 -> 验证 -> /opsx:archive
```

## 文件边界

- 业务实现：遵守项目现有目录结构。
- 活跃变更：`openspec/changes/`
- 稳定规格：`openspec/specs/`
- 项目记忆：`ai-harness/memory/`
- 长期文档：`docs/`
- API 契约：`docs/api-contracts/`
- Superpowers 本地状态：`.superpowers/`，默认不提交

## 安全约束

- 不覆盖已有人工规则。
- 不因接入范式而重构业务代码。
- 不把 AI 推测写入稳定规格。
- 不把 Superpowers 临时产物写成稳定规格。
- 删除旧逻辑、重大契约变更、生产数据操作必须先确认。
<!-- TIC:PROJECT-GOVERNANCE:END -->
````

---

## 4. `docs/ai-rules-usage.md` 标准模板

````markdown
# AI Rules Usage

本项目使用组织 `Team-Intelligence-Center` 作为统一 AI 研发范式来源。

<!-- TIC:PROJECT-GOVERNANCE:START -->
## 规则来源

本地路径：

```text
ai-rules/Team-Intelligence-Center/
```

核心文件：

- `Global-Rules/coding-rules.md`：提交规范、角色、阶段、检查点、会话快照。
- `Design/development-paradigm-openspec-guide.md`：组织研发范式 + OpenSpec / Superpowers 落地指南。
- `Prompts/ai-prd-generator.rules.md`：新需求 PRD 生成。
- `Prompts/ai-prd-editor.rules.md`：老项目 / 存量项目 PRD 梳理。
- `Skills/`：调研、任务拆解、契约冻结、交接、验收、归档等能力。

## OpenSpec 使用

终端命令：

```bash
openspec list
openspec show <change-name>
openspec validate --all --no-interactive
```

AI 工具命令：

```text
/opsx:explore
/opsx:propose
/opsx:apply
/opsx:archive
```

## Superpowers 使用

Superpowers 是可选的 Agent 执行方法层，不替代 OpenSpec。项目接入时会尽力自动检测并安装；如果当前工具只能通过图形插件市场或交互式命令安装，则按接入报告中的人工步骤完成。

推荐用途：

- 需求仍不清楚时，用 brainstorming 辅助澄清，结论写回 proposal 或 PRD。
- 已有 OpenSpec tasks 后，用 writing-plans、TDD、debugging、code review 或 subagent-driven development 执行。
- bug 修复后，把复现条件和稳定行为写回 `openspec/specs/` 或 `ai-harness/memory/`。

边界：

- OpenSpec 是规格事实源。
- Superpowers 产物必须引用 OpenSpec change id 或明确任务来源。
- `docs/superpowers/specs/` 不作为主规格目录。
- `.superpowers/` 默认是本地运行态目录，通常加入 `.gitignore`。

常见人工安装入口：

```text
Codex App：插件市场搜索 Superpowers 并安装
Codex CLI：/plugins -> 搜索 superpowers -> Install Plugin
Claude Code：/plugin install superpowers@claude-plugins-official
Cursor：/add-plugin superpowers
Gemini CLI：gemini extensions install https://github.com/obra/superpowers
```

## 日常规则

- 小修小改可以直接处理。
- 新需求、中大型变更、跨端变更、接口变化必须先 `/opsx:propose`。
- 有 OpenSpec change 时，Superpowers 执行计划和 review 需引用 change id。
- 涉及前后端协作时，先按 `Skills/contract-handoff.md` 冻结契约并生成 FE/BE 交接清单。
- 稳定事实写入 `openspec/specs/` 和 `ai-harness/memory/`。
- 长期 PRD、API 契约、外部服务说明写入 `docs/`。

## 本项目不做什么

- 不复制组织规则原文。
- 不维护第二套 PRD 或提交规范。
- 不因为接入组织范式而迁移技术栈。
- 不把 OpenSpec 当普通文档目录乱放材料。
- 不把 Superpowers 临时材料当成已确认需求或稳定规格。
<!-- TIC:PROJECT-GOVERNANCE:END -->
````

---

## 5. `ai-harness/project-adapter.md` 标准模板

```markdown
# Project Adapter

本文档记录组织 `Team-Intelligence-Center` 在当前项目中的适配方式。

## 项目边界

<!-- TIC:PROJECT-GOVERNANCE:START -->
| 边界 | 当前项目目录 | 说明 |
| --- | --- | --- |
| 后端 | TODO | TODO |
| 前端 / H5 / App | TODO | TODO |
| 管理后台 | TODO | TODO |
| 文档 | `docs/` | PRD、API 契约、外部服务、设计资料 |
| 规格 | `openspec/` | 活跃变更和稳定规格 |
| 项目记忆 | `ai-harness/memory/` | 项目事实、决策、runbook |
| 组织规则 | `ai-rules/Team-Intelligence-Center/` | 通用规则来源 |
| Superpowers | `.superpowers/` | 可选，本地执行状态，默认不提交 |
<!-- TIC:PROJECT-GOVERNANCE:END -->

## 老项目说明

如果当前项目不是组织推荐模板，不需要迁移技术栈。先记录真实现状，再逐步把稳定行为写入 OpenSpec。
```

---

## 6. `openspec/config.yaml` 标准模板

```yaml
schema: spec-driven

context: |
  Project: TODO
  Governance: company AI rules live in ai-rules/Team-Intelligence-Center/
  Project adaptation: ai-harness/ stores project memory, decisions, and runbooks
  Documentation: docs/ stores PRDs, API contracts, vendor docs, and design notes
  Agent execution: Superpowers may be used for brainstorming, planning, TDD, debugging, code review, and subagent-driven development.
  Change process: proposal -> specs -> design -> tasks -> implement -> verify -> archive
  Collaboration:
    - Codex, Cursor, Qoder, and OpenCode must follow the same artifact flow
    - tools may differ, but specs, contracts, review gates, and archive steps must stay consistent
    - OpenSpec remains the source of truth for specs; Superpowers execution artifacts must reference the OpenSpec change when one exists

rules:
  proposal:
    - State affected subprojects.
    - Call out rollback risk for cross-end or contract changes.
    - Note whether docs, specs, or memory must be updated.
  specs:
    - Describe observable behavior and acceptance criteria.
    - Keep stable current behavior under openspec/specs.
  design:
    - Explain boundary ownership, dependencies, and integration order.
    - Include migration or rollback notes for riskier changes.
  tasks:
    - Split work by role and subproject.
    - Include verification steps for each surface.
    - If using Superpowers, bind execution plans and reviews to the OpenSpec change id.
```

---

## 7. `openspec/specs/workspace/spec.md` 标准模板

```markdown
# Workspace Spec

## Purpose

This workspace coordinates project implementation, OpenSpec changes, project memory, and long-term documentation under the company AI development paradigm.

## Requirements

### Requirement: Governance Entry Points

The project SHALL expose stable AI governance entry points for contributors and AI tools.

#### Scenario: Read company rules

- **WHEN** a contributor or AI tool starts work
- **THEN** it SHALL read `AGENTS.md`, `docs/ai-rules-usage.md`, and `ai-harness/project-adapter.md`

#### Scenario: Use OpenSpec for material changes

- **WHEN** a change is medium-sized, cross-module, cross-end, or contract-affecting
- **THEN** the change SHALL be represented under `openspec/changes/` before implementation

#### Scenario: Use Superpowers for execution

- **WHEN** Superpowers is used for planning, TDD, debugging, review, or subagent-driven development
- **THEN** its outputs SHALL reference the OpenSpec change id when one exists
- **AND** stable behavior SHALL still be synchronized back to `openspec/specs/`

### Requirement: Preserve Project Facts

The project SHALL distinguish stable facts from assumptions.

#### Scenario: Record stable behavior

- **WHEN** behavior is verified by code, tests, runtime evidence, or human confirmation
- **THEN** it SHALL be eligible for `openspec/specs/` or `ai-harness/memory/`

#### Scenario: Record uncertain behavior

- **WHEN** behavior is inferred from old documents, comments, or AI reasoning
- **THEN** it SHALL remain a candidate fact until verified
```

---

## 8. 质量自检

执行完成后必须确认：

- [ ] `AGENTS.md` 已存在并指向组织规则。
- [ ] `docs/ai-rules-usage.md` 已说明终端用 `openspec`、AI 工具用 `/opsx:*`。
- [ ] `docs/ai-rules-usage.md` 已说明 Superpowers 是执行方法层，不是规格事实源。
- [ ] `ai-harness/project-adapter.md` 已记录项目边界。
- [ ] `ai-harness/memory/` 已有 README、project-context、decision-log、runbooks。
- [ ] `openspec/config.yaml` 已包含项目上下文。
- [ ] `openspec/specs/workspace/spec.md` 使用 OpenSpec 合法格式：`## Purpose` + `## Requirements`。
- [ ] 已检测 Superpowers；可自动安装的环境已尝试安装，不能自动安装的环境已写入人工待办。
- [ ] 如果团队启用 Superpowers，`.superpowers/` 已按团队约定 gitignore 或说明保留策略。
- [ ] 如果安装了 OpenSpec CLI，`openspec validate --all --no-interactive` 已通过或失败原因已记录。
- [ ] 未修改业务代码。

---

## 9. 最终报告模板

```markdown
## 项目治理接入完成

已生成 / 更新：
- AGENTS.md
- docs/ai-rules-usage.md
- ai-harness/...
- openspec/...

识别到的项目边界：
- 后端：...
- 前端：...
- 管理后台：...
- 文档：...

OpenSpec：
- 初始化：已执行 / 未执行（原因）
- 校验：通过 / 未通过（摘要）

Superpowers：
- 检测：已安装 / 未检测到
- 自动安装：已执行 / 不适用 / 失败（原因）
- 人工待办：无 / TODO
- 边界：OpenSpec 为规格事实源，Superpowers 为执行方法层

仍需人工补齐：
- TODO ...

后续使用：
- 小修小改：直接和 AI 对话
- 新需求 / 跨端 / 契约变化：`/opsx:propose`
- 开始实现：`/opsx:apply <change-name>`，必要时用 Superpowers 执行计划、TDD、调试和 review
- 验证后归档：`/opsx:archive <change-name>`
```
