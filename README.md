# Team-Intelligence-Center 🧠
**(AI 研发团队智能协作中枢)**

> *消除「PM 觉得说清楚了，开发觉得没说清楚」的永恒矛盾，将散落在代码与人脑中的业务真正沉淀为系统资产。*

> Public preview: 当前版本为 `0.2.0`。本版本面向 Codex / GPT-5.6 精简普通任务门禁，并增加稳定版、开发分支和显式 ref 更新通道。

## 📖 项目简介

**Team-Intelligence-Center** 并非一个传统的业务应用程序，而是面向 AI 编程编辑器协作架构（如多角色 AI Agent）和工程团队（PM、前端、后端、QA、文档等）的**核心智能中枢引擎规范库**。

它提供了一整套标准化的协作角色边界、业务流转协议与结构化的 System Prompts。通过在工程项目中引入本项目定义的严格规则，可以有效约束 AI 行为，避免常见的大语言模型输出发散、代码偏好漂移以及跨角色信息失真，确保每一次需求交付与历史重构都严格遵守可追溯的工程底线。

## 📦 开源状态

- **License**：Apache-2.0，见 [LICENSE](./LICENSE)。
- **定位**：Chinese-first、tool-neutral 的 AI 工程协作规则包。
- **适用工具**：Codex、Cursor、Qoder、OpenCode、OpenSpec、Superpowers，以及其他能读取项目规则的 AI 编码工具。
- **版本记录**：见 [CHANGELOG.md](./CHANGELOG.md) 与 [docs/releases/](./docs/releases/)；`0.1.0` 已归档，当前版本为 `0.2.0`。

## 🏗️ 核心资产目录说明

### 1. 🗂️ Global-Rules (全局协作基础干系规范)
包含接管项目核心流程的全局基建约束守则：
- **`coding-rules.md`**：除了标准化 Git Conventional Commits 的基本约束外，核心定义了风险路由、按动作触发的检查点、契约/共享域隔离、验证要求和跨任务接力规则。

### 2. 📝 Prompts (产品级 AI 操作指令集)
提供适配不同工程场景下大语言模型的 Prompt 系统指令护栏库：
- **`ai-prd-generator.rules.md` (Universal Version - 新需求创造)**：AI-PRD 生成器规范。使得产品人员仅需自然语言表达交互诉求，AI 必须严格走 7 大维度结构化追问、自检与抗二义性测试，随后拆分出前端与后端真正可以执行理解的编码级任务清单，拒绝大端技术黑盒化。
- **`ai-prd-editor.rules.md` (Production Version - 存量重构梳理)**：AI-PRD 深度重构编辑器规范。这套规则重点处理无文档的老项目问题，限制 AI 的自我发挥（强制将反推信息评定可信度 S1~S4级别），强约束跨模型间的结构一致性（强制双层 Changelog 以防结构漂移），让庞大甚至腐化的系统重新长出“记忆”。

### 3. ⚡ Skills (可复用执行能力模块)
封装各角色在具体执行场景下的标准化操作方法论与输出模板。当前公开预览版采用 **single adaptive workflow + risk_floor**：`tic-workflow-orchestrator` 只做路由，具体执行由 canonical Skill 承担，旧入口通过 alias / subflow 保持兼容。

| Skill 文件 | 服务角色 | 核心能力 |
|-----------|---------|--------|
| `tic-workflow-orchestrator.md` | PM/Tech Lead | adaptive 工作流总控（风险分级、risk_floor、Skill DAG、检查点、OpenSpec/Superpowers 接合） |
| `code-investigator.md` | CI | 5 阶段代码调研方法论（目录扫描→技术栈→模块拆解→规则抽取→风险标记） |
| `contract-handoff.md` | PM/FE/BE | 契约冻结 + 前后端交接（冻结声明、字段、错误码、Mock、自测、联调） |
| `changelog-writer.md` | DS | 双层 Changelog 编写规范（全局总纲 + 版本详情，严格对齐 PRD Editor §11） |
| `task-decomposer.md` | PM | 任务拆解方法论（三维拆解 + 依赖链标注 + 质量自检） |
| `shared-domain-arbiter.md` | PM/Tech Lead | 共享文件域仲裁（router/types/constants/global config 等） |
| `agent-session-protocol.md` | PM/Tech Lead | 多 agent 独立会话的运行态信箱协议（可读目录、manifest、outbox、status、收敛规则） |
| `project-governance-bootstrap.md` | PM/DS | 项目首次接入组织范式时，生成 AGENTS、AI 规则说明、ai-harness、OpenSpec 基础治理文件，并声明 Superpowers 协作边界 |
| `delivery-walkthrough.md` | PM/Tech Lead/QA/DS | 完成实现后的交付走查 artifact（变更摘要、证据、截图/录屏、Review 指引、风险和后续动作） |
| `release-handoff.md` | PM/Release Manager/DS | 发版交接统一入口，`mode=single` 单变更，`mode=train` 多项目/SQL/脚本发版总控 |
| `git-flow-operator.md` | PM/Release Manager | Git Flow 分支创建、release/hotfix 合并、tag、push 与回灌门禁 |
| `post-dev-prd-sync.md` | DS/PM | 开发完成后基于证据生成 PRD 更新草稿、候选规则和待确认项 |

兼容入口：
- `api-contract-freezer.md`、`fe-be-handoff.md` → `contract-handoff.md`
- `conflict-arbiter.md` → `shared-domain-arbiter.md`
- `release-ops-handoff.md`、`release-train-handoff.md` → `release-handoff.md`
- `candidate-rule-extractor.md` 是 `code-investigator` 的规则抽取子流程
- `prd-review-checklist.md` 是验收 checklist
- `session-snapshot-manager.md` 是总控和全局规则使用的快照模板

### 4. 🧭 Design (落地范式与工具接入)
提供组织级研发范式、OpenSpec、Superpowers、Figma MCP 等跨项目落地指南：
- **`development-paradigm-openspec-guide.md`**：组织研发范式 + OpenSpec / Superpowers 落地指南。说明如何把本规则库、OpenSpec、Superpowers、Codex/Cursor/Qoder/OpenCode 和项目级规则入口组合成统一开发链路。
- **`figma-mcp-skills-guide.md`**：Figma MCP + Skills 通用使用说明。说明设计读取、设计转代码、设计系统规则沉淀和 Code Connect 映射流程。

### 5. 🛠️ Automation (轻量自动化层)
提供最小可用的规则接入与自检工具，吸收自动化思想但不复制重流程包：
- **`manifest.json` / `VERSION`**：声明规则包版本、资产清单、安装产物与刻意排除项。
- **`templates/`**：项目侧最小入口模板，包括 `AGENTS.md`、`docs/ai-rules-usage.md`、`ai-harness/project-adapter.md`、`ai-harness/agent-session-protocol.md`、`.cursorrules`、`.windsurfrules` 和 `.rules/team-intelligence-center.md`；它们是规则接入产物，不是业务技术栈脚手架。
- **`tools/bootstrap-project.sh` / `tools/bootstrap-project.ps1`**：幂等接入业务项目，默认只合并最小规则入口、轻量 lock，并自动生成项目画像；不安装 Git hooks、不复制历史 PRD、不绑定 Codex-only。
- **`tools/install.sh` / `tools/install.ps1`**：日常一条命令接入入口，默认安装到当前目录，底层复用 bootstrap。
- **`tools/update.sh` / `tools/update.ps1`**：日常一条命令升级入口，默认选择最新稳定 SemVer tag，也支持当前分支和显式 ref，然后刷新 Codex 全局包装器和项目入口。
- **`tools/install-codex-global.sh` / `tools/install-codex-global.ps1`**：可选安装 Codex 全局 Loader 和 `tic-*` skill 包装器；只负责发现项目 TIC，不复制完整 Skills。
- **`tools/codegraph-helper.sh` / `tools/codegraph-helper.ps1`**：可选 CodeGraph 上下文增强入口，帮助老项目和跨模块任务分析影响面；不默认安装或初始化。
- **`tools/git-advice.sh` / `tools/git-advice.ps1`**：只读 Git 副驾，输出分支和提交建议，不执行 Git 变更。
- **`tools/validate-pack.sh`**：校验规则包文件、版本、Skill 结构和轻量化约束。
- **`docs/automation.md`**：记录从 Codex_Project 吸收的有益机制，以及明确剔除的冗余部分。

自动化默认原则是 **adaptive workflow + 规格驱动 + 验收驱动验证**：consulting / micro 保持轻量；standard / critical 任务先明确行为规格，再从验收标准推导自动测试或可观察验证。OpenSpec 可作为规格事实源，执行方法层可替换。规格、验证证据、PRD 草稿、Walkthrough 和 Release Handoff 的归属与落盘根由 `ai-harness/project-adapter.md` 声明。强管控项目通过 `risk_floor=standard|critical` 锁定最低档位，不维护第二套 strict 流程。

## 🔄 核心工作流理念

本中枢要求系统开发迭代不仅生成代码，也保留与风险相称的规格、验证和决策证据：

1. **[Orchestrator] Intent Intake 与风险路由**：先区分用户原话、危险词、自治诉求和真实授权，再识别 consulting / micro / standard / critical，并应用 `risk_floor`。
2. **[PM] 任务拆解设计**：将自然语言提炼为任务清单及可被执行验证的验收标准。
3. **[CI] 代码基现状调研**：不带主观推测地盘点老代码现状并生成现状交接报告。
4. **[PM/FE/BE] 契约与交接**：通过 `contract-handoff` 冻结契约和 FE/BE 交接清单。
5. **[FE/BE] 并行执行隔离**：依照已冻结契约工作，修改共享域需 `shared-domain-arbiter`；如启用多 Agent / subagent，只能作为受控 fan-out 执行策略，必须遵守 TIC Agent Contract。跨独立会话时使用 `agent-session-protocol`，以人可读 run 目录和结构化 artifact 收口。
6. **[QA] 测试准入验收**：核心流用例执行与边缘退回重测。
7. **[DS/Release] 交付归档**：Walkthrough、PRD sync、Changelog、Release handoff 按风险和影响触发。

**📍 用户挂载点控制（Human-in-the-loop）**：人类用户是唯一 Product Owner。检查点不再按阶段机械暂停，而是在范围重大歧义、关键方案无法从事实确定、破坏性契约、高危动作、发布/外部写入或失败补救扩域时触发。定义以 `Global-Rules/coding-rules.md` 第 6 节为唯一事实源。

## 🚀 如何使用本智能中枢

> 📘 **完整使用指南请阅读 [USAGE.md](./USAGE.md)**，包含快速上手、各模块详细说明、工作流全景图、集成方式和 FAQ。

建议作为知识基座在团队协同工程中进行应用：
- **AI 提示词挂载**：优先在项目级 `AGENTS.md` 或项目规则入口引用本仓库，不默认覆盖开发者全局 System Prompt 或全局 skills。由于其使用纯文本约束，所有 LLM 均可读取并转入 Team Agent 模拟态投入工作。
- **Submodule 规范基石**：将其作为 `git submodule` 集成在大型复杂工程库的独立存放点作为约束性资产规范，配合代码审批流长期守护项目全生命周期的产品需求与技术一致边界。
- **轻量自动化接入**：执行 `bash /path/to/Team-Intelligence-Center/tools/install.sh`，默认把最小入口写入当前业务项目。
- **日常规则升级**：在业务项目中执行 `bash /path/to/Team-Intelligence-Center/tools/update.sh --project /path/to/project`，默认升级到最新稳定 tag 并刷新入口；贡献者可使用 `--channel current`。
- **0.1.0 首次升级**：正常仍执行原来的一条更新命令；只有 detached HEAD、自定义旧分支或未取得 `0.2.0` 时，才使用 [USAGE.md 的兜底步骤](./USAGE.md#从-010-首次升级)。
- **Windows 原生接入**：PowerShell 环境执行 `powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1`。
- **Codex 全局 Loader**：可选执行 `bash /path/to/Team-Intelligence-Center/tools/install-codex-global.sh --dry-run` 预览，只安装全局发现入口和 `tic-*` 包装器。
- **OpenSpec 规格层**：参考 [组织研发范式 + OpenSpec / Superpowers 落地指南](./Design/development-paradigm-openspec-guide.md)，在业务项目中执行 `openspec init --tools codex,cursor,qoder,opencode --force`，让不同 AI 工具共用同一套 `/opsx:*` 规格驱动链路和规格事实源。
- **Superpowers 执行方法层**：在已启用 Superpowers 的 AI 工具中，用 brainstorming、planning、TDD、debugging、code review、subagent-driven development 等能力承接 OpenSpec tasks；OpenSpec 仍是规格事实源。
- **项目一键接入**：业务项目引入本仓库后，让 AI 执行 [project-governance-bootstrap](./Skills/project-governance-bootstrap.md)，自动补齐 `AGENTS.md`、`docs/ai-rules-usage.md`、`ai-harness/` 与 `openspec/` 基础入口，并自动检测/尽力安装 Superpowers；无法静默安装的工具会写入人工待办。
