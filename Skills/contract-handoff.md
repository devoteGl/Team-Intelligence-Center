---
schema: tic_capability.v1
id: contract-handoff
status: canonical
category: coordination
activation:
  when:
    - 公共接口或多个消费者需要共享同一契约
  not_when:
    - 变更只影响单个内部实现且不存在共享消费者
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 实现方需要可引用的契约和交接记录
requires: []
related:
  - task-decomposer
legacy_sources:
  - api-contract-freezer
  - fe-be-handoff
---

# Contract Handoff（契约冻结与前后端交接技能）

## 技能用途

- 服务角色：**PM / Tech Lead / FE / BE**
- 触发时机：公共接口、共享类型、字段、错误码或权限点会跨实现边界变化，
  且多个消费者需要同一约定时
- 输出物：冻结契约、FE 交接清单、BE 交接清单、Mock/fixture 方案、自测对照表
- 适用场景：需要把“接口协议”和“实现交接”绑定成同一证据链的协作任务

---

## 0. 核心原则

只有共享契约跨越实现边界，且不先对齐会让多个消费者产生不兼容结果时，
才需要本能力。

此时契约冻结和实现交接是同一个连续动作：**先对齐，再交接，再并行修改
共享边界**。契约已经稳定且本次不改变时，各实现方可以直接按现有契约工作。

绝对禁止：
- 共享契约仍有歧义时开始互相依赖的跨端并行开发。
- 冻结契约后另写一份不一致的交接清单。
- FE/BE 在并行期间私自修改共享类型、字段、错误码或状态枚举。
- 用“返回相关数据”“按需处理”等模糊描述代替字段级定义。

---

## 1. 触发条件

出现以下事实时可以触发：

- API 请求/响应会变化，并且存在两个或以上实现方或消费者。
- `types/`、`constants/`、状态枚举、错误码会跨模块共享。
- FE Mock、BE 实现和 QA 断言依赖同一组尚未对齐的字段或场景。
- 多个执行者会并行修改或消费同一个权限、事件或数据契约。
- 当前代码、规格和消费者对同一契约存在冲突。

以下情况不触发：

- 变更只影响单个内部实现，没有共享消费者。
- FE/BE 并行但公共契约已经稳定，且本次不修改契约。
- 只是出现 API、字段、类型、权限等关键词。
- 当前任务只需调查契约，不需要冻结或交接。

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
