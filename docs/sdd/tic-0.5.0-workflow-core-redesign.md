# TIC 0.5.0 Workflow Core 重设计

## 1. 决策摘要

TIC `0.5.0` 将默认工作方式从“先经过总控路由，再按阶段展开 Skill DAG”
改为“默认直接执行，只在具体动作产生风险时升级”。

本次重设计不以减少文件数或套用“高内聚、低耦合”为目标。评价 workflow
的主要指标是：

- 默认路径长度；
- 用户被打断的频率；
- 流程占用的上下文与注意力；
- 风险是否被限制在产生风险的动作附近；
- 能力能否被独立选择和替换；
- 额外产物是否存在明确消费者；
- 失败后的可恢复性；
- 规则是否容易解释和验证。

当前工作区中尚未发布的 `0.4.0` Collaboration Intelligence Loop 将并入
`0.5.0`。不发布临时过渡架构，也不丢失现有协作记忆实现成果。

## 2. 背景与问题

当前 workflow 已经尝试区分 consulting、micro、standard 和 critical，
并声明按风险触发规格、验证和归档。但默认入口仍承担了过多职责：

1. Intake 需要先完成任务归一化、风险分级、产物归属和 Skill 路由。
2. 多文件、测试、UI 或用户可见变化等宽泛信号容易升级整个任务。
3. Orchestrator 维护 `delegates_to` 和 Skill DAG，专业能力不能自然地被直接调用。
4. standard / critical 容易级联触发规格、E2E、PRD、Walkthrough、Changelog、
   Memory 和 Release Handoff。
5. Agent 需要解释跳过了哪些流程，导致“不执行流程”本身也产生流程成本。
6. 流程产物有时先于真实消费者出现，增加维护负担而没有等量增加正确性。

结果不是模型能力下降，而是更多注意力被用于理解和证明流程，普通任务的
执行速度、自主调查空间和方案探索受到限制。

## 3. 目标

### 3.1 行为目标

1. 普通任务默认进入 `direct`，不需要调用 workflow orchestrator。
2. 风险判断绑定具体动作、可恢复性和外部影响，不绑定文件数或关键词。
3. 可逆本地调查、修改和验证默认由 Agent 自主完成。
4. 只有产品方向分歧或受保护动作需要暂停用户确认。
5. Skills 作为可独立调用的能力，不组成默认阶段流水线。
6. 测试强度根据影响面选择，但“需要测试”本身不触发风险升级。
7. 额外产物只有在存在明确消费者或用户明确要求时生成。
8. 通过场景用例和静态校验持续验证 workflow 行为。

### 3.2 经营目标

1. 新用户一次阅读即可理解默认路径和暂停边界。
2. 新增 Skill 不需要修改中心化 DAG 才能使用。
3. 单个 Skill 的调整不会隐式改变其他 Skill 的触发行为。
4. 能力、风险和产物可以分别演进，不需要同步升级整条流水线。
5. 兼容入口有明确生命周期，不长期保留两套 workflow。

## 4. 不做什么

- 不把所有 Skills 合并成少数巨型模块。
- 不维护新旧两套并行的 workflow。
- 不为 workflow 引入运行时服务、数据库或中心化编排器。
- 不让任务规模、文件数量、是否涉及 UI 或是否需要测试单独决定风险档位。
- 不自动创建分支、提交、推送、合并、tag、发布或生产变更。
- 不自动扫描历史任务，也不自动把候选协作经验晋升为项目事实。
- 不删除尚未验证无人使用的旧 Skill 名称；兼容入口将在 `1.0.0` 前审计。

## 5. Workflow Core

### 5.1 单一事实源

新增 `Workflow/core.md`，作为工具中立的 workflow 决策事实源。

它只定义：

- 任务契约；
- 三档执行模式；
- 动作升级信号；
- 用户确认边界；
- 能力选择规则；
- 验证与交付的最低要求。

`Workflow/core.md` 不包含具体 Skill 模板，不生成 Skill DAG，不列举全量
跳过项，也不规定所有任务必须依次经过哪些阶段。

项目模板、全局 Loader、README 和使用指南只能摘要并指向该文件，不能各自
维护另一份风险模型。

### 5.2 最小任务契约

Agent 开始工作时只需要理解四个字段：

| 字段 | 含义 |
| --- | --- |
| `goal` | 用户要得到的结果 |
| `boundaries` | 不允许触碰的范围与副作用 |
| `done` | 可以验证的完成标准 |
| `autonomy` | Agent 可自主执行的动作范围 |

字段不完整时：

- 能通过代码、文档、运行时或只读调查确认的，先调查；
- 对结果影响小且容易回滚的，采用合理假设并在交付时说明；
- 会导致明显不同产品结果的，询问用户；
- 涉及受保护动作的，必须在执行前获得授权。

任务契约默认保存在当前任务上下文，不要求落盘。

### 5.3 三档执行模式

| 模式 | 判断依据 | 默认行为 |
| --- | --- | --- |
| `direct` | 本地、可逆、影响可控，没有受保护动作 | 调查、修改、验证并交付 |
| `structured` | 公共契约、跨模块行为、多人协作或明显产品行为需要先对齐 | 形成简短执行契约，再执行和验证 |
| `guarded` | 不可逆、生产、外部写入、权限、资金、隐私、数据迁移或发布 | 明确确认、回滚和证据后执行 |

所有任务默认从 `direct` 开始。只有当前准备执行的动作满足升级条件时，
对应动作或必要范围才升级；任务中其余安全工作不随之整体升级。

### 5.4 不构成升级的信号

以下情况不能单独导致模式升级：

- 修改多个文件；
- 需要运行测试、构建、lint 或截图；
- 涉及 UI、API、数据库等技术关键词；
- 用户可见，但修改局部且容易恢复；
- 任务耗时较长；
- Agent 希望使用计划或调查工具；
- 用户要求“全自动”或“你看着办”。

这些信号可以影响调查和验证强度，但不能替代动作风险判断。

### 5.5 受保护动作

以下动作在没有明确授权时必须暂停：

- 不可恢复的数据删除或覆盖；
- 生产环境、真实用户或外部系统写入；
- 数据库迁移及高成本回滚；
- 权限、安全、资金、隐私边界变化；
- 分支创建、提交、推送、合并、tag 和正式发布；
- 将草稿转为正式规格、规则或团队记忆；
- 两个方案会产生明显不同的产品结果，且无法从事实判断。

暂停只围绕受保护动作，不阻止此前可安全完成的调查、方案比较和验证。

## 6. Capability 模型

### 6.1 从 Skill DAG 改为独立激活

Skill metadata 升级为能力契约。建议的新 schema：

```yaml
schema: tic_capability.v1
id: e2e-verification
status: canonical
category: verification
activation:
  when:
    - 单元或集成测试不足以证明关键用户旅程
  not_when:
    - 局部测试已经覆盖全部受影响行为
side_effects: local
artifacts:
  default: none
  when_needed:
    - 验收、审计或异步交接需要可引用证据
requires: []
related: []
```

字段约束：

- 删除 `risk_min`，因为能力与风险档位不是一一对应关系。
- 删除 `delegates_to`，禁止自动级联其他能力。
- `requires` 只表达缺少它就无法正确工作的硬前置条件。
- `related` 只用于发现相关能力，不授权调用，也不扩大任务范围。
- `artifacts.default` 默认应为 `none`；确需默认产物时必须说明消费者。
- `side_effects` 取值为 `none`、`read-only`、`local-reversible`、
  `external-write` 或 `irreversible`，用于识别能力本身是否需要额外授权。

### 6.2 能力触发表

| 能力 | 激活条件 | 默认产物 |
| --- | --- | --- |
| `task-decomposer` | 用户需要计划，或无法安全地边调查边执行 | 当前任务内计划 |
| `code-investigator` | 现状、调用路径、影响面或业务事实未知 | 当前任务内调查结论 |
| `contract-handoff` | 公共接口或多个消费者需要共享同一契约 | 契约记录，位置由消费者决定 |
| `shared-domain-arbiter` | 存在并发 ownership 或互斥修改冲突 | 仲裁结论 |
| `agent-session-protocol` | 跨任务、跨工具、长时异步或需要审计 | 会话协作 artifact |
| `e2e-verification` | 局部测试不足以证明关键用户旅程 | 验证结果；需要时落盘证据 |
| `delivery-walkthrough` | Reviewer、QA、运营或使用方需要异步理解交付 | Walkthrough |
| `post-dev-prd-sync` | 产品事实变化且存在维护中的 PRD | PRD 更新草稿 |
| `changelog-writer` | 准备形成版本发布记录 | Changelog |
| `release-handoff` | 真实进入部署或运营交接 | Release Handoff |
| `collaboration-memory-maintainer` | 用户明确要求，或候选经验经确认具有长期价值 | 候选或正式记忆 |
| `git-flow-operator` | 用户明确要求 Git 生命周期操作 | Git 操作计划与证据 |
| `project-governance-bootstrap` | 用户要求项目接入 TIC | 接入文件 |
| `project-adapter-maintainer` | 用户要求维护 adapter，或接入/升级无法继续 | Adapter 变更 |

### 6.3 Orchestrator 的新定位

`tic-workflow-orchestrator` 不再是 canonical 默认入口。它保留为兼容和显式
规划能力：

- 旧用户显式调用时，将旧档位映射到新模式；
- 用户要求 workflow 规划、治理审计或复杂受保护操作时，可生成决策摘要；
- 它不得重新引入阶段流水线、Skill DAG 或全量产物清单；
- 新模板不得要求所有任务先调用 orchestrator。

## 7. 验证与产物

### 7.1 验证独立于执行模式

验证回答“怎样证明结果”，风险模式回答“执行前需要什么保护”。两者必须
分离。

示例：

- 一个局部 Bug 可以保持 `direct`，同时运行完整相关测试。
- 一个只改配置但会写入生产的任务可能代码量极小，却属于 `guarded`。
- UI 修改可以通过截图或真实操作验证，但不因“UI”自动升级。

### 7.2 消费者驱动产物

创建额外 artifact 前必须能回答：

1. 谁会使用它；
2. 用它完成什么后续动作；
3. 为什么当前任务摘要不足；
4. 它应该落到哪个事实源或归档位置。

典型消费者：

| 消费者 | 产物 |
| --- | --- |
| Reviewer / QA | Walkthrough 或验证证据 |
| 产品维护者 | PRD 更新草稿 |
| 发布与运维人员 | Changelog / Release Handoff |
| 后续协作者 | 已确认的项目事实、决策或 runbook |
| 无明确消费者 | 不生成额外 artifact |

Memory 不再默认进入 Intake 和 Closeout。检索、提取、晋升和审计必须由用户
明确要求，或由当前任务提出候选后获得确认。当前指令、代码、运行时和正式
规格始终优先于历史记忆。

## 8. 场景与预期行为

| 场景 | 模式 | 能力 | 产物 | 是否暂停 |
| --- | --- | --- | --- | --- |
| 解释代码 | direct | 调查能力按需 | 无 | 否 |
| 修复局部 Bug | direct | 调查按需 | 无 | 否 |
| 修改多个内部文件并补测试 | direct | 无强制能力 | 无 | 否 |
| 修改共享 API 契约 | structured | contract-handoff | 有消费者时记录契约 | 有重大兼容选择时 |
| 方向已明确的关键用户旅程调整 | direct | e2e-verification 按需 | 验收需要时生成证据 | 无 |
| 关键旅程存在明显产品方向分歧 | structured | task-decomposer 或契约能力按需 | 有消费者时记录决策 | 分歧无法从项目事实消解时 |
| 多 Agent 修改同一共享域 | structured | shared-domain-arbiter | ownership 结论 | 存在无法自行消解的冲突时 |
| 生产数据库迁移 | guarded | release-handoff 按需 | 回滚、验证和交接证据 | 是 |
| 生成协作经验候选 | direct | collaboration-memory-maintainer | 本地候选 | 晋升共享事实前 |
| 创建并推送 release 分支 | guarded | git-flow-operator | Git 与发布证据 | 是 |

## 9. 兼容与版本迁移

### 9.1 版本决策

- `0.3.0` 保持为最后一个已发布版本。
- 当前未发布的 `0.4.0` 内容并入 `0.5.0`。
- `VERSION`、`manifest.json`、README、Changelog、release / SDD /
  evidence / walkthrough 路径统一改为 `0.5.0`。
- `0.4.0` 不作为已发布版本出现在公开版本历史中。
- 搬迁通过路径移动和内容修订完成；必须保留当前工作区已有协作记忆内容，
  不得直接删除未跟踪资产或用新模板覆盖。

### 9.2 旧模型映射

迁移说明提供一次性映射：

```text
consulting / micro -> direct
standard           -> structured
critical           -> guarded
```

映射只用于帮助旧用户理解，不进入 `Workflow/core.md` 的主决策逻辑。

### 9.3 Skill 兼容

- 已发布的 alias 暂时保留，并重定向到对应 capability。
- `session-snapshot-manager` 等历史 subflow 需逐项判断是保留为模板还是废弃。
- 新 wrapper 读取 capability 正文，不复制 workflow core。
- `1.0.0` 前通过使用证据决定删除哪些兼容入口。

## 10. 实施范围

### 10.1 新增

- `Workflow/core.md`
- capability schema 或说明文件
- workflow 场景 fixture
- `docs/sdd/tic-0.5.0-workflow-core-redesign.md`
- `docs/releases/0.5.0/` 相关发布与证据目录

### 10.2 重写

- `Global-Rules/coding-rules.md` 中的 workflow 部分
- `Skills/tic-workflow-orchestrator.md`
- canonical Skills 的 metadata 和触发说明
- `templates/AGENTS.md`
- `templates/codex-global/AGENTS.md`
- `templates/docs/ai-rules-usage.md`
- `README.md`
- `USAGE.md`
- `manifest.json`
- `VERSION`
- `CHANGELOG.md`
- `tools/validate-pack.sh`

### 10.3 保护性迁移

- `Skills/collaboration-memory-maintainer.md`
- `templates/ai-harness/memory/`
- `templates/tic-local/`
- bootstrap / update 脚本中的 memory 保留逻辑
- Project Adapter 的 `memory_root`

这些资产保留现有语义，但从默认 Intake / Closeout 路由中移除。

## 11. 验证策略

### 11.1 静态校验

`tools/validate-pack.sh` 至少检查：

- `Workflow/core.md` 存在且包含三档模式；
- 新项目模板不把 orchestrator 声明为普通任务必经入口；
- canonical capability 不包含 `risk_min` 或 `delegates_to`；
- capability metadata 包含 activation、artifacts 和 side_effects；
- 旧四档不会出现在新核心和新项目模板中；
- Memory、Adapter 和 bootstrap 的保护性逻辑仍通过；
- manifest、VERSION、Changelog 和发布目录版本一致。

### 11.2 场景 fixture

新增机器可读场景，至少记录：

```yaml
id: local-bug-fix
signals:
  reversible_local_change: true
  tests_required: true
expected:
  mode: direct
  checkpoint: false
  mandatory_artifacts: []
```

fixture 覆盖第 8 节的典型场景。当前版本先做 schema 和静态一致性校验，
后续可接入模型 eval，但不为了本次重设计引入新的运行时。

### 11.3 行为审查

发布前使用同一组任务分别对旧版与新版提示进行人工或模型对照，记录：

- 首次开始执行前的决策步骤数；
- 不必要的用户提问数；
- 自动生成的 artifact 数；
- 是否错误执行受保护动作；
- 是否选择了与任务无关的 Skill；
- 最终验证是否足以支持完成结论。

## 12. 验收标准

1. 普通本地任务无需调用 orchestrator 即可执行。
2. `direct` 默认不创建流程文档。
3. 多文件、测试、UI、API 或数据库关键词不能单独触发升级。
4. 风险升级只作用于产生风险的动作和必要范围。
5. canonical capability 不通过 metadata 自动级联其他 capability。
6. 每项额外产物都能指出消费者或明确的后续用途。
7. Memory 不再默认进入每个任务的 Intake 和 Closeout。
8. 受保护动作在没有明确授权时仍会暂停。
9. 当前 `0.4.0` 协作记忆成果完整迁入 `0.5.0`。
10. 安装、刷新、Adapter 与 Memory 保留测试继续通过。
11. 版本、模板、文档、manifest 和校验脚本使用同一 workflow 事实源。
12. 场景 fixture 能检测新旧档位混用、默认 orchestrator 和自动产物回归。

## 13. 后续决策

本设计不预先承诺合并或删除 canonical Skills。完成 `0.5.0` 行为迁移并积累
真实使用证据后，再根据以下条件决定模块调整：

- 是否总是由同一事实触发；
- 是否服务同一消费者；
- 是否共享相同输入输出生命周期；
- 是否经常独立变化；
- 合并后是否会增加默认上下文或隐式副作用。

这避免为了目录整洁制造新的巨型能力，也避免旧模块数量本身继续决定
workflow 的复杂度。
