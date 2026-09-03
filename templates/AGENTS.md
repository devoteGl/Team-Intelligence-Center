# Team-Intelligence-Center 轻量规则

规则版本：`{{TIC_VERSION}}`

## 规则源

按 `.tic-rules.lock` 的非空 `rules_path=`（项目相对路径）、gitignored
`.tic-rules.local` 的 `rules_dir=`、开发者 Loader 的顺序定位规则源。
`Workflow/core.md` 是唯一 workflow 事实源。

## 默认协作

普通任务直接调查、修改和验证，不先调用 Orchestrator 或总控型外部 Skill。
开始时理解：

- `outcome`：最终可观察结果；
- `boundaries`：范围、兼容性和不能触碰的副作用；
- `done`：全部验收标准；
- `verification`：证明结果的新鲜证据；
- `authority`：可自主执行和必须确认的动作。

规划、授权、验证、Review 和事实持久化分别判断：

- 规划使用内联判断、简短计划或长时任务的 Living ExecPlan；
- 本地可逆工作自主执行；外部、不可逆、生产、迁移、权限、资金、隐私、
  Git 状态变更和正式发布动作先确认；
- 修改过程中就近验证，交付前执行对应完成标准的最终验证；
- 每次交付做完整 diff 自审；公共契约、跨项目或高后果变更按需独立 Review；
- 当前任务摘要是默认产物，有长期消费者时才写 OpenSpec、PRD、Runbook、
  Release Handoff 或共享 Memory。

只暂停需要确认的具体动作，不阻塞安全调查与准备。

## 产品基线与 UI

大型新产品、业务域或重大用户旅程在缺少已确认产品基线时，使用
`tic-prd-author` 明确用户、结果、主旅程、范围、非目标和验收。确认前可继续
调查、原型和可逆技术探针，不开始会冻结 API、Schema、菜单、状态或领域模型的
持久实现。

用户可见产品在实现前明确角色、主旅程、信息架构和关键状态；重大产品方向由
有权 owner 确认。稳定产品内的 Bug、局部 UI 修复和纯重构继续直接实现并验证。

## Capability 与外部方法

Capability 先检查 `activation.not_when`，再仅在用户明确要求或事实满足
`activation.when` 时选择；关键词本身不构成激活事实，也不自动级联。
Superpowers 是按需工程方法库，不是 workflow 总入口；其 brainstorm、plan、
TDD、subagent、Review 或 verification 方法不能因为安装而强制进入每个任务。
OpenSpec 是跨任务、跨项目或多人长期维护的长期规格事实源，不是任务入口。
同一事实只保留一个主事实源，不重复创建 OpenSpec、Superpowers spec 和 SDD。

常用 TIC capability：

- 新产品或重大旅程缺少产品基线：`prd-author`
- 产品 owner 需要审查已有 PRD：`prd-review-checklist`
- 事实与影响面未知：`code-investigator`
- 公共契约有多个消费者：`contract-handoff`
- 并发修改存在 ownership 冲突：`shared-domain-arbiter`
- 局部检查不能证明关键旅程：`e2e-verification`
- 跨任务、跨工具、长时异步或审计：`agent-session-protocol`
- Reviewer、QA 或使用者需要异步说明：`delivery-walkthrough`
- 产品维护者需要同步行为事实：`post-dev-prd-sync`
- 真实进入发布或运营交接：`release-handoff`
- 用户要求 Git 生命周期操作：`git-flow-operator`

## 项目资产

- 优先遵守当前用户指令、代码、运行时、正式规格和项目 adapter。
- 不覆盖用户未提交改动。
- 普通安装与升级不得覆盖 `ai-harness/project-adapter.md` 或已有 memory。
- Memory 不默认参与每个任务；不得保存原始聊天、密钥、认证状态、敏感信息或
  未确认推断。
- UI 改动在环境可运行时核对真实界面、交互、控制台和网络请求。
- 没有与完成标准对应的新鲜证据，不得声称完成。

## Git 与交付

不默认创建分支、提交、推送、合并、tag 或发布。用户在当前任务明确要求该
结果即构成授权；目标可唯一解析时不重复确认。执行前仍需刷新权威远端引用，
检查基线、同名分支、影响和恢复方式。

交付说明结果、修改范围、验证、Review、未测项、剩余风险和尚未授权的动作。
