---
schema: tic_capability.v1
id: task-decomposer
status: canonical
category: planning
activation:
  when:
    - 用户要求拆解任务或实施计划
    - 工作包含多个相互依赖的交付单元，需要明确顺序或所有权
  not_when:
    - 单一、清晰、可直接完成并验证的局部任务
    - 仅因文件数量、预计耗时或技术栈复杂
side_effects: none
artifacts:
  default: none
  when_needed:
    - 多人、跨任务或异步执行需要持久计划
requires: []
related:
  - contract-handoff
  - shared-domain-arbiter
---

# Task Decomposer（任务拆解能力）

## 技能用途

把目标拆成可独立推进、可验证、边界清楚的工作单元。拆解围绕依赖和结果，
不预设角色流水线，也不自动调用其他能力。

## 拆解方法

1. 明确目标、不做什么、完成标准、验证方式和已有授权。
2. 按真实依赖切分；没有依赖的单元可并行，有依赖的写清输入输出。
3. 每个单元只设一个主要结果和一个可验证终点。
4. 标出共享写入面、外部副作用、未知事实与需要用户决策的事项。
5. 根据执行中的新证据更新计划，不把最初拆解当不可变合同。

## 推荐输出

```yaml
goal: ""
work_items:
  - id: W1
    outcome: ""
    scope: []
    depends_on: []
    owner: "single accountable owner"
    verification: []
decisions_needed: []
```

- `owner` 可以是人、Agent 或当前任务；不要求固定 PM、前端、后端、QA 角色。
- 计划默认留在当前任务上下文。只有明确消费者需要时才创建文件。
- 共享契约、并发 ownership 冲突、E2E 或发布交接是否需要专门方法，应分别
  根据各自激活条件判断。
