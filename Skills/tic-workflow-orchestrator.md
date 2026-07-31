---
schema: tic_skill.v1
id: tic-workflow-orchestrator
status: canonical
phase: orchestration
role: PM / Tech Lead
risk_min: consulting
inputs:
  - user_task
  - project_rules
  - optional_risk_floor
outputs:
  - workflow_plan_card
  - selected_skill_dag
  - checkpoint_list
requires: []
delegates_to:
  - task-decomposer
  - code-investigator
  - project-adapter-maintainer
  - contract-handoff
  - shared-domain-arbiter
  - agent-session-protocol
  - e2e-verification
  - delivery-walkthrough
  - release-handoff
  - post-dev-prd-sync
  - changelog-writer
---

# TIC Workflow Orchestrator（AI 研发工作流总控技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Workflow Router**
- 触发时机：用户希望按 TIC 研发范式处理需求、Bug、重构、发版、文档归档，或项目已接入 TIC 且任务达到 standard / critical 风险档
- 输出物：工作流计划卡、风险分级、Skill DAG、检查点、产物清单、跳过项说明
- 适用场景：统一路由 TIC Skills、OpenSpec、Superpowers 和项目验证/归档链路

---

## 0. 核心原则

本技能是**路由器**，不是巨型执行技能。

必须做到：
- **Capability First, Governance on Risk**：默认释放 AI 能力，只在风险触发时升级门禁和证据要求。
- **只路由，不复制**：不得复制子 Skill 的正文模板、检查表或写作规则。
- **单一 adaptive 工作流**：不维护第二套 strict 流程；强管控通过 `risk_floor` 实现。
- **OpenSpec 是规格事实源，Superpowers 是执行方法层**：本技能只决定何时需要规格、证据、确认和归档。
- **产物归属先行**：standard / critical 任务必须识别 SDD、TDD 证据、PRD 草稿、Walkthrough 和 Release Handoff 的归属节点与落盘根，不能按当前 shell 目录随意写入。
- **项目事实保护**：`project-adapter.md` 缺失、陈旧、schema 变化或疑似被覆盖时，路由到 `project-adapter-maintainer`；不得用 bootstrap 模板整文件覆盖完成迁移。
- **E2E 按风险触发**：standard / critical 任务先判断端到端验证必要性；改变用户旅程、跨层交互或关键链路时路由到 `e2e-verification`，不为所有 micro 任务强制完整 E2E。
- **TIC Agent Contract 是协作底座**：社区 agent、工具原生 subagent 和外部编排器只能作为能力适配，不得替代 TIC 角色、检查点和证据链。
- **Agent Session Protocol 按协作边界触发**：同一 Codex 任务内的原生 subagent 可使用宿主线程；跨任务、跨工具、长时异步或审计场景通过 artifact 协作，`session_id` 只做追踪，不做事实源。
- **可解释跳过**：输出 standard / critical 计划卡时，对原本可能触发但被跳过的关键 Skill 说明原因；consulting / micro 不列冗长的全量跳过清单。

绝对禁止：
- 把 `task-decomposer`、`code-investigator`、`delivery-walkthrough` 等子 Skill 的模板正文内联到本技能。
- 为 micro / consulting 任务强制完整 PRD、OpenSpec、Walkthrough 或 release handoff。
- 让 Superpowers 临时产物成为稳定规格事实源。
- 让社区 agent 库、工具原生 orchestrator 或“一句话自治”入口绕过 `tic-workflow-orchestrator`。
- 绕过用户确认执行分支创建、tag、push、合并、高风险删除、不可逆迁移或生产配置修改。

---

## 1. 工作流模型

TIC 只维护一套 adaptive workflow：

```text
workflow = adaptive
risk_floor = none | standard | critical
effective_tier = max(classified_tier, risk_floor)
```

`strict` 仅作为兼容别名：`strict` 等价于 `risk_floor = critical`，不得维护单独流程。

### 1.1 风险档位

| 档位 | 使用场景 | 默认流程 |
| --- | --- | --- |
| consulting | 咨询、解释、方案比较、只读分析 | 直接回答或轻量调查 |
| micro | 小文案、局部样式、小 Bug、低风险单文件改动 | 最小实现 + 最小验证 |
| standard | 用户可见行为、多文件变更、正常功能、接口消费、重要文档 | SDD/TDD 或等价验收驱动流程 |
| critical | 权限、资金、生产数据、删除、迁移、跨端契约、跨服务发版、不可逆操作 | 完整证据链 + 人工确认 + 归档 |

### 1.2 自动升级信号

出现以下任一信号时，至少升级到 `standard`：
- 用户可见行为、UI 流程、API、数据模型、状态流转、业务规则变化。
- 影响多个文件、多个端、多个模块或共享文件域。
- 需要测试、构建、联调、截图或人工验收才能证明完成。

出现以下任一信号时，升级到 `critical`：
- 权限、资金、隐私、生产数据、数据库迁移、回滚困难。
- 删除用户数据、公共行为或难恢复历史，大规模重构、跨服务发版、第三方回调、生产配置。
- 用户明确要求“大版本”“发版”“上线交接”“严格管控”。

分级不使用乘法复杂度分。普通接口、类型或登录页面的局部改动不因关键词自动成为 critical；应结合破坏性、影响面、可恢复性、外部副作用和验证成本判断。

### 1.3 Intent Intake 与受控 Fan-out

Intake 先把用户原话归一化为：
- 目标：用户真正要达成的结果。
- 危险词：全自动、顺便、重构、删除、上线、迁移、清空、登录、支付、权限等。
- 自治诉求：用户希望 AI 自主到什么程度。
- 缺失信息：影响风险分级、范围、验收或不可逆动作授权的信息。
- 产物归属：`artifact_owner_type`、`artifact_owner_id`、SDD/TDD/PRD/Release 的落盘根；无法确认时标为待确认。
- 建议档位与确认方式：consulting / micro / standard / critical，以及是否需要 CP。

用户类型判断只影响解释粒度和追问方式，不降低安全边界。流程熟练用户可少解释、快执行；流程不熟或表达模糊用户要把目标、范围和风险翻译清楚。“全自动”授权范围内可逆本地步骤和非破坏性验证，不授权外部写入、不可逆迁移、生产变更、数据删除、发布或 PRD/OpenSpec 转正。

多 Agent 是执行层 fan-out 策略，不是独立工作流。总控只判断是否允许 fan-out，并输出理由、任务边界、文件 ownership 和收口责任。
Fan-out 准入：子任务可独立验证；API/字段/错误码/FE-BE 并行已完成 `contract-handoff`；共享域写入已完成 `shared-domain-arbiter`；子 agent 不执行 Git Flow、发版、迁移、生产动作或未授权的破坏性操作。
默认策略：consulting / micro 不启用写入型 fan-out；standard 可受控 fan-out；critical 启用前必须确认边界和风险。

同一 Codex 任务内的原生 subagent 默认使用宿主线程、权限继承和主 Agent 汇总，不强制创建 `.tic/agent-runs/`。

如 agent 跨独立任务、跨工具、跨设备或长时间异步运行，或者团队要求长期审计，必须启用 `agent-session-protocol`：run 目录使用“时间 + 任务短标题”，agent 目录使用“序号 + 中文角色 + 本次职责”；`run_id`、`agent_id`、`session_id` 写入 manifest/status。总控只读取结构化 outbox 和 evidence。出现契约冲突、越权请求、范围漂移或重复阻塞时，立即停止 fan-out 并收敛回主 Agent。

---

## 2. Phase 路由

| Phase | 目标 | 默认 Skill | Fan-out |
| --- | --- | --- | --- |
| Intake | 识别任务、风险、规则源、risk floor | `tic-workflow-orchestrator` | 否 |
| Discovery | 调研现状、影响面、候选规则、风险；维护项目 adapter | `code-investigator`、`project-adapter-maintainer`（按需） | 条件可，只读优先 |
| Planning | 拆任务、规格、验收、契约 | `task-decomposer`、OpenSpec/SDD、`contract-handoff` | 否，方案可多视角评审 |
| Execution | 实现、并行开发、共享域仲裁 | 具体工程技能、Superpowers、`shared-domain-arbiter` | 条件可，需契约和文件域边界 |
| Verification | 测试、构建、lint、联调、E2E、UI/接口证据 | 项目命令、Superpowers TDD/debug/review、`e2e-verification`（按风险） | 条件可，主 Agent 收口 |
| Closeout | 交付走查、PRD 草稿、Changelog | `delivery-walkthrough`、`post-dev-prd-sync`、`changelog-writer` | 否，主 Agent 收口 |
| Release | 运维/运营/QA 发版交接 | `release-handoff` | 否 |

项目显式启用 rtk 等 CLI 输出压缩工具时，Verification 可在只读、高噪音、幂等命令中使用摘要输出提升阅读效率。Git Flow、发版、迁移、破坏性操作、生产命令、失败调试和 critical 证据必须保留原生命令或 raw 输出。

---

## 3. 各档位模板

### consulting

```text
Intake -> Answer
```

要求：
- 不强制创建 OpenSpec change。
- 不强制输出 SESSION SNAPSHOT，除非用户要求跨会话接力。

### micro

```text
Intake -> Execution -> Verification -> Short Closeout
```

要求：
- 使用最小验证。
- 只在用户可见行为变化或证据需要异步 review 时生成轻量 Walkthrough。

### standard

```text
Intake -> Planning -> Discovery(按需) -> Contract(按需)
  -> Execution -> Verification -> Closeout(按需)
```

要求：
- 必须有可执行验收标准。
- 建议 SDD + TDD；有 OpenSpec change 时引用 change id。
- 必须记录 SDD 落盘位置和 TDD 证据位置；已有 OpenSpec 时优先写入或关联 `openspec/changes/<change-id>/`，否则使用 `docs/sdd/<change-id>.md` 或项目约定位置。
- 必须判断 E2E 是 `not-required`、`targeted` 还是 `required`；改变用户旅程、跨层交互或关键 API 流程时触发 `e2e-verification`。
- API、FE/BE、共享类型或跨端字段变化时必须触发 `contract-handoff`。
- 用户可见行为变化时触发 `post-dev-prd-sync` 草稿。

### critical

```text
Intake -> Discovery -> OpenSpec/SDD -> Contract-Handoff
  -> Execution with TDD -> Verification with evidence
  -> Delivery Walkthrough -> Release Handoff(按需)
  -> PRD Sync -> Changelog
```

要求：
- 必须记录人工确认点和回滚/补救思路。
- 必须暴露未测项、剩余风险和证据缺口。
- 认证、权限、资金、隐私、迁移或跨服务关键链路使用 E2E gate；`blocked`、`partial` 或 `waived` 必须记录责任人和剩余风险。
- 必须记录 PRD 草稿、SDD、TDD 证据和发版交接包的归属节点；多项目任务只能有一个主归属，其他项目作为引用或子项。
- 涉及发版、SQL、脚本、运营使用或上线观察时触发 `release-handoff`。

---

## 4. 输出格式

standard / critical 任务，或者用户要求计划、任务存在关键歧义时，输出工作流计划卡。consulting / micro 可在一句话内说明分级和处理方式，不强制展开完整表格。

```markdown
## TIC Workflow Plan

- Task: <用户任务摘要>
- Classified tier: consulting / micro / standard / critical
- Risk floor: none / standard / critical
- Effective tier: consulting / micro / standard / critical
- Reason: <分级依据>
- Intent intake: <目标 / 危险词 / 自治诉求 / 缺失信息 / 确认方式>
- User handling: concise / guided / confirm-first
- Artifact owner: <workspace / project / subproject / external + owner id>
- Artifact / release roots: <sdd_root / tdd_evidence_root / prd_root / prd_draft_root / release_registry_root>

### Phases
| 顺序 | Phase | Skill / Method | Required artifact | Checkpoint |
| --- | --- | --- | --- | --- |
| 1 | Intake | tic-workflow-orchestrator | plan card | 按风险触发 |

### Skipped
| Skill | Reason |
| --- | --- |
| release-handoff | 本次不涉及发版、运维或运营交接 |

### Superpowers / OpenSpec 接合
- OpenSpec change: required / optional / not required
- Superpowers: planning / TDD / debugging / review / subagent / not required
- Fan-out mode: disabled / read-only review / controlled execution
- Agent session artifact: native-thread / not required / .tic/agent-runs/<run-dir>
- E2E verification: not-required / targeted / required / required-gate + evidence root
```

---

## 5. 与 Superpowers 的边界

TIC Orchestrator 决定“是否需要规格、证据、门禁和归档”；Superpowers 决定“如何把实现做扎实”。

推荐接合：
- 需求仍模糊：使用 Superpowers brainstorming，结论写回 proposal 或 PRD。
- 已有 OpenSpec tasks：使用 Superpowers writing-plans。
- 实现阶段：使用 Superpowers TDD、debugging、code review、subagent-driven development。
- 有 OpenSpec change 时，Superpowers 产物必须引用 change id 或明确任务来源。

---

## 6. 自检

输出计划卡前检查：
- [ ] 是否只做路由，没有复制子 Skill 正文。
- [ ] 是否应用 `risk_floor`。
- [ ] 是否完成 Intent Intake，区分“用户原话”和“用户授权”。
- [ ] 是否说明跳过项。
- [ ] 是否识别 OpenSpec / Superpowers 接合点。
- [ ] 如启用 fan-out / 社区 agent，是否冻结契约、分配文件域、保留主 Agent 收口责任。
- [ ] 如启用独立 agent 会话，是否使用 `agent-session-protocol` 落盘 manifest、outbox、status 和证据。
- [ ] 是否按验收标准和风险判断 E2E 必要性，并在触发时路由到 `e2e-verification`。
- [ ] 是否区分事实、推断、待确认。
- [ ] 是否保留 AI 在实现、工具选择和调试路径上的合理自主权。
