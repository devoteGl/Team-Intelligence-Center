---
schema: tic_capability.v1
id: post-dev-prd-sync
status: canonical
category: persistence
activation:
  when:
    - 产品维护者需要把已交付行为同步到项目 PRD 事实源
  not_when:
    - 项目没有 PRD 消费者或行为未改变
    - 只有实现细节、重构、推测或未确认候选规则
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 项目 PRD owner 接受的变更草案或正式更新
requires: []
related:
  - candidate-rule-extractor
  - changelog-writer
---

# Post-development PRD Sync（开发后 PRD 同步能力）

## 技能用途

把已经交付并有证据的产品行为同步给明确的 PRD 消费者。本能力不因任务完成自动触发，也不把代码推断直接提升为产品事实。

## 方法

1. 从项目 adapter 读取 PRD owner、事实源和 `prd_draft_root`；不存在时询问或
   只返回草案，不自行发明目录。
2. 对照交付前后的可观察行为、验收结果和已确认决定。
3. 仅更新受影响章节，保留未知自定义结构和人工内容。
4. 将候选规则、矛盾和无法证明的事项列入待确认，不写成正式规则。
5. 输出变更摘要和证据映射，由有权产品维护者决定是否合入。

```yaml
prd_source: ""
owner: ""
delivered_behavior: []
evidence: []
proposed_edits: []
candidate_rules: []
pending_confirmation: []
```

OpenSpec、测试证据、提交和截图可作为输入，但它们不自动授权修改 PRD，也不
形成固定的后开发链路。
