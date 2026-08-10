---
schema: tic_capability.v1
id: delivery-walkthrough
status: canonical
category: handoff
activation:
  when:
    - 明确消费者需要异步 review、QA、演示、使用或接手说明
  not_when:
    - 当前对话中的实现摘要和验证结果已足够
    - 仅因为开发完成
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 消费者需要可引用的交付走查记录
requires: []
related:
  - e2e-verification
  - release-handoff
---

# Delivery Walkthrough（交付走查能力）

## 技能用途

面向已识别消费者，把已完成变更和现有证据整理为易于 review、验收或接手的
说明。本能力不因“实现完成”自动触发，也不补造缺失的验证。

## 生成方法

1. 先写消费者及其下一步动作，删除对其无用的章节。
2. 从真实 diff、提交、测试、截图、trace 或运行结果提取内容。
3. 区分已验证、未验证、已知限制和后续建议。
4. UI 证据只在视觉或交互是声明的一部分时加入。
5. 默认复用项目已有文档根；没有持久化消费者时直接在任务中回答。

## 可选结构

```markdown
# 交付走查
- 消费者与目的：
- 交付范围：
- 行为变化：
- 如何验证：
- 证据：
- 已知限制与剩余风险：
- 接手动作：
```

不要求固定文件清单、截图数量、角色签字或其他 capability 的产物。内容粒度
由消费者决定。
