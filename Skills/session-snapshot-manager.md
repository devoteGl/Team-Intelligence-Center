---
schema: tic_capability.v1
id: session-snapshot-manager
status: rule-template
category: coordination
activation:
  when:
    - 工作跨任务、跨工具、跨人接力或当前上下文即将不可用
  not_when:
    - 同一任务上下文和工具状态仍可可靠恢复
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 接手者需要可恢复的最小快照
requires: []
related:
  - agent-session-protocol
---

# Session Snapshot Manager（会话快照模板）

## 技能用途

为真实的跨上下文接力压缩当前状态。快照不是固定工作阶段，也不高于当前代码、
项目文档、外部状态和新验证证据。

```yaml
snapshot:
  objective: ""
  boundaries: []
  completed: []
  in_progress: []
  remaining: []
  decisions: []
  authorizations: []
  evidence: []
  changed_files: []
  risks: []
  next_action: ""
```

生成时只保留接手必需的事实，不复制原始聊天、隐藏推理或敏感信息。恢复时先
核对仓库、任务、工具和外部系统的当前状态；过期内容标为 stale，不静默执行
旧快照中的受保护动作。
