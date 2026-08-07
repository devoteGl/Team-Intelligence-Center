# TIC 0.5.0 协作复利闭环 SDD

## 1. 背景

TIC 已声明 `ai-harness/memory/` 用于项目事实、决策和 runbook，但现有
bootstrap 没有生成对应资产，也没有统一的提取、确认、晋升、冲突处理、
过期和审计流程。

历史任务还反复暴露出一类无法只靠项目代码解决的问题：指定代码视角、
讨论与实施边界、Git Flow 可见性、授权后的自治程度、真实环境证据要求等
协作经验会跨任务复现，却没有进入可审计的工程资产。

## 2. 目标

建立工具中立的 Collaboration Intelligence Loop：

1. 从用户明确授权的历史任务、当前任务结果和项目证据中提取候选经验。
2. 区分个人本地偏好、团队协作规则、项目事实、决策和 runbook。
3. 对候选执行证据、敏感性、冲突、有效期和晋升检查。
4. 用户明确要求时只检索少量相关、已确认记忆。
5. 候选经验经确认具有长期价值时才提取，避免把记忆变成默认流程。

## 3. 不做什么

- 不保存原始聊天记录、完整 transcript、思维链、秘密、Token、cookie、
  验证码、个人信息或生产业务明细。
- 不默认扫描历史任务；跨任务历史分析必须有用户明确授权或项目明确策略。
- 不引入向量数据库、云端记忆服务或外部 Agent 仓库。
- 不让记忆覆盖当前代码、运行时、正式规格或用户最新指令。
- 不把个人偏好自动提交为团队规则。

## 4. 资产模型

| 资产 | 位置 | 可提交 | 职责 |
| --- | --- | --- | --- |
| 项目适配 | `ai-harness/project-adapter.md` | 是 | 路径、命令、拓扑、治理与风险事实 |
| 项目上下文 | `ai-harness/memory/project-context.md` | 是 | 经验证的业务/系统边界 |
| 决策记录 | `ai-harness/memory/decision-log.md` | 是 | 已确认决策、理由和替代关系 |
| Runbook | `ai-harness/memory/runbooks.md` | 是 | 已验证的重复操作 |
| 团队协作 | `ai-harness/memory/team-collaboration.md` | 是 | 非个人化、已确认的协作约定 |
| 个人画像 | `.tic/local/collaboration-profile.md` | 否 | 当前协作者的本地偏好 |
| 候选队列 | `.tic/local/memory-candidates.md` | 否 | 未晋升候选与私人来源证据 |

`project-adapter.md` 不承载个人偏好或聊天摘要。OpenSpec / PRD 仍是目标
行为事实源；memory 只能引用正式规格，不能替代它。

## 5. 记忆条目契约

每条候选或正式记忆至少包含：

```yaml
id: MEM-YYYYMMDD-NNN
scope: personal-local | team | project
kind: preference | project-fact | decision | anti-pattern | runbook
statement: ""
status: candidate | confirmed | deprecated | superseded
confidence: S1 | S2 | S3 | S4
evidence_refs: []
sensitivity: public | internal | local-private | prohibited
confirmed_by: ""
valid_from: YYYY-MM-DD
review_after: YYYY-MM-DD
supersedes: []
```

来源证据可以引用任务 ID、代码路径、commit、规格或验证证据；团队资产
不得只依赖私人任务 ID，晋升时必须换成团队可复核证据。

## 6. 生命周期

### Extract

- 用户明确要求分析历史时，可读取当前宿主可访问的相关任务。
- 显式提取只分析当前任务及其交付证据。
- 每次生成 0～5 条候选，避免为没有长期价值的任务创建空记录。

### Classify

- 个人表达与沟通偏好进入 `personal-local`。
- 团队协作约定进入 `team`。
- 业务边界、系统事实、决策和 runbook 进入 `project`。
- 分支、进程、临时环境和一次性故障状态默认不晋升为长期记忆。

### Promote

- 用户显式声明的低风险个人偏好可直接确认到本地画像。
- 推断出的个人偏好至少需要两个独立任务证据，否则保持候选。
- 团队规则、项目事实、业务规则和 runbook 必须有人类确认或可复核项目
  证据；业务行为仍需进入 OpenSpec / PRD。
- `prohibited` 内容直接丢弃，不落盘。

### Retrieve

- Capability 被明确激活后，最多加载 3～7 条与当前任务直接相关的已确认
  条目。
- 当前状态问题以指定 ref 的代码、运行时和数据为准。
- 目标行为问题以已确认 OpenSpec、PRD 和决策为准。
- 记忆冲突时必须暴露差异，不静默选择。

### Reconcile / Audit / Deprecate

- 按 `review_after` 复核动态事实。
- 新决策通过 `supersedes` 替代旧条目，不改写历史。
- 无法复核或与当前事实冲突的条目降为 candidate、deprecated 或
  superseded。

## 7. Capability 接入

- 普通任务不默认读取、提取或写入 Memory。
- 用户明确要求历史分析、协作审计或记忆迁移时调用完整 Capability。
- 候选经验经确认具有长期复用价值时调用 `mode=extract`。
- 发现记忆与代码、规格或当前 ref 冲突时调用 `mode=reconcile`。
- 没有消费者或可复用经验时不生成空记录。

## 8. 验收标准

1. 新 bootstrap 生成五个共享 memory 文件。
2. 普通 `--force` refresh 对已有 memory 文件逐字节保留。
3. `.tic/local/` 自动加入 `.gitignore`，bootstrap 不自动创建个人画像。
4. canonical Skill 覆盖 extract、review、promote、reconcile、audit、
   deprecate，并包含授权、隐私、证据、冲突和过期规则。
5. Codex wrapper 只定位并读取 canonical Skill，不复制规则正文。
6. Capability 能被直接调用，不依赖 Orchestrator，也不自动参与普通任务。
7. Project Adapter 声明 `memory_root`，老项目仍保护性迁移。
8. 规则包验证覆盖模板、bootstrap、保留、gitignore、wrapper 和路由。

## 9. 验证策略

本仓库无业务 UI，E2E requirement 为 `targeted`：

- 使用 `tools/validate-pack.sh` 的隔离项目 fixture 验证首次创建和 refresh。
- 使用 Skill quick validator 检查 Codex wrapper 结构。
- 使用真实 `live-project-workspace` 做本地接入试运行，不读取或提交原始历史。
- PowerShell 运行时继续作为长期验证项；本次执行静态对齐检查。
