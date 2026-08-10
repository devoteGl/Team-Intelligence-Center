# TIC 0.5.2 Skill 能力收口

## 问题

0.5.1 已把 workflow 改为五维独立判断，但不少 Skill 正文仍保留旧角色流水线、
固定报告、目录和推荐链路。Codex 全局 wrapper 的 `description` 又是自动发现
入口；“before non-trivial changes”“Use before API”“Use after implementation”
会把可选方法重新变成隐形流程。

## 决策

1. canonical Skill 只描述一个高内聚方法，正文控制在 180 行以内。
2. 先应用 `activation.not_when`，关键词本身不构成激活事实。
3. `related` 只用于发现，不在正文或 wrapper 中自动级联。
4. 输出默认留在任务上下文，只有明确消费者需要时落盘。
5. contract 由独立消费者边界触发；shared-domain arbitration 由并发 ownership
   冲突触发；walkthrough、PRD、changelog、release artifact 均由消费者触发。
6. Git 写操作仍受保护，但当前任务对明确结果的授权可复用；只在 refs、远端、
   版本、覆盖行为不唯一或范围扩大时再次询问。
7. 分支新鲜度只要求权威远端，不把 `fetch --all` 固化为普遍规则。

## 生命周期

- 14 个主能力保持 `canonical`。
- `tic-workflow-orchestrator` 保持显式调用的 `compatibility` 能力。
- 5 个旧名称仅保留薄 alias，目标在 `0.6.0` 删除。
- `candidate-rule-extractor` 是窄 subflow；`prd-review-checklist` 与
  `session-snapshot-manager` 分别登记为 checklist 和 rule template。

## 验收

- canonical Skills 不含旧 tier、CP、角色/阶段链或推荐链路术语。
- canonical Skills 均不超过 180 行。
- wrapper descriptions 不使用 before/after 顺序或宽泛关键词触发。
- 场景覆盖明确正触发，以及共享文件、内部 API、开发完成、产品行为变化等
  形似关键词但不应触发的情形。
- 已明确授权的 Git 发布场景不要求重复确认。
- 安装、更新、adapter/memory 保留和现有验证继续通过。
