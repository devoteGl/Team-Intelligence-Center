---
schema: tic_skill.v1
id: api-contract-freezer
status: alias
canonical: contract-handoff
phase: planning
role: PM
risk_min: standard
inputs:
  - ci_report
  - task_list
outputs:
  - frozen_contract
requires:
  - task-decomposer
delegates_to:
  - contract-handoff
---

# API Contract Freezer（接口契约冻结兼容入口）

## 技能用途

- 服务角色：**PM / Tech Lead**
- 触发时机：旧流程或旧提示词仍调用 `api-contract-freezer` 时
- 输出物：接口契约冻结声明、字段定义、错误码、Mock/fixture 和变更流程
- 适用场景：API、共享类型、字段、枚举、错误码、权限点或 FE/BE 并行前的契约冻结

---

## 兼容策略

本文件是兼容入口，不再维护独立正文模板。新任务必须路由到 canonical Skill：

```text
Skills/contract-handoff.md
```

执行时：

1. 读取并遵守 `Skills/contract-handoff.md`。
2. 若旧任务只要求“冻结接口契约”，按 `contract-handoff` 的冻结声明部分输出。
3. 若同时涉及 FE/BE 并行交接，按 `contract-handoff` 同时输出 FE / BE handoff。
4. 契约冻结后触发 `Global-Rules/coding-rules.md` 第 6 节的 CP-3 检查点。

## 兜底输出

如果 canonical Skill 缺失，输出最小契约冻结卡：

```markdown
# 契约冻结卡

- 关联任务：
- 冻结范围：
- 请求参数：
- 响应结构：
- 错误码：
- Mock / fixture：
- 变更流程：
- CP-3 确认状态：
```
