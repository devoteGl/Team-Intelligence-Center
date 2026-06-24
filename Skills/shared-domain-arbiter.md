---
schema: tic_skill.v1
id: shared-domain-arbiter
status: canonical
phase: execution
role: PM / Tech Lead
risk_min: standard
inputs:
  - shared_file_change_request
  - contract_or_task_scope
outputs:
  - arbitration_decision
  - affected_owner_notice
requires:
  - task-decomposer
delegates_to: []
legacy_sources:
  - conflict-arbiter
---

# Shared Domain Arbiter（共享文件域仲裁技能）

## 技能用途

- 服务角色：**PM / Tech Lead**
- 触发时机：实现中需要修改共享文件域，例如 `router/`、`types/`、`constants/`、全局配置、公共工具、跨端契约文件
- 输出物：共享文件修改仲裁结论、影响范围、授权条件、通知对象、记录位置
- 适用场景：FE/BE 并行、跨模块开发、共享类型/路由/常量变更、避免职责边界被隐式破坏

---

## 0. 核心原则

共享文件域是协作边界，不是任何一方的临时便利区。

绝对禁止：
- 未经说明直接修改共享文件。
- 把 Git merge conflict 误当成本技能处理对象。
- 不评估影响面就批准字段、路由、常量或全局配置变更。

---

## 1. 申请格式

```markdown
## Shared Domain Change Request

- Applicant:
- File / domain:
- Change type:
- Related task / contract:
- Reason:
- Impact on FE:
- Impact on BE:
- Impact on QA / docs:
- Rollback:
```

---

## 2. 仲裁结论

```markdown
## Shared Domain Arbitration

- Decision: approved / approved with conditions / rejected / needs more info
- Reason:
- Conditions:
- Owners to notify:
- Required follow-up:
- Snapshot / walkthrough record:
```

---

## 3. 与旧技能关系

本技能是 `conflict-arbiter` 的重命名 canonical 版本。旧名容易和 Git merge conflict 混淆，后续路由应使用 `shared-domain-arbiter`。
