---
schema: tic_skill.v1
id: contract-handoff
status: canonical
phase: planning
role: PM / FE / BE
risk_min: standard
inputs:
  - task_list
  - ci_report
  - prd_or_openspec_change
outputs:
  - frozen_contract
  - fe_handoff
  - be_handoff
requires:
  - task-decomposer
delegates_to: []
legacy_sources:
  - api-contract-freezer
  - fe-be-handoff
---

# Contract Handoff（契约冻结与前后端交接技能）

## 技能用途

- 服务角色：**PM / Tech Lead / FE / BE**
- 触发时机：涉及 API、共享类型、数据结构、错误码、权限点、前后端并行实现或跨端字段消费前
- 输出物：冻结契约、FE 交接清单、BE 交接清单、Mock/fixture 方案、自测对照表
- 适用场景：需要把“接口协议”和“实现交接”绑定成同一证据链的 standard / critical 任务

---

## 0. 核心原则

契约冻结和 FE/BE 交接必须是同一个连续动作：**先冻结，再交接，再并行实现**。

`contract-handoff` 是跨端、FE/BE 或多 agent 并行实现的前置闸门。未冻结契约时，不得把相关实现任务派发给社区 agent、工具原生 subagent 或外部编排器。

绝对禁止：
- 未冻结契约就开始跨端并行开发。
- 冻结契约后另写一份不一致的交接清单。
- FE/BE 在并行期间私自修改共享类型、字段、错误码或状态枚举。
- 用“返回相关数据”“按需处理”等模糊描述代替字段级定义。

---

## 1. 触发条件

满足任一条件即触发：
- 新增或修改 API 请求/响应。
- 新增或修改 `types/`、`constants/`、状态枚举、错误码。
- FE 需要 Mock 数据或 BE 需要按 UI 场景实现接口。
- 任务需要 FE/BE 并行。
- OpenSpec / PRD 中出现数据需求、业务规则或权限点变化。

---

## 2. 输出结构

```markdown
# <功能名称> Contract Handoff

## 1. 冻结声明
- Contract ID:
- Version:
- Frozen at:
- Related change / PRD / task:
- Owner:
- Change policy:

## 2. 接口契约
| API / Event | Direction | Request | Response | Errors | Rules |
| --- | --- | --- | --- | --- | --- |

## 3. 数据类型与枚举
| Name | Field | Type | Required | Constraint | Display / Mapping |
| --- | --- | --- | --- | --- | --- |

## 4. FE Handoff
| Page / Component | Data needed | API / Mock | State | Self-test |
| --- | --- | --- | --- | --- |

## 5. BE Handoff
| API | Validation | Business rule | Storage / transaction | Self-test |
| --- | --- | --- | --- | --- |

## 6. 集成验证
| Scenario | Given | When | Then | Evidence |
| --- | --- | --- | --- | --- |

## 7. 待确认项
| Item | Owner | Blocking? |
| --- | --- | --- |

## 8. 并行执行边界
| Agent / Role | Task scope | Writable domain | Read-only contract | Required evidence |
| --- | --- | --- | --- | --- |
```

---

## 3. 变更控制

冻结后需要修改契约时：
1. 先提交变更申请，说明字段、原因、影响面。
2. PM / Tech Lead 判断是否影响 FE、BE、QA、文档和已有 Mock。
3. 递增契约版本。
4. 更新交接清单和验证场景。
5. 在 SESSION SNAPSHOT 或 Walkthrough 中记录变更。

---

## 4. 与旧技能关系

本技能是 `api-contract-freezer` 和 `fe-be-handoff` 的 canonical 合并版。

- 旧入口 `api-contract-freezer` 仍可用于只读旧流程，但新任务应路由到本技能。
- 旧入口 `fe-be-handoff` 仍可作为交接模板参考，但不得绕过冻结声明。
