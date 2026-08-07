# TIC 0.5.0 协作复利闭环 - Delivery Walkthrough

## 1. 交付摘要

TIC 现在把长期协作经验分为个人本地画像、团队约定、项目事实、决策和
runbook，通过授权、证据、敏感性、有效期与冲突门禁控制其提取和复用。
它不是聊天归档，也不会让历史偏好覆盖当前指令或正式规格。

## 2. 核心链路

```text
明确授权的历史 / 当前任务证据
  -> extract 0～5 条候选
  -> review 范围、证据、敏感性、冲突、有效期
  -> promote 到 .tic/local/ 或 ai-harness/memory/
  -> 显式检索 3～7 条相关 confirmed 记忆
  -> 当前指令 / 当前证据 / 正式规格优先
  -> reconcile / audit / deprecate
```

## 3. 关键决策

| 决策 | 原因 |
| --- | --- |
| 个人与团队资产分离 | 避免把个人偏好变成团队强制规则 |
| 不保存原始聊天 | 降低隐私、噪声、提示注入和长期漂移风险 |
| 有限检索和提取 | 控制上下文成本，防止记忆堆积 |
| 当前证据与正式规格优先 | 避免陈旧记忆覆盖真实状态和目标行为 |
| bootstrap 只创建共享骨架 | 不在无授权时建立个人画像 |
| 普通升级逐文件保留 | 保护项目维护的决策、runbook 和自定义内容 |

## 4. Review 指引

- 核对 `Skills/collaboration-memory-maintainer.md` 的授权、隐私、晋升和
  冲突规则。
- 核对 Shell / PowerShell bootstrap 都只创建缺失 memory，且
  `.tic/local/` 被 gitignored。
- 核对 Memory 可直接调用且不默认扫描历史任务。
- 核对 manifest、README、USAGE、全局 Loader 和项目模板版本一致。
- 核对隔离 fixture 与真实 `live-project-workspace` 试运行证据。

## 5. 验证与风险

详细结果见 `docs/test-evidence/tic-0.5.0/README.md`。

- 本仓库无业务 UI，E2E requirement 为 `targeted`。
- `validate-pack.sh`、Shell 语法、manifest、diff 和 15 个 wrapper quick
  validation 使用 2026-08-07 新鲜证据通过。
- 一个父工作区 + 7 个正式子项目的本地更新属于未发布 Memory 实现的历史
  试运行；adapter 和既有 memory hash 当时保持不变，本次未重跑。
- PowerShell 本次做静态对齐；因无 `pwsh`，运行时证据明确记为
  `partial` 并作为长期验证项。
- 0.5.0 尚未 tag 或 push；本次只验证本地开发版本。
