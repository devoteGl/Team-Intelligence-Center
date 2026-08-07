# TIC Capability Contract

TIC Skills 使用 `tic_capability.v1` frontmatter 描述能力边界。该 metadata
用于发现和校验，不构成中心化编排图，也不决定规划深度、执行授权、验证
范围、Review 或事实持久化。

## 1. 标准结构

```yaml
---
schema: tic_capability.v1
id: e2e-verification
status: canonical
category: verification
activation:
  when:
    - 局部测试不足以证明关键用户旅程
  not_when:
    - 已有测试完整覆盖本次受影响行为
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 验收、审计或异步交接需要可引用证据
requires: []
related: []
---
```

## 2. 字段

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `schema` | 是 | 固定为 `tic_capability.v1` |
| `id` | 是 | 稳定、唯一的能力标识 |
| `status` | 是 | `canonical`、`compatibility`、`alias`、`subflow`、`checklist` 或 `rule-template` |
| `category` | 是 | 用于发现能力，不代表执行阶段 |
| `activation.when` | 是 | 能力可以被选择的事实条件 |
| `activation.not_when` | 是 | 容易误触发但不应选择能力的条件 |
| `side_effects` | 是 | 能力可能产生的最高副作用 |
| `artifacts.default` | 是 | 默认产物；通常为 `none` |
| `artifacts.when_needed` | 是 | 存在消费者时才生成的产物 |
| `requires` | 是 | 无法绕过的硬前置条件 |
| `related` | 是 | 仅用于发现的相关能力 |

`side_effects` 只能取：

- `none`
- `read-only`
- `local-reversible`
- `external-write`
- `irreversible`

## 3. 激活规则

- 用户明确调用能力时，可以激活。
- 当前任务事实满足 `activation.when` 时，可以激活。
- 命中 `activation.not_when` 时，不得仅凭关键词激活。
- `related` 不授权调用，也不扩大任务范围。
- 一个能力不能自动激活另一个能力。
- `requires` 不得用于表达“通常一起使用”或历史流程顺序。
- 受保护副作用仍需遵守 `Workflow/core.md` 的授权边界。
- 外部方法型 Skill 与 TIC capability 使用同一激活规则；总控型 Skill 的
  “全任务强制入口”声明不构成项目激活事实。

## 4. 产物规则

`artifacts.default` 为 `none` 时，能力可以在当前任务上下文中返回结果，不必
创建文件。`artifacts.when_needed` 中的产物只有在存在明确消费者、归档要求
或用户请求时生成。

兼容 alias 可以指向 canonical capability，但不得保留旧工作流、风险档位或
独立正文模板。

## 5. 与 Workflow 决策的关系

Capability 只回答“当前是否需要一种特定方法”。以下问题由
`Workflow/core.md` 分别判断：

- `planning_depth`
- `execution_authority`
- `verification_scope`
- `review_level`
- `fact_persistence`

选择 capability 不会自动改变这些值；需要独立 Review、OpenSpec 或确认动作
时，必须分别存在对应事实。
