---
schema: tic_skill.v1
id: release-train-handoff
status: alias
canonical: release-handoff
phase: release
role: PM / Tech Lead / Release Manager / DS
risk_min: critical
inputs:
  - delivery_evidence
  - release_train_scope
outputs:
  - release_train_handoff
requires:
  - delivery-walkthrough
delegates_to:
  - release-handoff
---

# Release Train Handoff（发版批次交付包兼容入口）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager / DS**
- 触发时机：旧流程或旧提示词仍调用 `release-train-handoff` 时
- 输出物：发版批次交付包
- 适用场景：全量发版、多项目/多服务发版、SQL/脚本/配置变更、需要统一冒烟和回滚的 release train

---

## 兼容策略

本文件是兼容入口，不再维护独立正文模板。新任务必须路由到 canonical Skill：

```text
Skills/release-handoff.md
```

执行时：

1. 读取并遵守 `Skills/release-handoff.md`。
2. 使用 `mode=train`。
3. 输出发版总控、服务卡、业务联动卡、数据库/脚本 manifest、总冒烟、监控、回滚和证据归档。
4. 分支创建、merge、tag、push 或回灌仍必须交给 `git-flow-operator`，不得由发版交接技能直接执行。

## 兜底输出

如果 canonical Skill 缺失，输出最小发版批次交付包：

```markdown
# 发版批次交付包

- Release ID：
- 发版范围：
- 服务 / 项目清单：
- 数据库 / 脚本：
- 发版顺序：
- 总体验证：
- 监控与上线观察：
- 回滚方案：
- 待确认项：
```
