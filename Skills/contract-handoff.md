---
schema: tic_capability.v1
id: contract-handoff
status: canonical
category: coordination
activation:
  when:
    - 共享契约跨越实现边界，且存在两个或更多独立消费者或实现者
    - 契约变更需要兼容性、版本或迁移决策
  not_when:
    - 单个内部实现可以在同一变更中原子完成
    - 只出现 API、字段、类型、枚举或权限等关键词但没有协调边界
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 独立消费者需要冻结、版本化或异步交接的契约
requires: []
related:
  - shared-domain-arbiter
  - e2e-verification
---
- 契约冻结不等于禁止变更；后续变更要显式说明消费者影响和迁移路径。
- 契约冻结不等于禁止变更；后续变更要显式说明消费者影响和迁移路径。
# Contract Handoff（共享契约交接能力）

## 技能用途

只有共享契约跨越实现边界，并需要独立消费者据此工作时，才冻结可验证的
语义。它不限于前后端，也适用于事件、Schema、CLI、SDK、配置和文件格式。

## 方法

1. 标出契约 owner、消费者、版本边界和事实源。
2. 定义输入、输出、约束、错误语义、权限、兼容性与废弃策略。
3. 写清未决问题；存在实质选择时由有权决策者确认。
4. 提供消费者可运行的示例、fixture、schema 或 contract test。
5. 变更后以真实实现和验证证据核对契约，避免文档漂移。

## 最小契约卡

```yaml
contract: ""
owner: ""
consumers: []
source_of_truth: ""
versioning: ""
behavior: []
errors: []
compatibility: []
verification: []
open_decisions: []
```

- 默认在当前任务上下文中表达；异步消费者存在时再落盘。
- 单个内部实现、同一 owner 的顺序修改或可原子提交的重命名不需要本能力。
- 契约冻结不等于禁止变更；后续变更要显式说明消费者影响和迁移路径。
