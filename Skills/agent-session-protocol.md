---
schema: tic_capability.v1
id: agent-session-protocol
status: canonical
category: coordination
activation:
  when:
    - Agent 协作跨独立任务、跨工具、长时异步或需要审计
  not_when:
    - 同一任务内的原生 subagent 或线程可可靠承载协作
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 跨会话执行需要可恢复的任务、状态、消息和证据
requires: []
related:
  - shared-domain-arbiter
  - delivery-walkthrough
---

# Agent Session Protocol（跨会话协作协议）

## 技能用途

为跨独立任务、跨工具、长时异步或需要审计的 Agent 协作提供最小持久化
协议。同一任务内宿主已能保存消息、权限和结果时，直接使用原生机制。

## 最小模型

```text
run/
├── manifest.md
├── status.md
├── inbox/<agent>.md
├── outbox/<agent>.md
└── evidence/
```

只创建实际需要的文件；没有恢复、审计或跨工具消费者时不创建目录。

## 协作约束

- 每个执行者拥有明确 outcome、读写边界、禁止动作和验证责任。
- 主任务或指定 owner 负责最终整合；outbox 是输入，不是自动成立的结论。
- 消息记录决定、事实、证据、风险和阻塞，不保存隐藏推理或原始聊天。
- 共享写入冲突必须先收敛 ownership；不得用新会话绕过授权边界。
- Git、发布、生产写入、迁移或删除仍由原任务授权决定。

## 状态

`queued → working → needs-input | blocked | completed | cancelled`

每次状态更新至少包含：当前结果、证据链接、剩余事项、是否需要外部决定。
恢复任务时以可验证产物和当前代码为准，不把过期状态文件当最终事实。
