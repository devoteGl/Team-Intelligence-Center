---
schema: tic_capability.v1
id: prd-review-checklist
status: checklist
category: verification
activation:
  when:
    - 用户或产品维护者要求审查已有 PRD
    - 大型新产品或重大用户旅程准备把产品基线转为已确认并进入正式实现
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

判断 PRD 或产品基线是否足以支持其真实消费者做决定、实现或验收。清单不假设
产品一定是前后端应用，也不强制数据库、页面、优先级或固定验收格式。

## 审查维度

- 目标：用户/业务结果、非目标和成功标准是否明确。
- 参与者：使用者、owner、权限和受影响方是否可识别。
- 行为：主路径、失败路径、边界、状态变化和可观察结果是否清楚。
- 产品基线：用户、结果、主旅程、范围、非目标、验收和 owner 是否共同成立。
- 界面：用户可见产品是否定义信息架构、页面职责、关键状态、反馈和恢复；视觉
  稿与 PRD 是否引用同一产品基线。
- 约束：兼容、隐私、安全、性能、法规和运营约束是否按领域需要覆盖。
- 验收：每项重要声明是否有可执行、可观察的验证方法。
- 决策：假设、未决问题、候选规则和正式决定是否分开。
- 一致性：术语、字段、示例、图表和外部契约是否互相矛盾。
- 追溯：OpenSpec/SDD、计划、测试和实现能否引用对应需求，而不是反向扩大它。

## 破坏性检查

以下任一项默认阻断产品基线转为 `CONFIRMED`：

- 代码、数据库或既有菜单被用来证明“用户就需要这些功能”；
- 目标以模块、接口、页面、表或测试数量表达；
- 技术风险没有真实用户场景，却被建设为正式产品能力；
- PRD、现有产品、设计稿和长期规格存在未裁决冲突；
- fixture、SHADOW、静态检查或局部 UI 结果被当成真实业务闭环；
- owner、主旅程、非目标或关键验收缺失；
- PRD 状态已确认，但没有可追溯的确认人或确认记录。

## 输出

```yaml
verdict: ready | ready-with-conditions | not-ready
implementation_readiness: discovery-only | bounded-implementation | ready
findings:
  - severity: blocking | important | suggestion
    location: ""
    issue: ""
    consequence: ""
    proposed_resolution: ""
open_decisions: []
destructive_risks: []
evidence_checked: []
```

严重性由对消费者结果的影响决定，不使用固定 P0～P3 映射。缺少与产品无关的
模板章节不是问题；无法验证的重要行为才是问题。`ready` 只说明产品基线可供
实现使用，不证明实现或发布已经完成。
