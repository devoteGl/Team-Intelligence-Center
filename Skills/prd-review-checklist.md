---
schema: tic_capability.v1
id: prd-review-checklist
status: checklist
category: verification
activation:
  when:
    - 用户或产品维护者要求审查已有 PRD
  not_when:
    - 当前任务没有 PRD 消费者
    - 只需要验证代码实现
side_effects: read-only
artifacts:
  default: none
  when_needed:
    - 产品维护者需要可引用的审查报告
requires: []
related:
  - post-dev-prd-sync
---

# PRD Review Checklist（PRD 审查清单）

## 技能用途

判断 PRD 是否足以支持其真实消费者做决定、实现或验收。清单不假设产品一定
是前后端应用，也不强制数据库、页面、优先级或 Given-When-Then 格式。

## 审查维度

- 目标：用户/业务结果、非目标和成功标准是否明确。
- 参与者：使用者、owner、权限和受影响方是否可识别。
- 行为：主路径、失败路径、边界、状态变化和可观察结果是否清楚。
- 约束：兼容、隐私、安全、性能、法规和运营约束是否按领域需要覆盖。
- 验收：每项重要声明是否有可执行、可观察的验证方法。
- 决策：假设、未决问题、候选规则和正式决定是否分开。
- 一致性：术语、字段、示例、图表和外部契约是否互相矛盾。

## 输出

```yaml
verdict: ready | ready-with-conditions | not-ready
findings:
  - severity: blocking | important | suggestion
    location: ""
    issue: ""
    consequence: ""
    proposed_resolution: ""
open_decisions: []
```

严重性由对消费者结果的影响决定，不使用固定 P0～P3 映射。缺少与产品无关的
模板章节不是问题；无法验证的重要行为才是问题。
