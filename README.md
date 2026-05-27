# Team-Intelligence-Center 🧠
**(AI 研发团队智能协作中枢)**

> *消除「PM 觉得说清楚了，开发觉得没说清楚」的永恒矛盾，将散落在代码与人脑中的业务真正沉淀为系统资产。*

## 📖 项目简介

**Team-Intelligence-Center** 并非一个传统的业务应用程序，而是面向 AI 编程编辑器协作架构（如多角色 AI Agent）和工程团队（PM、前端、后端、QA、文档等）的**核心智能中枢引擎规范库**。

它提供了一整套标准化的协作角色边界、业务流转协议与结构化的 System Prompts。通过在工程项目中引入本项目定义的严格规则，可以有效约束 AI 行为，避免常见的大语言模型输出发散、代码偏好漂移以及跨角色信息失真，确保每一次需求交付与历史重构都严格遵守可追溯的工程底线。

## 🏗️ 核心资产目录说明

### 1. 🗂️ Global-Rules (全局协作基础干系规范)
包含接管项目核心流程的全局基建约束守则：
- **`coding-rules.md`**：除了标准化 Git Conventional Commits 的基本约束外，**核心定义了 AI Agent Team 多角色流转协议**；其内置了阶段控制（[PM] → [CI] → [BE/FE] → [QA] → [DS]），前端/后端文件域隔离防冲突机制、错误拦截及上下文（SESSION SNAPSHOT）恢复接力框架。

### 2. 📝 Prompts (产品级 AI 操作指令集)
提供适配不同工程场景下大语言模型的 Prompt 系统指令护栏库：
- **`ai-prd-generator.rules.md` (Universal Version - 新需求创造)**：AI-PRD 生成器规范。使得产品人员仅需自然语言表达交互诉求，AI 必须严格走 7 大维度结构化追问、自检与抗二义性测试，随后拆分出前端与后端真正可以执行理解的编码级任务清单，拒绝大端技术黑盒化。
- **`ai-prd-editor.rules.md` (Production Version - 存量重构梳理)**：AI-PRD 深度重构编辑器规范。这套规则重点处理无文档的老项目问题，限制 AI 的自我发挥（强制将反推信息评定可信度 S1~S4级别），强约束跨模型间的结构一致性（强制双层 Changelog 以防结构漂移），让庞大甚至腐化的系统重新长出“记忆”。

### 3. ⚡ Skills (可复用执行能力模块)
封装各角色在具体执行场景下的标准化操作方法论与输出模板，共 13 个 Skill：

| Skill 文件 | 服务角色 | 核心能力 |
|-----------|---------|--------|
| `code-investigator.md` | CI | 5 阶段代码调研方法论（目录扫描→技术栈→模块拆解→规则抽取→风险标记） |
| `api-contract-freezer.md` | PM | 接口契约冻结流程（定义模板→冻结声明→变更管理→版本控制） |
| `changelog-writer.md` | DS | 双层 Changelog 编写规范（全局总纲 + 版本详情，严格对齐 PRD Editor §11） |
| `prd-review-checklist.md` | QA | PRD 四维质量审查（完整性→无歧义→边界→可执行性，含 30+ 检查项） |
| `session-snapshot-manager.md` | PM | 会话快照生成与恢复标准化（6 强制字段 + 恢复检查清单 + 异常处理） |
| `candidate-rule-extractor.md` | CI/BE | 候选业务规则抽取（前后端扫描矩阵 + YAML 输出格式 + 生命周期管理） |
| `task-decomposer.md` | PM | 任务拆解方法论（三维拆解 + 依赖链标注 + 质量自检） |
| `conflict-arbiter.md` | PM | 共享文件仲裁流程（申请→四维评估→结论→记录，含 Hotfix 处理） |
| `fe-be-handoff.md` | FE/BE | 前后端交接标准化（FE/BE 交接清单模板 + Mock 方案 + 集成验证清单） |
| `project-governance-bootstrap.md` | PM/DS | 项目首次接入公司范式时，生成 AGENTS、AI 规则说明、ai-harness、OpenSpec 基础治理文件，并声明 Superpowers 协作边界 |
| `release-ops-handoff.md` | PM/Release Manager/DS | 单个功能或单个跨项目变更的运维发版、运营使用、QA 验收和反馈闭环交付卡 |
| `git-flow-operator.md` | PM/Release Manager | Git Flow 分支创建、release/hotfix 合并、tag、push 与回灌门禁 |
| `release-train-handoff.md` | PM/Release Manager/DS | 全量/多项目发版总控包、服务卡、数据库/脚本 manifest、冒烟、回滚与证据归档 |

### 4. 🧭 Design (落地范式与工具接入)
提供公司级研发范式、OpenSpec、Superpowers、Figma MCP 等跨项目落地指南：
- **`development-paradigm-openspec-guide.md`**：公司研发范式 + OpenSpec / Superpowers 落地指南。说明如何把本规则库、OpenSpec、Superpowers、Codex/Cursor/Qoder/OpenCode 和项目模板组合成统一开发链路。
- **`figma-mcp-skills-guide.md`**：Figma MCP + Skills 通用使用说明。说明设计读取、设计转代码、设计系统规则沉淀和 Code Connect 映射流程。

### 5. 🛠️ Automation (轻量自动化层)
提供最小可用的规则接入与自检工具，吸收自动化思想但不复制重流程包：
- **`manifest.json` / `VERSION`**：声明规则包版本、资产清单、安装产物与刻意排除项。
- **`templates/`**：项目侧最小入口模板，包括 `AGENTS.md`、`docs/ai-rules-usage.md`、`ai-harness/project-adapter.md`。
- **`tools/bootstrap-project.sh` / `tools/bootstrap-project.ps1`**：幂等接入业务项目，默认只合并最小规则入口、轻量 lock，并自动生成项目画像；不安装 Git hooks、不复制历史 PRD、不绑定 Codex-only。
- **`tools/codegraph-helper.sh` / `tools/codegraph-helper.ps1`**：可选 CodeGraph 上下文增强入口，帮助老项目和跨模块任务分析影响面；不默认安装或初始化。
- **`tools/git-advice.sh` / `tools/git-advice.ps1`**：只读 Git 副驾，输出分支和提交建议，不执行 Git 变更。
- **`tools/validate-pack.sh`**：校验规则包文件、版本、Skill 结构和轻量化约束。
- **`docs/automation.md`**：记录从 Codex_Project 吸收的有益机制，以及明确剔除的冗余部分。

自动化默认原则是 **SDD + TDD**：standard / critical 任务先明确行为规格，再从验收标准推导测试或验证；OpenSpec 可作为规格承载层，但不强制咨询和 micro 任务进入重流程。

## 🔄 核心工作流理念

本中枢要求任意系统开发迭代不仅生成代码，更强制遵循工程纪律上的阶段卡点推进：

1. **[PM] 任务拆解设计**：将自然语言提炼为任务清单清单及可被执行验证的验收标准 (Acceptance Criteria)。
2. **[CI] 代码基现状调研**：不带任何主观推测地盘点老代码现状并生成现状交接报告。
3. **[PM] API契约仲裁**：依据 CI 报告集中进行架构和契约决断。
4. **[FE/BE] 并行执行隔离**：依照已冻结的实体契约工作，不可违规操作共享配置文件，修改皆需上游审批。
5. **[QA] 测试准入验收**：核心流用例执行与边缘退回重测。
6. **[DS] 开发纪要归档**：演进纪实向主文档和流水 CHANGELOG 输出沉淀。

**📍 用户挂载点控制（Human-in-the-loop）**：在这套设计中，人类用户作为唯一的 **Product Owner**。所有不可逆的高危操作（如：信息冲突仲裁、系统大篇幅逻辑覆写、旧业务删除）皆埋设被动拦截锁，强制配置检查点 (**CP-1~CP-5**) ，必须获取用户确认后 AI 才可向下一环流转。

## 🚀 如何使用本智能中枢

> 📘 **完整使用指南请阅读 [USAGE.md](./USAGE.md)**，包含快速上手、各模块详细说明、工作流全景图、集成方式和 FAQ。

建议作为知识基座在团队协同工程中进行应用：
- **AI 提示词挂载**：直接将此仓库的规则复制到 AI 智能编辑器目录下的 `.rules` 或全局 System Prompt。由于其使用纯文本强制描述约束，所有 LLM 可直接无损耗接收并转入 Team Agent 模拟态投入全时工作。 
- **Submodule 规范基石**：将其作为 `git submodule` 集成在大型复杂工程库的独立存放点作为约束性资产规范，配合代码审批流长期守护项目全生命周期的产品需求与技术一致边界。
- **轻量自动化接入**：执行 `bash tools/bootstrap-project.sh --dry-run /path/to/project` 预览，再执行 `bash tools/bootstrap-project.sh --yes /path/to/project` 写入最小入口。
- **Windows 原生接入**：PowerShell 环境执行 `powershell -ExecutionPolicy Bypass -File tools\bootstrap-project.ps1 -Yes -ProjectRoot C:\path\to\project`。
- **OpenSpec 规格层**：参考 [公司研发范式 + OpenSpec / Superpowers 落地指南](./Design/development-paradigm-openspec-guide.md)，在业务项目中执行 `openspec init --tools codex,cursor,qoder,opencode --force`，让不同 AI 工具共用同一套 `/opsx:*` 规格驱动链路。
- **Superpowers 执行方法层**：在已启用 Superpowers 的 AI 工具中，用 brainstorming、planning、TDD、debugging、code review、subagent-driven development 等能力承接 OpenSpec tasks；OpenSpec 仍是规格事实源。
- **项目一键接入**：业务项目引入本仓库后，让 AI 执行 [project-governance-bootstrap](./Skills/project-governance-bootstrap.md)，自动补齐 `AGENTS.md`、`docs/ai-rules-usage.md`、`ai-harness/` 与 `openspec/` 基础入口，并自动检测/尽力安装 Superpowers；无法静默安装的工具会写入人工待办。
