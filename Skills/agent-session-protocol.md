---
schema: tic_capability.v1
id: agent-session-protocol
status: canonical
category: coordination
activation:
  when:
    - Agent 协作跨独立任务、跨工具、长时异步或需要审计
  not_when:
    - 同一任务内的原生 subagent 可由宿主线程可靠承载
side_effects: local-reversible
artifacts:
  default: agent-session-artifacts
  when_needed:
    - 跨会话执行需要 manifest、inbox、outbox、status 和证据
requires: []
related:
  - contract-handoff
  - shared-domain-arbiter
  - delivery-walkthrough
---

# Agent Session Protocol（多 Agent 会话产物协议）

## 技能用途

- 服务角色：**PM / Tech Lead / Workflow Coordinator**
- 触发时机：Agent 协作跨独立任务、跨工具、长时异步或需要审计
- 输出物：agent run 目录、manifest、inbox/outbox、status、证据索引和收敛记录
- 适用场景：把多会话执行变成可读、可审计、可收敛的执行层 fan-out

---

## 0. 核心原则

- 主 Agent 负责最终收口；本协议只管理需要持久化的 agent 会话产物。
- 同一 Codex 任务内的原生 subagent 默认使用宿主线程、权限和主 Agent 汇总，不强制创建本协议文件。
- 目录名给人看，`run_id` / `agent_id` / `session_id` 给机器追踪。
- `session_id` 只作为追踪字段，不是事实源；事实源是落盘 artifact。
- agent 之间不得自由群聊；通信经过主 Agent 或 mailbox artifact。
- 不保存推理链路；只保存任务、摘要、证据、风险、待决策和状态。
- 发现冲突、越权、范围漂移或重复阻塞时，必须收敛回主 Agent。

绝对禁止：
- 用独立会话绕过任务边界、受保护动作确认、必要契约或 ownership 仲裁。
- 让子 agent 执行 Git Flow、发版、push、merge、tag、删除、迁移或生产配置。
- 把 agent outbox 直接当最终结论；最终收口必须由主 Agent 完成。

---

## 1. 准入条件

只有满足以下条件时，才建议启用 agent session protocol：
- 子任务能独立验证，且协作跨越当前宿主可可靠保存的原生线程边界。
- fan-out 边界已写清：任务、角色、可读域、可写域、禁止动作和证据要求。
- 多个消费者共享契约时，已明确是否需要 `contract-handoff`。
- 多个执行者存在共享域 ownership 冲突时，已明确是否需要 `shared-domain-arbiter`。
- 用户需要异步 review、跨任务接力、跨工具协作、长时任务观察或多 agent 证据归档。

同一 Codex 任务内的原生 subagent 不因任务规模或技术风险本身启用本协议；
主 Agent 应直接收口其结果并运行最终验证。

---

## 2. 目录结构

推荐在项目根创建可审计运行态目录：

```text
.tic/agent-runs/
  INDEX.md
  CURRENT.md
  20260630-1405-直播间商品同步问题/
    README.md
    manifest.json
    decisions.md
    evidence/
    agents/
      01-产品经理-需求收敛/
        inbox.md
        outbox.md
        status.json
      02-后端架构-接口排查/
        inbox.md
        outbox.md
        status.json
      03-测试-证据收集/
        inbox.md
        outbox.md
        status.json
```

命名规则：
- run 目录：`YYYYMMDD-HHMM-任务短标题`，短标题使用业务语言，便于用户查找。
- agent 目录：`序号-中文角色-本次职责`，避免只暴露抽象 id。
- `manifest.json` 记录 `run_id`、`agent_id`、`session_id`、契约引用和状态机。
- `INDEX.md` 记录历史 run；`CURRENT.md` 指向当前活跃 run。

`.tic/agent-runs/` 是运行态目录。是否提交由项目决定；默认只提交需要长期审计的 README、decisions、evidence 摘要，不提交临时噪音。

---

## 3. Artifact 协议

### 3.1 manifest.json

必须记录：
- `run_id`、`display_name`、`task_summary`、`effective_tier`。
- `orchestrator_session_id`、`created_at`、`status`。
- `contract_refs`、`shared_domain_approval_refs`、`risk_notes`。
- `participants`：`agent_id`、显示名、角色、职责、可写域、`session_id`、状态。

### 3.2 inbox.md

每个 agent 的输入必须包含：
- 任务目标、非目标、验收标准。
- 可读文件域、可写文件域、禁止动作。
- 契约版本、共享域仲裁状态和检查点边界。
- 预期输出 schema、证据要求和截止条件。

### 3.3 outbox.md

每个 agent 的输出必须包含：
- Summary：做了什么 / 没做什么。
- Evidence：命令、文件、截图、日志或只读调查依据。
- Changes：建议改动或已授权改动摘要。
- Risks：未测项、假设、冲突和剩余风险。
- Decision needed：需要主 Agent 或用户裁决的事项。
- Next action：建议下一步，不直接推进越权动作。

### 3.4 status.json

状态只允许：
- `pending`：已派发，未开始。
- `running`：执行中。
- `blocked`：等待输入、工具或确认。
- `ready_for_review`：已产出，待主 Agent 收口。
- `done`：已被主 Agent 接收。
- `failed`：失败，需要重派或降级。
- `aborted`：因收敛、风险或用户指令终止。

---

## 4. 收敛规则

以下情况必须停止 fan-out，并由主 Agent 收敛：
- 两个 agent 对契约、业务事实或共享文件 ownership 给出冲突结论。
- 子 agent 请求越权动作或修改未授权文件域。
- 任务范围扩张到新的产品结果或受保护动作。
- 同一阻塞连续出现两次，或证据不足以支持继续并行。
- 用户要求暂停、改方向或只保留单线执行。

收敛输出至少包含：当前 run、参与 agent、已采纳结论、未采纳原因、冲突点、下一步和剩余风险。

---

## 5. 自检

启用本协议前检查：
- [ ] 是否仍由 `tic-workflow-orchestrator` 总控。
- [ ] 是否使用人可读 run / agent 目录名。
- [ ] 是否把 `session_id` 作为追踪字段，而不是事实源。
- [ ] 是否冻结契约、分配文件域并写明禁止动作。
- [ ] 是否通过 artifact 通信，而不是让 agent 自由群聊。
- [ ] 是否定义收敛条件和主 Agent 最终验收责任。
