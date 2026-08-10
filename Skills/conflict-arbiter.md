---
schema: tic_capability.v1
id: conflict-arbiter
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 conflict-arbiter
  not_when:
    - 新任务可按事实判断 shared-domain-arbiter
side_effects: local-reversible
artifacts:
  default: none
  when_needed: []
requires: []
related:
  - shared-domain-arbiter
---

# Conflict Arbiter（兼容入口）

## 技能用途

本文件是兼容入口，不再维护独立正文模板。canonical Skill：
`Skills/shared-domain-arbiter.md`。

仅在旧名称被显式调用时读取 canonical Skill；单人修改共享文件不会因旧名称
的历史语义而自动进入仲裁，也不自动调用其他能力。
