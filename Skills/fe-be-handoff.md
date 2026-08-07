---
schema: tic_capability.v1
id: fe-be-handoff
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 fe-be-handoff
  not_when:
    - 新任务可以直接调用 contract-handoff
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - canonical capability 需要输出交接记录
requires: []
related:
  - contract-handoff
---

# FE-BE Handoff（前后端交接兼容入口）

## 技能用途

- 服务角色：**PM / FE / BE**
- 触发时机：旧流程或旧提示词仍调用 `fe-be-handoff` 时
- 输出物：FE 交接清单、BE 交接清单、Mock/联调约定、自测对照表
- 适用场景：契约冻结后，前后端开始各自实现前

---

## 兼容策略

本文件是兼容入口，不再维护独立正文模板。新任务必须路由到 canonical Skill：

```text
Skills/contract-handoff.md
```

执行时：

1. 读取并遵守 `Skills/contract-handoff.md`。
2. 先确认已有冻结契约；没有冻结契约时，先完成契约冻结。
3. 基于已冻结契约输出 FE / BE 各自需要的交接清单。
4. 若交接后需要改字段、错误码、枚举或 Mock，必须回到 `contract-handoff` 的变更流程，不得单方私改。

## 兜底输出

如果 canonical Skill 缺失，输出最小 FE/BE 交接卡：

```markdown
# FE / BE 交接卡

- 关联任务：
- 冻结契约：
- FE 需要的信息：
- BE 需要的信息：
- Mock / 联调方式：
- 自测对照：
- 未确认项：
```
