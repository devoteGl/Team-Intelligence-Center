# Team-Intelligence-Center 轻量规则

本项目使用 Team-Intelligence-Center 作为轻量 AI 协作规则层。

规则来源：见下方“规则源解析”。本文件不得记录个人本机绝对路径。
规则版本：`{{TIC_VERSION}}`

## 规则源解析

AI 需要读取 TIC 正文规则或 Skills 时，按以下顺序定位规则源：

1. 若 `.tic-rules.lock` 中存在非空 `rules_path=`，按项目相对路径读取该目录。
2. 若 `rules_path=` 为空或不存在，则读取 `.tic-rules.local` 中的 `rules_dir=`；该文件只保存个人本机绝对路径，必须保持 gitignored。
3. 若仍未找到，使用开发者已安装的 Codex 全局 Loader 或人工指定的规则库路径作为兜底。

提交到仓库的 `AGENTS.md` 和 `.tic-rules.lock` 不应包含 `/Users/...`、`/home/...`、`C:\...` 等个人路径。

## 工作原则

- 简单任务保持简单。咨询、只读查询、代码解释、微小非行为改动，不走完整 PRD/SDD/Plan 流程。
- 默认使用 single adaptive workflow：先由 `tic-workflow-orchestrator` 判断 consulting / micro / standard / critical，再套用项目 `risk_floor`。强管控项目使用 `risk_floor=standard|critical`，不维护第二套 strict 流程。
- AI 应先做轻量 Intent Intake：识别目标、危险词、自治诉求、缺失信息、建议档位和确认方式。用户类型判断只影响解释粒度和追问方式，不降低检查点或高危动作确认要求。
- standard / critical 任务执行 SDD + TDD。先明确行为规格，再基于验收标准编写或更新测试，最后实现；SDD、TDD 证据、PRD 草稿、Walkthrough 和 Release Handoff 必须按 `ai-harness/project-adapter.md` 的归属与落盘根写入。
- SDD/TDD 是工作流阶段语义，不是独立工具链。项目已有 `openspec/`，或任务涉及跨模块、API、数据模型、长期产品行为时，OpenSpec 是规格事实源；Superpowers 是执行方法层。
- 按风险升级，而不是按关键词升级。支付、认证、数据迁移、生产配置、安全、删除、跨模块契约需要更严格处理。
- “全自动”“你看着办”“不用问我”只授权可逆低风险步骤；遇到删除、迁移、发版、push、merge、tag、生产配置或 PRD/OpenSpec 转正时仍必须暂停确认。
- 改代码前先读本项目上下文，优先复用现有模式、命令、测试和文档。
- 完成前必须验证。最终说明要写清楚跑了哪些命令、哪些通过、哪些未测、还有什么风险。
- 不编造业务事实。反推到的行为要标注可信度，候选规则确认前不得写成正式需求。
- 不覆盖人的工作。保留项目已有规则和用户未提交改动。
- 涉及创建分支、release/hotfix、merge、tag、push 或回灌时，必须执行 `Skills/git-flow-operator.md`。`feature/*` 使用业务名或 issue + 业务名；`release/*`、`hotfix/*` 和 tag 使用 `数字.数字.三位数字`，tag 不加 `v` 前缀。创建前必须输出候选分支、release owner、release registry root 和待执行命令，等待用户确认；release/hotfix 打 tag 后必须继续输出 `develop` 回灌状态、tag 落点、发版目录、命令和证据，不得把 tag 视为完成态。
- 涉及 API、共享类型、字段、枚举、错误码、权限点或 FE/BE 并行前，优先使用 `Skills/contract-handoff.md`；旧 `api-contract-freezer.md` 与 `fe-be-handoff.md` 仅作为兼容入口。
- 涉及共享文件域修改时，优先使用 `Skills/shared-domain-arbiter.md`；旧 `conflict-arbiter.md` 仅作为兼容入口。
- 如启用 subagent / multi-agent / 社区 agent，必须由 `tic-workflow-orchestrator` 先判断是否允许 fan-out；外部 agent 只能作为能力适配，必须遵守 TIC Agent Contract、文件 ownership、检查点和证据要求。禁止全量外部 agent 自由接管 standard / critical 任务。
- 如每个 agent 独立开会话，必须遵守 `Skills/agent-session-protocol.md` 或项目 `ai-harness/agent-session-protocol.md`：目录名给人看，`session_id` 只做追踪，通信通过结构化 artifact，冲突或越权时收敛回主 Agent。
- standard / critical 任务实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明或用户要求 walkthrough，应生成交付 Walkthrough。
- 需要发版、运维、运营、QA、回滚或上线观察交接时，优先使用 `Skills/release-handoff.md`；单变更使用 `mode=single`，多项目、多服务、SQL/脚本使用 `mode=train`。发版计划必须写清 release owner、release registry root、发布 tag、tag 目标 commit、远端 tag 状态、部署触发方式和 SDD/TDD/PRD 落盘状态。
- standard / critical 任务完成后，如涉及用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程变化，应自动生成 PRD 更新草稿和待确认项。

## CLI 输出压缩工具（可选）

rtk 等 CLI 输出压缩工具只用于降低长输出对 AI 上下文的污染，不是 TIC 工作流必需依赖。

- 未安装或项目未显式启用时，所有命令必须能按原生命令正常执行。
- 仅在只读、高噪音、幂等场景优先使用 rtk，例如 `rtk git status/log/diff`、`rtk grep/find/read`、测试 / lint / build 的摘要输出。
- 涉及 `git push/merge/cherry-pick/rebase/tag/reset`、Git Flow 发版、数据迁移、生产部署、回滚、破坏性操作或失败调试时，必须使用原生命令或保留 raw/proxy 原始输出。
- 关键证据以原生命令 exit code、stderr 和完整日志为准；rtk 摘要只能作为辅助阅读，不得替代审计底稿。
- 团队/公司环境启用 rtk 前必须确认 telemetry 已关闭，建议设置 `RTK_TELEMETRY_DISABLED=1`。

## 任务分级

| 档位 | 适用场景 | 处理要求 |
| --- | --- | --- |
| consulting | 解释、对比、只读 review、流程讨论 | 直接回答并给证据，不改文件。 |
| micro | 文案、注释、文档、微小非行为改动 | 做窄改动，跑最小有意义验证。 |
| standard | 新功能、行为变化、API/UI 契约、跨模块改动 | 写或更新 SDD，从验收标准推导 TDD 测试，实现后验证。 |
| critical | 支付、认证、安全、生产配置、破坏性迁移、数据丢失风险 | 需要明确人工确认、SDD + TDD 证据、回滚思路、更强验证和清晰发版说明。 |

`risk_floor` 可由 `.tic-rules.lock`、`ai-harness/project-adapter.md` 或用户明确要求提供。AI 不得把任务降级到 floor 以下。

## SDD + TDD 原则

- SDD 定义目标行为、范围、不做什么、验收标准和边界场景。
- TDD 把 SDD 的验收标准转成失败测试或明确验证项，再进入实现。
- 实现必须能追溯到 SDD 和测试。
- 已有 `openspec/` 时，SDD 优先关联或写入 `openspec/changes/<change-id>/`；没有 OpenSpec 时使用 `docs/sdd/<change-id>.md` 或项目约定位置。
- TDD 证据索引默认写入 `docs/test-evidence/<change-id>/README.md`，具体测试代码仍放在项目测试目录。
- OpenSpec 可以作为 SDD 语义的存储和生命周期承载方式，但 consulting 和 micro 任务不强制使用 OpenSpec。
- 不新增绕过 OpenSpec / Superpowers 的独立 SDD/TDD Skill 链。
- 不把未确认的代码反推当成既定业务事实；老项目反推规则要使用可信度标签和候选规则机制。

## UI 验证规则

涉及 UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归的变更时，AI 应优先核对真实界面。

- UI 相关改动必须使用 `design-taste-frontend` 与 `ui-ux-pro-max`。若 `design-taste-frontend` 明确判定场景不适用（如密集后台、数据表或多步骤产品 UI），仍需记录该判断，并按项目设计系统与 `ui-ux-pro-max` 执行。
- 本地应用可运行时，优先使用 Playwright、浏览器截图、Computer Use 或 Chrome 打开页面并核对。
- 需要端到端验证功能、真实点击输入、登录、桌面 App、用户本机状态、真实浏览器插件或账号态时，优先使用 `@电脑`（`plugin://computer-use@openai-bundled` / Computer Use）辅助验证；不可用时说明原因，再用 Playwright、Browser 或 Chrome 替代。
- 核对重点：页面是否可打开、核心流程是否可操作、样式是否错位、桌面/移动端是否异常、控制台是否有关键错误。
- micro 级纯文案或无行为样式微调，可只做最小截图、局部检查或说明级验证。
- 无法运行或自动核对界面时，最终报告必须说明原因、替代验证内容和剩余 UI 风险。

## 开发后 PRD 同步

- 触发条件：开发完成、验收通过、发版前整理，或本次变更影响用户可见行为、UI、API、数据模型、状态流转、业务规则、运营流程。
- 默认动作：执行 `Skills/post-dev-prd-sync.md`，基于 OpenSpec / SDD、git diff、测试、UI 验证、API 契约等证据生成 PRD 更新草稿。
- PRD 草稿默认写入 `docs/PRD/drafts/<change-id>-prd-update.md`，正式 PRD 默认归 `docs/PRD/` 或项目声明位置；多项目变更只能有一个主归属，其他项目作为引用或子项。
- 不触发场景：纯重构、格式化、注释、测试补充、内部实现优化且无行为变化。
- 草稿不得自动转正。S2/S3 代码反推和推测内容必须进入候选规则或待确认项，人工确认后才能同步到正式 PRD / OpenSpec specs。

## 交付 Walkthrough

- 触发条件：实现完成、准备异步 review、QA/PM 需要快速理解交付内容、UI/浏览器任务有截图或录屏证据、脚本/工具需要使用说明，或用户明确要求“walkthrough / 交付走查 / 交付说明”。
- 默认动作：执行 `Skills/delivery-walkthrough.md`，基于需求来源、git diff、改动文件、测试/构建、UI 截图/录屏、接口契约和人工确认生成可审阅交付 artifact。
- 输出重点：交付摘要、用户可见变化、技术走查、变更文件与影响面、验证证据、Review 指引、未测项、剩余风险和后续动作。
- 边界：Walkthrough 不替代开工前计划、正式 PRD、Changelog 或发版 runbook；需要上线交接时继续执行发版交接技能。

## 推荐使用的 TIC 资产

- 全局行为规则：`Global-Rules/coding-rules.md`
- 新需求生成：`Prompts/ai-prd-generator.rules.md`
- 老项目补文档：`Prompts/ai-prd-editor.rules.md`
- 开发后 PRD 同步：`Skills/post-dev-prd-sync.md`
- 交付走查：`Skills/delivery-walkthrough.md`
- 工作流总控：`Skills/tic-workflow-orchestrator.md`
- OpenSpec / Superpowers 接合：`Design/development-paradigm-openspec-guide.md`
- 代码调研：`Skills/code-investigator.md`
- 任务拆解：`Skills/task-decomposer.md`
- Git Flow 分支操作：`Skills/git-flow-operator.md`
- 契约冻结与交接：`Skills/contract-handoff.md`
- 共享域仲裁：`Skills/shared-domain-arbiter.md`
- Agent 会话协议：`Skills/agent-session-protocol.md`
- 发版交接：`Skills/release-handoff.md`

默认从规则来源目录读取这些 Skills，不自动复制到项目本地 skills 或全局 skills。只有团队明确维护镜像时，才做显式同步。

## 完成报告

涉及代码或文档改动时，最终报告应包含：

- 修改了哪些文件。
- 做了哪些简化或关键决策。
- 执行了哪些验证命令和结果。
- 未覆盖的验证和剩余风险。
