# AI 规则使用说明

本项目已用轻量模式接入 Team-Intelligence-Center。

## 已安装内容

- `AGENTS.md`：项目级 AI 协作入口。
- `.tic-rules.lock`：轻量安装元信息，用于诊断当前接入的规则版本。
- `docs/ai-rules-usage.md`：本说明文件。
- `.cursorrules`：Cursor 项目规则入口，指向 `AGENTS.md`。
- `.windsurfrules`：Windsurf 项目规则入口，指向 `AGENTS.md`。
- `.rules/team-intelligence-center.md`：支持 `.rules/` 目录的 AI 工具入口，指向 `AGENTS.md`。
- `ai-harness/project-adapter.md`：项目维护的命令、模块、归属、发布策略和风险边界事实；普通安装与升级不会覆盖。

## 如何与 AI 协作

先用自然语言描述任务。AI 应按风险分级处理：

- consulting / 只读任务：直接回答，不改文件。
- micro 任务：保持改动很窄，并执行最小验证。
- standard 任务：使用相关 TIC 技能，明确规格，并从验收标准推导自动测试或可观察验证。
- critical 任务：需要明确人工确认、回滚思路和更强验证。

不懂流程也可以只说目标。AI 会先做轻量 Intent Intake，识别目标、自治诉求、缺失信息、风险信号、建议档位和确认方式。用户说“全自动”“你看着办”“不用问我”时，AI 可自主推进范围内可逆本地步骤和非破坏性验证；外部写入、不可逆迁移、生产变更、数据删除、发布或 PRD/OpenSpec 转正仍需明确确认。

默认入口是 single adaptive workflow：`tic-workflow-orchestrator` 先判断 consulting / micro / standard / critical，再应用项目 `risk_floor`。如果项目配置 `risk_floor=standard|critical`，AI 不得自行降级到该档位以下。

规格与验证是工作流语义，不是独立 SDD/TDD Skill 链。项目已有 OpenSpec 时，OpenSpec 是规格事实源；执行方法层负责计划、TDD、调试和 review。E2E 是 Verification phase 的条件门禁：standard / critical 任务先判断必要性，改变用户旅程、跨层交互或关键链路时执行 `e2e-verification`。规格、验证证据、PRD 草稿、Walkthrough 和 Release Handoff 的归属与落盘根以 `ai-harness/project-adapter.md` 为准。

需要创建、补全、审计、迁移或修复 `project-adapter.md` 时，使用 `project-adapter-maintainer`。已有非占位内容、自定义章节和本地决策默认保留；自动探测只提供候选事实，不得在升级时静默覆盖。

涉及 API、共享类型、字段、枚举、错误码、权限点或 FE/BE 并行前，优先使用 `contract-handoff`。涉及共享文件域修改时，优先使用 `shared-domain-arbiter`。需要发版、运维、运营、QA、回滚或上线观察交接时，优先使用 `release-handoff(mode=single|train)`；发版计划必须写清 release owner、release registry root、发布 tag、tag 目标 commit、远端 tag 状态、部署触发方式和 SDD/TDD/PRD 落盘状态。

创建任何 `feature/*`、`release/*`、`hotfix/*` 分支前，AI 必须先解析项目的 branch/version/tag 策略，执行或要求执行 `git fetch --all --prune --tags`，再检查本地/远端同名分支和基线分支新鲜度。默认版本格式是 SemVer，tag 前缀保留项目既有风格。`tools/git-advice.*` 是只读建议脚本，不主动 fetch；它的版本和 tag 建议不能替代 Git 确认卡。

如项目启用 subagent / multi-agent / 社区 agent，TIC 角色仍是协作合同。外部 agent 只能作为专业能力适配，必须由 `tic-workflow-orchestrator` 决定是否 fan-out，并遵守契约冻结、共享域仲裁、文件 ownership、检查点和交付证据要求。不建议全量安装外部 agent 库后由模型自由选择角色处理 standard / critical 任务。

同一 Codex 任务内的原生 subagent 使用宿主线程并由主 Agent 收口，不强制落盘运行态文件。跨独立任务、跨工具、长时异步或需要审计时使用 `agent-session-protocol`。项目侧入口是 `ai-harness/agent-session-protocol.md`，运行态目录建议为 `.tic/agent-runs/YYYYMMDD-HHMM-任务短标题/`。

UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归相关变更，应使用当前环境可用的设计与 UI/UX 专业能力，并优先核对真实界面。安装了 `design-taste-frontend` 与 `ui-ux-pro-max` 时优先使用；能力不可用时说明替代依据。需要端到端真实操作时优先使用当前环境可用的 Computer Use、浏览器自动化或截图验证。

E2E 验证优先复用项目原生可重复套件。项目未指定 runner 且 Web 变更需要新增可重复套件时，Playwright Test 是默认候选；Playwright MCP、Browser、Chrome、Computer Use、截图和 trace 用于探索、调试或可观察证据。环境、认证、数据、清理、核心旅程和证据根从 `project-adapter.md` 的 `verification.e2e` 读取；认证状态保持本地并 gitignored，只清理本次验证拥有的数据。

standard / critical 任务实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明，或你明确要求“walkthrough / 交付走查”，AI 应生成交付 Walkthrough。它应说明交付摘要、用户可见变化、技术走查、变更文件、验证证据、Review 指引、未测项、风险和后续动作。

standard / critical 任务完成后，如影响用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程，AI 应生成 PRD 更新草稿和待确认项。草稿必须基于证据，不自动转正为正式 PRD。多项目变更只能有一个 PRD 主归属，其他项目作为引用或子项。

## 规则来源

本项目不在可提交文件中记录个人本机绝对路径。AI 读取 TIC 正文规则或 Skills 时，应优先使用 `.tic-rules.lock` 中的非空项目相对 `rules_path`；若 `rules_path` 为空或项目未内置规则库，则读取 `.tic-rules.local` 中的个人本机 `rules_dir`。

`.tic-rules.local` 由安装脚本生成，只用于当前开发者机器，必须保持 gitignored。

请把源规则库作为稳定知识基座。除非团队明确决定，不要把大型流程包、vendor 资产或历史 PRD 档案复制进业务项目。

Skills 默认从解析出的规则源读取，不自动差量复制到项目本地 skills 或开发者全局 skills，避免版本漂移和覆盖个人配置。`api-contract-freezer`、`fe-be-handoff`、`conflict-arbiter`、`release-ops-handoff`、`release-train-handoff` 等旧入口保留兼容，但新任务优先使用 canonical 技能。
