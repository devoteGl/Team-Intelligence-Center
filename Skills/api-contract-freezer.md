---
schema: tic_capability.v1
id: api-contract-freezer
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 api-contract-freezer
  not_when:
    - 新任务可按事实判断 contract-handoff
side_effects: local-reversible
artifacts:
  default: none
  when_needed: []
requires: []
related:
  - contract-handoff
---

# API Contract Freezer（兼容入口）

## 技能用途

本文件是兼容入口，不再维护独立正文模板。canonical Skill：
`Skills/contract-handoff.md`。

仅在旧名称被显式调用时读取 canonical Skill，并重新应用其激活边界；旧名称
不代表契约一定需要冻结。canonical 文件缺失时报告缺失，不恢复旧流程。
