---
schema: tic_capability.v1
id: tic-workflow-orchestrator
status: compatibility
category: planning
activation:
  when:
    - 用户明确要求 workflow 治理审计或复杂受保护操作的决策摘要
  not_when:
    - 普通任务可以在授权范围内直接调查、修改和验证
side_effects: none
artifacts:
  default: workflow-decision-summary
  when_needed:
    - 用户或审计方需要可引用的五维决策说明
requires: []
related:
  - task-decomposer
  - prd-author
  - prd-review-checklist
  - contract-handoff
  - e2e-verification
  - release-handoff
  - project-adapter-maintainer
---

# TIC Workflow Orchestrator（显式治理审计兼容能力）

## 技能用途

本能力不是普通任务入口。它只在用户明确要求时，读取 `Workflow/core.md`，
把已经存在的任务事实整理为决策摘要；不得指挥 Agent 的逐步执行。

## 决策摘要

```yaml
workflow_decision:
  contract:
    outcome: ""
    boundaries: []
    done: []
    verification: []
    authority:
      autonomous: []
      confirmation_required: []
  product_baseline:
    status: not-required | missing | draft | confirmed | superseded
    owner: ""
    source: ""
  decisions:
    planning_depth: inline | brief | living
    execution_authority: autonomous | confirmation-required
    verification_scope: targeted | integration | e2e | operational
    review_level: self | independent | user-decision
    fact_persistence: task-context | openspec | prd | runbook | release-record | local-candidate
  capabilities: []
  unresolved: []
```

五个维度必须分别给出事实依据。不得从文件数、技术关键词、预计耗时或某个
外部 Skill 的总控声明推导整个任务的统一等级。

新产品、业务域或重大用户旅程还要判断产品基线。缺少已确认基线且持久实现会
冻结产品行为时，允许调查、原型和可逆技术探针；正式实现保持未授权，直到有权
owner 确认用户、结果、主旅程、范围、非目标和验收。

## Capability 选择

只有用户明确要求、事实满足 `activation.when`，或缺少该能力会使已授权任务
无法安全正确完成时才选择。`related` 不授权调用，Capability 之间没有默认
顺序。

Superpowers 等外部方法只在具体方法有独立增益时选择；不得生成
brainstorm → plan → TDD → subagent → review → verification 的固定链。
OpenSpec 只在 `fact_persistence=openspec` 且存在长期消费者时使用。

## 暂停边界

只在以下情况暂停：

- 产品结果存在无法从事实消解的重大分歧；
- 当前准备执行的动作是外部、不可逆、生产、迁移、权限、资金、隐私、
  Git 状态变更或正式发布；
- 草稿将转为正式规格、规则或共享记忆；
- 失败补救需要扩大授权范围。

暂停只保护具体动作，安全调查、方案准备和本地验证继续推进。

## 旧版迁移

旧词只能作为迁移输入，不得映射成新的综合等级：

- `consulting` / `micro`：重新分别判断五个维度；
- `standard`：不能自动要求计划、OpenSpec、E2E 或 Review；
- `critical`：识别其中真正需要确认的具体动作，其余维度独立判断；
- `direct` / `structured` / `guarded`：拆解为规划、授权、验证、Review 和
  持久化事实后弃用。

## 完成检查

- [ ] 是否读取 `Workflow/core.md`。
- [ ] 是否使用五字段任务契约。
- [ ] 新产品是否记录产品基线状态、owner 和事实源。
- [ ] 五个维度是否分别有事实依据。
- [ ] 是否没有固定阶段或 Skill 调用链。
- [ ] 每个额外 artifact 是否有消费者和唯一事实源。
- [ ] 是否只暂停需要确认的具体动作。
