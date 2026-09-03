---
schema: tic_capability.v1
id: prd-author
status: canonical
category: product-planning
activation:
  when:
    - 用户要求创建、重写或确认 PRD 或产品基线
    - 大型新产品或重大用户旅程缺少已确认产品基线，继续实现会冻结产品行为
  not_when:
    - 不改变用户可见行为的局部 Bug、重构或技术验证
    - 已确认 PRD 范围内的纯实现任务
    - 只需要把已交付行为同步到现有 PRD
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 产品 owner 或跨任务消费者需要 PRD 草稿或已确认基线
requires: []
related:
  - prd-review-checklist
  - task-decomposer
---

# PRD Author（产品需求基线能力）

## 技能用途

把业务意图和证据整理成可确认、可验收的产品基线。它保护大型新产品和重大
用户旅程不被技术实现反向定义，同时不干扰已有稳定产品的普通修复。

完整编写 PRD 时，读取 `Prompts/ai-prd-generator.rules.md`；只需判断是否缺少
产品基线时，不必加载完整写作参考。

## 方法

1. 识别 PRD owner、使用者、下游消费者、已有事实源和当前 PRD 状态。
2. 收集用户原话、业务材料、真实产品行为和已确认决定；分别标记事实、候选、
   冲突与未知。
3. 明确 outcome、用户、主旅程、范围、非目标和验收标准。会改变产品结果的
   未决项交给有权 owner 决定。
4. 用户可见产品同时明确角色、主旅程、信息架构和关键状态；视觉细节留给设计
   产物，PRD 引用确认后的设计基线。
5. 输出与需求规模相称的 PRD，保持 `DRAFT`，直到 owner 明确确认。
6. 记录被替代的旧事实源和仍可继续的可逆调查，不把草稿状态描述成项目阻塞。

## 实现边界

确认产品基线前，只允许调查、原型和可逆技术探针。不得让探针冻结正式 API、
Schema、菜单、领域模型或成为范围扩张依据。

发现代码、路线图或测试已经偏离产品意图时，先输出漂移及影响，不把现状写回
PRD 来消除冲突。已交付行为的证据同步属于 `post-dev-prd-sync`，不是本能力的
替代路径。

## 最小输出

```yaml
prd:
  status: DRAFT | REVIEW | CONFIRMED | SUPERSEDED
  owner: ""
  users: []
  outcome: ""
  primary_journey: []
  scope: []
  non_goals: []
  acceptance: []
  evidence: []
  conflicts: []
  open_decisions: []
  implementation_boundary: discovery-only | baseline-confirmed
```

完成标准：重要用户结果可被验收，产品与技术事实没有被混写，所有待决事项都有
owner，且 `CONFIRMED` 状态有明确授权证据。
