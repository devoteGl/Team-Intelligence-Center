---
schema: tic_capability.v1
id: release-train-handoff
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 release-train-handoff
  not_when:
    - 新任务可按事实判断 release-handoff
side_effects: local-reversible
artifacts:
  default: none
  when_needed: []
requires: []
related:
  - release-handoff
---

# Release Train Handoff（兼容入口）

## 技能用途

本文件是兼容入口，不再维护独立正文模板。canonical Skill：
`Skills/release-handoff.md`。

仅在旧名称被显式调用时读取 canonical Skill；多服务或批次发布的字段由真实
发布消费者决定，不恢复旧的统一发版模板。
