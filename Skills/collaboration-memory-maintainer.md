---
schema: tic_capability.v1
id: collaboration-memory-maintainer
status: canonical
category: persistence
activation:
  when:
    - 用户明确要求提取、审查、提升、协调、审计或废弃协作记忆
    - 项目政策已确认允许复用某类长期协作事实
  not_when:
    - 普通任务或单次偏好没有长期复用价值
    - 需要扫描其他聊天、私密记录或未授权历史
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 本地候选、项目共享记忆或审计记录
requires: []
related:
  - project-adapter-maintainer
---

# Collaboration Memory Maintainer（协作记忆维护能力）

## 技能用途

以明确授权、可追溯证据和生命周期控制维护协作记忆。Memory 不默认参与每个
任务，也不保存原始聊天、推理链、secret、PII 或与项目无关的个人信息。

## 模式

- `mode=extract`：从当前获准上下文提取 0～5 条候选，不写正式记忆。
- `mode=review`：核对证据、复用价值、作用域、敏感度和冲突。
- `mode=promote`：经明确授权后，将确认候选写入个人或项目事实源。
- `mode=reconcile`：处理重复、冲突、过期与作用域重叠。
- `mode=audit`：检查来源、使用记录、`review_after`、敏感度和所有者。
- `mode=deprecate`：标记失效原因与替代项，不静默删除审计事实。

## 候选结构

```yaml
id: ""
statement: ""
scope: personal | project | team
kind: preference | decision | convention | runbook | constraint
evidence: []
confidence: high | medium | low
sensitivity: public | internal | restricted
owner: ""
review_after: ""
conflicts_with: []
status: candidate | confirmed | deprecated
```

## 边界

- 个人偏好和未确认候选只写入 gitignored 本地目录。
- 项目共享记忆必须有明确授权、项目关联证据和维护 owner。
- 检索只返回与当前任务直接相关、已确认、未过期且作用域允许的条目。
- 新证据与记忆冲突时以当前事实为准，并进入 `mode=reconcile`；不得让旧记忆
  覆盖代码、CI、政策或用户当前决定。
- 每条记忆可被追溯、纠正、导出和废弃；无期限、无 owner 的约定不自动晋升。
