---
schema: tic_capability.v1
id: fe-be-handoff
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 fe-be-handoff
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

# FE-BE Handoff（兼容入口）

## 技能用途

本文件是兼容入口，不再维护独立正文模板。canonical Skill：
`Skills/contract-handoff.md`。

仅在旧名称被显式调用时读取 canonical Skill。消费者不限于前端和后端，是否
需要契约交接仍由独立消费者与实现边界决定。
