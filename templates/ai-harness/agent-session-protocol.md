# Agent Session Protocol

本文件定义项目内多 agent 独立会话的运行态约定。它是项目适配层，不替代 `tic-workflow-orchestrator`、`contract-handoff` 或 `shared-domain-arbiter`。

## 何时启用

默认只在 standard / critical 任务中启用，并且必须满足：

- 子任务可独立验证。
- 已写清角色、任务范围、可读域、可写域、禁止动作和证据要求。
- API、字段、错误码、权限点或 FE/BE 并行前已完成契约冻结。
- 共享域写入前已完成共享域仲裁。
- 主 Agent 负责最终收口，不把子 agent 输出直接当完成态。

consulting / micro 任务保持轻量，除非用户明确要求跨会话接力或只读异步评审。

## 目录约定

```text
.tic/agent-runs/
  INDEX.md
  CURRENT.md
  20260630-1405-任务短标题/
    README.md
    manifest.json
    decisions.md
    evidence/
    agents/
      01-中文角色-本次职责/
        inbox.md
        outbox.md
        status.json
```

命名规则：

- run 目录使用 `YYYYMMDD-HHMM-任务短标题`，短标题使用用户和业务都能理解的中文。
- agent 目录使用 `序号-中文角色-本次职责`。
- `run_id`、`agent_id`、`session_id` 写入 `manifest.json` 或 `status.json`，不要暴露成主要浏览入口。
- `session_id` 只做追踪，不做事实源；事实源是契约、决策、证据和 outbox。

## Inbox

每个 agent 的 `inbox.md` 必须包含：

- 任务目标与非目标。
- 验收标准。
- 可读文件域与可写文件域。
- 禁止动作。
- 契约版本和共享域仲裁状态。
- 预期输出 schema。
- 证据要求和停止条件。

## Outbox

每个 agent 的 `outbox.md` 必须包含：

- Summary：做了什么 / 没做什么。
- Evidence：命令、文件、截图、日志或只读调查依据。
- Changes：建议改动或已授权改动摘要。
- Risks：未测项、假设、冲突和剩余风险。
- Decision needed：需要主 Agent 或用户裁决的事项。
- Next action：建议下一步。

## Status

`status.json` 的状态只允许：

- `pending`
- `running`
- `blocked`
- `ready_for_review`
- `done`
- `failed`
- `aborted`

## 收敛规则

以下情况必须停止 fan-out，并由主 Agent 收敛：

- agent 对契约、业务事实或共享文件 ownership 给出冲突结论。
- 子 agent 请求越权动作或修改未授权文件域。
- 任务范围扩张到新的 standard / critical 变更。
- 同一阻塞连续出现两次。
- 证据不足以支持继续并行。
- 用户要求暂停、改方向或单线执行。

收敛输出至少包含：当前 run、参与 agent、已采纳结论、未采纳原因、冲突点、下一步和剩余风险。
