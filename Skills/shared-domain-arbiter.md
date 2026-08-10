---
schema: tic_capability.v1
id: shared-domain-arbiter
status: canonical
category: coordination
activation:
  when:
    - 两个或更多并发执行者需要修改同一共享域，且 ownership 或方案发生冲突
  not_when:
    - 单一执行者修改共享文件
    - 多个改动可顺序完成，且 owner 与契约没有争议
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 并发执行者需要可引用的 ownership 决定
requires: []
related:
  - contract-handoff
  - agent-session-protocol
---

# Shared Domain Arbiter（共享域仲裁能力）

## 技能用途

在真实的并发写入或 ownership 冲突中确定一个可执行决策。文件位于 router、
types、constants 或 global config，并不会单独触发本能力。

## 方法

1. 列出冲突请求、执行者、共享域、时间窗口和各自必须满足的结果。
2. 优先划分互不重叠的 ownership；无法划分时指定唯一 owner 合并变更。
3. 依据兼容性、可逆性、验证成本和事实源做决定，不按角色高低裁决。
4. 记录被拒方案、决定有效期、通知对象和重新打开条件。

```yaml
shared_domain: ""
requests: []
decision: approve | approve-with-conditions | sequence | reject
owner: ""
conditions: []
verification: []
reopen_when: []
```

仲裁只解决当前冲突，不自动扩大为架构评审、契约冻结或 Git 操作。
