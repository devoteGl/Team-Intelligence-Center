---
schema: tic_capability.v1
id: release-ops-handoff
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 release-ops-handoff
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

# Release Ops Handoff（兼容入口）

## 技能用途

本文件是兼容入口，不再维护独立正文模板。canonical Skill：
`Skills/release-handoff.md`。

仅在旧名称被显式调用时读取 canonical Skill；不强制 tag、发布目录、固定角色
或规格/测试/PRD 套件。
