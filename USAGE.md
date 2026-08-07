# Team-Intelligence-Center 使用指南

本指南面向规则包维护者和接入业务项目的团队。0.5.1 的默认模型是
“结果优先、原生执行、五个维度独立判断”。

## 1. 先理解三个对象

### Workflow Core

[`Workflow/core.md`](Workflow/core.md) 是唯一的通用决策源，回答：

- 需要多深的计划？
- 哪个具体动作需要确认？
- 什么结论需要什么验证与 Review？
- 是否真的需要持久化 artifact？

### Capability

`Skills/*.md` 是可独立选择的能力。每个文件使用
[`Workflow/capability-schema.md`](Workflow/capability-schema.md) 定义的
`tic_capability.v1` 契约。

相关能力不会因为被列在 metadata 中而自动串联。调用一个 Capability 也
不会自动授权另一个 Capability 的副作用。

### Project Adapter

`ai-harness/project-adapter.md` 保存当前项目的事实和治理配置，例如项目
边界、测试命令、E2E 环境、证据根、发布归属和 memory 根。普通安装、刷新
和升级逐字节保留已有 adapter。

## 2. 五个维度如何选择

| 维度 | 选择 |
| --- | --- | --- |
| 规划深度 | 内联 / 简短 / Living ExecPlan |
| 执行授权 | 自主 / 动作前确认 |
| 验证范围 | 针对性 / 集成 / E2E / 运行态 |
| Review | diff 自审 / 独立 Review / 用户决策 |
| 事实持久化 | 当前任务 / OpenSpec / PRD / Runbook / Release / 本地候选 |

这些维度不能互相替代。大型本地重构可以需要 Living ExecPlan 但无需额外
授权；一个很小的生产写入仍然需要确认。

## 3. 受保护动作

以下动作执行前必须获得明确授权：

- 外部系统写入或通知他人；
- 不可逆或难恢复的数据迁移、删除和覆盖；
- 生产环境、真实资金、真实账号或真实用户数据操作；
- Git 分支创建、提交、push、merge、tag 和发布；
- PRD、候选规则或 Collaboration Memory 的正式晋升；
- 明显超出用户原始目标的范围扩张。

“全自动”“你决定”“不用问我”允许在原目标内自主完成可逆本地工作，不
自动包含上述动作。

## 4. 安装到项目

### 4.1 Shell

先预览：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --preview \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

确认后应用：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

刷新生成入口：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --refresh \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

仅在明确希望重新探测项目结构时重建 adapter：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --refresh \
  --regenerate-adapter \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

重建前会备份原文件。普通 `--refresh` 不会覆盖 adapter。

### 4.2 PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File `
  C:\path\to\Team-Intelligence-Center\tools\install.ps1 `
  -Preview `
  -RulesDir C:\path\to\Team-Intelligence-Center `
  -ProjectRoot C:\path\to\project
```

移除 `-Preview` 后应用；显式重建 adapter 使用
`-RegenerateAdapter`。

### 4.3 生成内容

安装器按需生成：

```text
AGENTS.md
.tic-rules.lock
.tic-rules.local                  # 只在需要本机绝对路径时生成，不提交
.cursorrules
.windsurfrules
.rules/team-intelligence-center.md
docs/ai-rules-usage.md
ai-harness/project-adapter.md
ai-harness/agent-session-protocol.md
ai-harness/memory/
```

`.tic/local/` 只用于个人偏好和待确认 memory 候选，默认加入
`.gitignore`，安装器不会自动创建其中的个人文件。

## 5. 规则源解析

项目入口按以下顺序解析规则源：

1. 从当前目录向上查找 `.tic-rules.lock`；
2. 使用其中非空的项目相对 `rules_path=`；
3. 否则读取同级 `.tic-rules.local` 的本机 `rules_dir=`；
4. 再按项目 `AGENTS.md` 的说明解析；
5. 显式调用 TIC 能力但仍未解析时，才使用全局 Loader 的 fallback。

提交到仓库的文件不包含个人机器绝对路径。

## 6. 更新

默认稳定通道选择最高 SemVer release tag：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --preview \
  --project /path/to/project

bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project
```

跟随当前检出分支：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --channel current \
  --project /path/to/project
```

固定到 0.5.1：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --ref 0.5.1 \
  --project /path/to/project
```

`--no-pull`、`--no-global` 和 `--no-project` 可分别关闭规则源更新、Codex
全局 wrapper 刷新和项目入口刷新。

更新顺序是：更新规则源、运行验证、刷新全局 wrapper、刷新项目入口。
Project Adapter 和 shared memory 仍按保留优先策略处理。

## 7. 可选 Codex 全局 Loader

预览安装：

```bash
bash /path/to/Team-Intelligence-Center/tools/install-codex-global.sh \
  --dry-run \
  --rules-dir /path/to/Team-Intelligence-Center
```

应用：

```bash
bash /path/to/Team-Intelligence-Center/tools/install-codex-global.sh \
  --yes \
  --rules-dir /path/to/Team-Intelligence-Center
```

Loader 只做规则发现和 wrapper 路由：

- 项目规则优先；
- 不复制完整 Skills；
- 不覆盖个人全局规则；
- 不让 Orchestrator 成为所有任务的入口；
- 不扩大任何 Capability 的授权。

## 8. Capability 选择

| 需要解决的问题 | 选择的 Capability |
| --- | --- |
| 不清楚代码路径、业务规则或影响面 | `code-investigator` |
| 需要把复杂目标拆成独立结果和 ownership | `task-decomposer` |
| API、字段、枚举、错误码或权限需要跨边界对齐 | `contract-handoff` |
| 多执行方并发修改同一共享域 | `shared-domain-arbiter` |
| 当前验证不足以证明关键用户旅程 | `e2e-verification` |
| 跨任务、跨工具、长时异步或审计交接 | `agent-session-protocol` |
| 明确消费者需要异步交付说明 | `delivery-walkthrough` |
| 产品维护者需要同步已变更行为 | `post-dev-prd-sync` |
| 发布方需要部署、回滚、tag 和证据交接 | `release-handoff` |
| 用户明确要求 Git Flow 建议或操作 | `git-flow-operator` |
| 用户要求维护可复用协作事实 | `collaboration-memory-maintainer` |
| 需要显式生成复杂工作计划或迁移旧路由 | `tic-workflow-orchestrator` |

普通本地任务不需要调用 `tic-workflow-orchestrator`。

## 9. 规格、验证和产物是三件事

### 规格

只有行为需要长期契约、多方对齐或项目本身要求时，才创建或更新 OpenSpec、
SDD、PRD。项目已有事实源时继续使用该事实源。

### 验证

验证回答“什么证据足以支持当前结论”。它与规划、授权和 Review 分别判断：

- 纯文档改动可以只做结构和链接检查；
- 单点代码修复应运行相关单元或集成测试；
- UI 结论在环境可运行时应核对真实界面；
- 用户旅程、跨层流程、认证、权限、资金、隐私或迁移可能需要 E2E；
- 无法完成必要验证时记录 `partial`、`blocked` 或经责任人确认的
  `waived`，不能写成通过。

优先使用项目原生、可重复的测试套件。Browser、Chrome、Computer Use、
截图和 trace 是可替换的观察适配，不是强制依赖。

### 产物

创建额外 artifact 前必须回答：

1. 谁会读取？
2. 用于什么决定或后续动作？
3. 不创建会丢失什么重要信息？

没有明确答案时，不创建 Walkthrough、PRD 草稿、Release Handoff、
session manifest 或 memory 候选。

## 10. Collaboration Memory

Memory 是显式 Capability，不是默认任务上下文。

共享范围：

```text
ai-harness/memory/project-context.md
ai-harness/memory/decision-log.md
ai-harness/memory/runbooks.md
ai-harness/memory/team-collaboration.md
```

个人范围：

```text
.tic/local/collaboration-profile.md
.tic/local/memory-candidates.md
```

允许保存：

- 已确认且有来源的项目事实；
- 明确决策及其适用范围；
- 可复现 runbook；
- 团队确认的协作约定。

禁止保存：

- 原始聊天；
- 密钥、token、认证状态；
- 个人敏感信息；
- 未经确认的推断；
- 已过期但仍被当作当前事实的条目。

检索、提取、review、promote、reconcile、audit 和 deprecate 都是显式
操作。候选不会自动晋升为团队规则，个人偏好不会自动晋升为共享记忆。

## 11. Git 与发布

TIC 默认只提供建议，不执行 Git 写操作。用户明确要求 Git Flow 时：

1. 解析项目声明的分支、版本和 tag 策略；
2. 运行或要求运行 `git fetch --all --prune --tags`；
3. 检查基线同步和本地/远端同名分支；
4. 输出候选命令和证据；
5. 在执行分支、提交、push、merge、tag 或发布前等待确认。

已 push 的发布 tag 默认不可移动。release/hotfix tag 也不是自动完成态，
仍需记录项目要求的回灌或收尾状态。

## 12. 跨任务协作

同一任务内优先使用宿主线程、当前计划和工具状态。只有跨独立任务、跨
工具、长时异步或需要审计时，才创建 session manifest、status、outbox 和
evidence。

启用多个执行方时必须明确：

- 每个执行方的结果责任；
- 可写文件域；
- 共享契约；
- 检查点；
- 验证证据；
- 主执行方如何收口。

artifact 不是跨任务协作本身；它只在接手者确实需要时存在。

## 13. 从旧配置迁移

旧版任务档位和流程下限不再控制 0.5.1 的执行。迁移时：

1. 把旧档位拆成规划、授权、验证、Review 和事实持久化五个独立判断；
2. 把原来的全局最小流程约束改写成具体受保护动作；
3. 删除 Skill metadata 中的路由和自动调用关系；
4. 将 Orchestrator 改为显式规划或兼容用途；
5. 将自动产物改为有消费者时创建；
6. 将默认 memory 检索和提取改为显式激活。

旧 `.tic-rules.lock` 中未知字段会在普通刷新时保留，便于团队逐步迁移，
但不再作为 Workflow Core 的决策源。

## 14. 维护者验证

```bash
bash -n tools/*.sh
jq empty manifest.json Workflow/scenarios.json
bash tools/validate-pack.sh
git diff --check
```

验证器会创建隔离 fixture，不修改业务项目。若系统安装 `pwsh`，还会运行
PowerShell 创建与保留性 fixture；否则输出明确 warning。
