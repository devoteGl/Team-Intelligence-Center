---
schema: tic_skill.v1
id: conflict-arbiter
status: alias
canonical: shared-domain-arbiter
phase: execution
role: PM
risk_min: standard
inputs:
  - shared_file_change_request
outputs:
  - arbitration_decision
requires:
  - task-decomposer
delegates_to:
  - shared-domain-arbiter
---

# Conflict Arbiter（共享文件冲突仲裁兼容入口）

## 技能用途

- 服务角色：**PM / Tech Lead**
- 触发时机：旧流程或旧提示词仍调用 `conflict-arbiter` 时
- 输出物：共享文件修改仲裁结论
- 适用场景：router、types、constants、global config、公共工具、共享组件等共享域修改

---

## 兼容策略

本文件是兼容入口，不再维护独立正文模板。新任务必须路由到 canonical Skill：

```text
Skills/shared-domain-arbiter.md
```

执行时：

1. 读取并遵守 `Skills/shared-domain-arbiter.md`。
2. 明确共享域文件、申请方、修改目的、影响范围和回滚方式。
3. 输出允许 / 驳回 / 需拆分 / 需契约冻结的仲裁结论。
4. 涉及 API、字段、枚举、错误码或权限点时，继续触发 `contract-handoff`。

## 兜底输出

如果 canonical Skill 缺失，输出最小共享域仲裁卡：

```markdown
# 共享域仲裁卡

- 关联任务：
- 共享文件：
- 申请方：
- 修改目的：
- 影响范围：
- 仲裁结论：
- 后续动作：
```
