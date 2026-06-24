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
  - contract-handoff
  - shared-domain-arbiter
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
- **可解释跳过**：每个未触发的 Skill 必须说明跳过原因，避免“看起来漏了”。

绝对禁止：
- 把 `task-decomposer`、`code-investigator`、`delivery-walkthrough` 等子 Skill 的模板正文内联到本技能。
- 为 micro / consulting 任务强制完整 PRD、OpenSpec、Walkthrough 或 release handoff。
- 让 Superpowers 临时产物成为稳定规格事实源。
- 绕过用户确认执行分支创建、tag、push、合并、删除、迁移或生产配置修改。

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
- 删除旧逻辑、大规模重构、跨服务发版、第三方回调、生产配置。
- 用户明确要求“大版本”“发版”“上线交接”“严格管控”。

---

## 2. Phase 路由

| Phase | 目标 | 默认 Skill |
| --- | --- | --- |
| Intake | 识别任务、风险、规则源、risk floor | `tic-workflow-orchestrator` |
| Discovery | 调研现状、影响面、候选规则、风险 | `code-investigator` |
| Planning | 拆任务、规格、验收、契约 | `task-decomposer`、OpenSpec/SDD、`contract-handoff` |
| Execution | 实现、并行开发、共享域仲裁 | 具体工程技能、Superpowers、`shared-domain-arbiter` |
| Verification | 测试、构建、lint、联调、UI/接口证据 | 项目命令、Superpowers TDD/debug/review |
| Closeout | 交付走查、PRD 草稿、Changelog | `delivery-walkthrough`、`post-dev-prd-sync`、`changelog-writer` |
| Release | 运维/运营/QA 发版交接 | `release-handoff` |

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
- 涉及发版、SQL、脚本、运营使用或上线观察时触发 `release-handoff`。

---

## 4. 输出格式

总控必须先输出工作流计划卡：

```markdown
## TIC Workflow Plan

- Task: <用户任务摘要>
- Classified tier: consulting / micro / standard / critical
- Risk floor: none / standard / critical
- Effective tier: consulting / micro / standard / critical
- Reason: <分级依据>

### Phases
| 顺序 | Phase | Skill / Method | Required artifact | Checkpoint |
| --- | --- | --- | --- | --- |
| 1 | Intake | tic-workflow-orchestrator | plan card | CP-1 |

### Skipped
| Skill | Reason |
| --- | --- |
| release-handoff | 本次不涉及发版、运维或运营交接 |

### Superpowers / OpenSpec 接合
- OpenSpec change: required / optional / not required
- Superpowers: planning / TDD / debugging / review / subagent / not required
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
- [ ] 是否说明跳过项。
- [ ] 是否识别 OpenSpec / Superpowers 接合点。
- [ ] 是否区分事实、推断、待确认。
- [ ] 是否保留 AI 在实现、工具选择和调试路径上的合理自主权。
