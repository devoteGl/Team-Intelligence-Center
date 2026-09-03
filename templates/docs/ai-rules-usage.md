# AI 规则使用说明

本项目以轻量方式接入 Team-Intelligence-Center。

## 已安装内容

- `AGENTS.md`：项目级协作入口。
- `.tic-rules.lock`：规则版本和项目相对来源。
- `.tic-rules.local`：gitignored 的个人本机规则源。
- `.cursorrules`、`.windsurfrules`、`.rules/team-intelligence-center.md`：
  其他 AI 工具的项目入口。
- `ai-harness/project-adapter.md`：项目命令、拓扑、归属和治理事实；普通安装与升级不会覆盖。
- `ai-harness/memory/`：经确认的项目事实、决策、runbook 和协作约定；
  普通安装与升级逐文件保留。

## 如何描述任务

直接告诉 AI：

- 想得到什么结果；
- 哪些范围不能碰；
- 怎样算完成；
- 用什么证据证明；
- 哪些动作可以自主执行。

信息能够从项目中确认时，AI 会先调查。低影响、可回滚的细节可以采用合理
假设并在交付时说明。只有产品方向分歧或受保护动作需要询问。

## 五个独立判断

规划、授权、验证、Review 和持久化分别判断：

| 维度 | 选择 |
| --- | --- |
| 规划 | 内联判断 / 简短计划 / Living ExecPlan |
| 授权 | 自主执行 / 动作前确认 |
| 验证 | 针对性 / 集成 / E2E / 运行态 |
| Review | diff 自审 / 独立 Review / 用户决策 |
| 持久化 | 当前任务 / OpenSpec / PRD / Runbook / Release / 本地候选 |

大型本地重构可以使用 Living ExecPlan 但继续自主执行；很小的生产写入可以
不写长计划但仍需确认。文件数、技术关键词和测试需求不能替代分别判断。

## Capability

Skills 默认从解析出的规则源读取，不自动差量复制到项目本地 skills 或
开发者全局 skills。

普通任务不需要先调用 Orchestrator。需要某项专业能力时，AI 根据用户明确
要求或该能力的 `activation.when` 直接选择：

- 调查：`code-investigator`
- 计划：`task-decomposer`
- 公共契约：`contract-handoff`
- 并发 ownership：`shared-domain-arbiter`
- 跨任务或跨工具 Agent 协作：`agent-session-protocol`
- 关键旅程验证：`e2e-verification`
- 异步交付说明：`delivery-walkthrough`
- 维护中 PRD 同步：`post-dev-prd-sync`
- 发布交接：`release-handoff`
- 协作记忆：`collaboration-memory-maintainer`
- Git 生命周期：`git-flow-operator`

一个 capability 提到另一个 capability，不代表自动授权调用。

Superpowers 等外部 Skills 是按需方法库，不是默认总控。OpenSpec 是需要跨
任务、跨项目或多人长期维护时使用的长期规格载体，不是普通任务入口。

## 验证与交付

优先运行项目已有、可重复且与验收标准直接相关的验证。局部测试不足以证明
关键用户或系统旅程时使用 E2E。无法执行理想验证时，AI 必须说明替代证据、
未测项和剩余风险。

验证贯穿实现并在交付前重新执行。每次交付做完整 diff 自审；公共契约、
跨项目、高后果或复杂实现按需使用独立 Review。

当前任务摘要是默认交付。只有明确消费者存在时才创建额外 artifact：

- Reviewer / QA：Walkthrough 或验证证据；
- 产品维护者：PRD 更新草稿；
- 发布 / 运维：Changelog 或 Release Handoff；
- 后续协作者：经确认的事实、决策或 runbook。

## Memory

Memory 不默认参与每个任务。只有用户明确要求，或候选经验经确认具有长期
复用价值时才启用。

- 跨任务读取历史对话必须得到用户明确授权。
- 当前用户指令、代码、运行时和正式规格优先。
- 个人偏好和候选保存在 gitignored 的 `.tic/local/`。
- 团队和项目记忆写入 `ai-harness/memory/` 前需要证据与确认。
- 不保存原始聊天、密钥、认证状态、个人敏感信息或未确认推断。

## Git 与发布

AI 不默认执行分支、提交、推送、合并、tag 或发布。明确要求后，AI 应读取
`Global-Rules/git-rules.md`、`Skills/git-flow-operator.md` 和项目 adapter，
刷新远端引用并检查基线、同名分支与影响。目标已由当前请求唯一授权时不重复
确认；只有歧义、覆盖风险或范围扩大时暂停。

新提交使用 `tic-gitflow-v1`：普通任务进入类型分支，长期分支不直接提交或
推送；commit message 使用必填具体 scope 的中文 Conventional Commits，并在
写入前通过规则源中的分支和提交信息校验脚本。

创建发布材料不等于已经授权发布。生产、迁移、回滚和 Git 状态变更必须保留
原生或可审计的原始输出。

## 规则来源

可提交文件不保存个人绝对路径。若 gitignored `.tic-rules.local` 明确声明
`rules_source=local_config`，且非空 `rules_dir=` 可访问并包含
`Workflow/core.md`，优先使用该分支无关的本机规则源；否则读取
`.tic-rules.lock` 的非空 `rules_path=`，再回退到 `.tic-rules.local` 的
`rules_dir=`。

项目完整决策规则位于规则源的 `Workflow/core.md`；capability metadata
位于 `Workflow/capability-schema.md`。
