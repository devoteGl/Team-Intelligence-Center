# 组织研发范式 + OpenSpec / Superpowers 落地指南

本文面向组织内所有业务项目，说明如何把 `Team-Intelligence-Center`、OpenSpec、Superpowers、项目级规则入口和不同 AI 编码工具组合成统一研发范式。

结论先行：这套组合可以作为组织的统一开发范式。关键不是绑定某一个 AI 工具，而是让所有工具共同遵守同一套动作边界、规格事实源、契约和验证原则。TIC Workflow Core 是轻量决策入口；OpenSpec 在需要持久规格时承载规格事实；Superpowers 是可选的 Agent 执行方法层；Orchestrator 只用于显式复杂规划或旧版迁移。

## 1. 范式分层

推荐每个项目按五层组织：

| 层级 | 目录建议 | 职责 |
| --- | --- | --- |
| 组织规则层 | `ai-rules/Team-Intelligence-Center/` | 通用角色、流程、Prompts、Skills、提交纪律 |
| OpenSpec 规格层 | `openspec/` | 活跃变更、稳定规格、设计说明、任务清单、归档 |
| Superpowers 执行层 | AI 工具插件 / `.superpowers/` | 头脑风暴、计划、TDD、调试、代码审查、子代理执行 |
| TIC Workflow Core | `Workflow/core.md` | direct-by-default、动作升级、受保护动作、验证与产物边界 |
| 项目适配层 | `ai-harness/` | 当前项目的角色映射、记忆、决策、runbook |
| 长期文档层 | `docs/` | PRD、API 契约、外部服务、设计资料、验收记录 |

业务代码仍然放在各项目自己的工程目录。范式只管协作链路和产物边界，不替代业务工程本身。`.superpowers/` 是运行态辅助目录，默认不作为长期规格来源。

## 2. 业务工程边界

TIC 开源版不提供业务脚手架或示例工程，也不推荐固定的后端、管理后台或用户前端技术栈。团队继续使用自己的工程体系；TIC 只要求规则、规格、契约、验证、归档和项目适配入口清晰。

业务工程自身决定代码起点，OpenSpec、Superpowers 和组织规则决定交付过程。一个通用接入结构如下：

```text
your-project/
├── ai-rules/Team-Intelligence-Center/ # 组织规则子模块
├── openspec/                          # OpenSpec 规格层
├── .superpowers/                       # Superpowers 本地运行态，可加入 .gitignore
├── ai-harness/                        # 当前项目适配与记忆
├── docs/                              # PRD、契约、设计、外部服务
└── <business-code>/                   # 项目既有或自选业务代码目录
```

目录名可按项目实际调整，但职责边界应保持稳定。

## 3. 自适应开发路径

```text
需求 / 问题
  -> Workflow Core 判断当前动作
  -> direct：本地实现 + 相称验证
  -> structured（按需）：
       /opsx:explore / proposal / contract-handoff / execution plan
  -> Superpowers（按需）：计划、TDD、调试、review、子代理开发
  -> 验证：测试、构建、联调、真实界面或 E2E
  -> guarded（仅受保护动作）：外部写入、生产、Git、发布或正式晋升
  -> 长期规格 / PRD / memory / archive（仅有明确消费者时）
```

对应到组织角色：

| 阶段 | 组织角色 | 关键产物 |
| --- | --- | --- |
| 目标和边界 | PM / Tech Lead | 完成标准、受保护动作 |
| 现状调研（按需） | CI | 影响范围、候选规则、风险清单 |
| 契约冻结（按需） | PM + FE + BE | API 契约、字段、错误码、Mock fixture |
| 实现 | FE / BE + 可选执行能力 | 代码与必要测试 |
| 验证 | QA / Reviewer | 支持交付结论的证据、未测风险 |
| 长期同步（按需） | 明确消费者 | specs、PRD、Changelog、memory 或 archive |

## 4. OpenSpec 与 Superpowers 安装方案

OpenSpec 和 Superpowers 都是可选外部系统。团队明确选择后，应按各自当前
官方文档独立安装和初始化；TIC 不代替包管理器或插件管理器，也不把某个
版本和安装命令固化成项目 bootstrap 的隐式副作用。

如果团队使用 Superpowers，建议在业务项目 `.gitignore` 中加入：

```gitignore
.superpowers/
```

确需保留的执行计划、复盘或验收记录，应写入有明确消费者的 `docs/` 或
对应 OpenSpec change，不直接把 `.superpowers/` 当长期文档库。只有经过
明确 memory 维护动作确认具有长期复用价值时，才写入
`ai-harness/memory/`。

如果业务项目已经以 submodule 引入本仓库，推荐先让 AI 执行接入技能，自动生成项目根入口和治理目录：

```text
请读取 ai-rules/Team-Intelligence-Center/Skills/project-governance-bootstrap.md，
按该技能初始化本项目的 AI 治理入口。
```

如果项目暂时只想初始化 OpenSpec 目录，不生成 AI 工具命令：

```bash
openspec init --tools none --force
```

如果团队希望给所有支持的 AI 工具生成入口：

```bash
openspec init --tools all --force
```

升级 OpenSpec CLI 后，重新生成工具侧命令和 skills：

```bash
openspec update --force
```

查看当前 OpenSpec 配置：

```bash
openspec config list
openspec schemas
openspec templates
```

## 5. 推荐项目配置

初始化后，每个项目应维护 `openspec/config.yaml`。示例：

```yaml
schema: spec-driven

context: |
  Project: your-project
  Business code: keep the existing project structure
  Governance: company AI rules live in ai-rules/Team-Intelligence-Center/
  Project adaptation: ai-harness/ stores project memory, decisions, and runbooks
  Documentation: docs/ stores PRDs, API contracts, vendor docs, and design notes
  Agent execution: Superpowers may be used for brainstorming, planning, TDD, debugging, code review, and subagent-driven development.
  Change process: proposal -> specs -> design -> tasks -> implement -> verify -> archive
  Collaboration:
    - Codex, Cursor, Qoder, and OpenCode must follow the same artifact flow
    - tools may differ, but specs, contracts, review gates, and archive steps must stay consistent
    - OpenSpec remains the source of truth for specs; Superpowers execution artifacts must reference the OpenSpec change when one exists

rules:
  proposal:
    - State affected subprojects.
    - Call out rollback risk for cross-end or contract changes.
    - Note whether docs, specs, or memory must be updated.
  specs:
    - Describe observable behavior and acceptance criteria.
    - Keep stable current behavior under openspec/specs.
  design:
    - Explain boundary ownership, dependencies, and integration order.
    - Include migration or rollback notes for riskier changes.
  tasks:
    - Split work by role and subproject.
    - Include verification steps for each surface.
    - If using Superpowers, bind execution plans and reviews to the OpenSpec change id.
```

## 6. AI 工具入口

`opsx` 不是终端可执行命令。终端入口叫 `openspec`，例如：

```bash
openspec list
openspec show <change-name>
openspec status --change <change-name>
openspec validate --all --no-interactive
```

`/opsx:*` 是 AI 编码工具里的斜杠命令或 skill 入口。常用命令：

| 命令 | 使用时机 |
| --- | --- |
| `/opsx:explore` | 想法不清楚，需要先调研、比较方案、澄清边界 |
| `/opsx:propose` | 新需求、大改动、跨端改动、接口变化，需要建立 OpenSpec change |
| `/opsx:apply` | 已有 OpenSpec change，准备按 tasks 实现 |
| `/opsx:sync` | 需要把变更规格同步回主规格，具体是否生成取决于 OpenSpec profile |
| `/opsx:archive` | 验证完成，需要归档 change |

不用每句话都输入 `/opsx`。推荐规则：

- 平时正常和 AI 对话。
- 只有探索、立项、实现、同步、归档这些阶段切换时使用 `/opsx:*`。
- 小修小改、错字、局部 bug 可直接处理。
- 跨边界契约变化先对齐契约；需要持久规格和多方评审时再使用
  `/opsx:propose`。

## 7. 各工具生成位置

OpenSpec 会按所选工具生成 commands 和 skills。常见位置：

| 工具 | 生成位置 |
| --- | --- |
| Codex | 项目内 `.codex/skills/openspec-*`；部分版本会把命令放到 `$CODEX_HOME/prompts/` |
| Cursor | `.cursor/skills/openspec-*`、`.cursor/commands/opsx-*.md` |
| Qoder | `.qoder/skills/openspec-*`、`.qoder/commands/opsx/*.md` |
| OpenCode | `.opencode/skills/openspec-*`、`.opencode/commands/opsx-*.md` |

生成后需要重启对应 IDE 或 AI 工具，斜杠命令才会刷新。

## 8. 与 Team-Intelligence-Center 的接合

OpenSpec 负责“规格和变更工件”，`Team-Intelligence-Center` 负责“角色和工程纪律”。

| OpenSpec 工件 | 应接合的组织规则 |
| --- | --- |
| `proposal.md` | `Prompts/ai-prd-generator.rules.md`、`Skills/task-decomposer.md` |
| `specs/` | `Prompts/ai-prd-editor.rules.md`、`Skills/code-investigator.md` 的 candidate rules 子流程 |
| `design.md` | `Skills/code-investigator.md`、`Skills/shared-domain-arbiter.md` |
| `tasks.md` | `Skills/task-decomposer.md`、`Skills/contract-handoff.md` |
| API 契约 | `Skills/contract-handoff.md` |
| 验收 | `Skills/prd-review-checklist.md` |
| 归档 | 有版本消费者时使用 `Skills/changelog-writer.md` 或 `Skills/release-handoff.md` |
| 项目接入 | `Skills/project-governance-bootstrap.md` |

落地项目不应复制或改写组织规则原文。推荐作为 submodule 接入：

```bash
git submodule add <Team-Intelligence-Center-repo-url> ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

升级组织规则时，只提交 submodule 指针变更，并在项目变更说明里记录升级影响。

## 9. 与 Superpowers 的接合

Superpowers 负责“Agent 如何把任务做扎实”，不负责替代 OpenSpec 规格层。推荐把它接在 OpenSpec 的 `tasks.md` 后面，用于计划、TDD、调试、review 和子代理并行执行。

| Superpowers 能力 | 推荐接合点 | 产物归属 |
| --- | --- | --- |
| brainstorming | `/opsx:explore` 前后，需求仍不清楚时 | 结论写回 proposal 或 `docs/PRD/` |
| writing-plans | `openspec/changes/<id>/tasks.md` 已有后 | 计划必须引用 change id；长期计划归 `docs/` |
| test-driven-development | `/opsx:apply` 实现阶段 | 测试代码和验证记录归业务仓库 |
| systematic-debugging | bug 修复或回归定位 | 复现条件写回 spec、runbook 或缺陷记录 |
| requesting-code-review | 实现完成、验收前 | review 结论进入验收记录或 change 备注 |
| subagent-driven-development | 多端、多模块可并行任务 | 子任务必须按 OpenSpec tasks 或明确计划拆分 |

### 9.1 协作原则

- OpenSpec 是规格事实源；Superpowers 是执行方法层。
- TIC Workflow Core 决定动作边界；Orchestrator 只在用户明确需要复杂计划或治理审计时使用。
- 有 OpenSpec change 时，Superpowers 的计划、调试、review 产物必须引用该 change id。
- `docs/superpowers/specs/` 不能成为第二套主规格；稳定行为应同步回 `openspec/specs/`。
- `.superpowers/` 默认视为本地运行态目录，除非团队明确要求，不提交。
- 小修、小 bug 可以直接用 Superpowers 的 TDD / debugging，不强制创建 OpenSpec change。
- 跨端、跨模块或接口契约变化需要先明确共享契约；只有需要持久规格时才创建 OpenSpec change。

### 9.2 Guardrailed Multi-Agent / 受控并行

多 Agent 是执行层 fan-out 能力，不是 TIC 的顶层工作流。TIC 不维护 agent 市场，TIC 维护 agent 上岗制度。

启用 fan-out 前，主 Agent 必须依据 `Workflow/core.md` 明确目标、边界、每个执行方的 ownership、共享契约、验证要求和受保护动作。用户说“全自动”只表示希望 AI 少打扰，不表示授权外部 agent 执行删除、迁移、发版、Git Flow、生产配置或规格转正等高危动作。

Agent Contract：
- TIC canonical role：PM / CI / FE / BE / QA / DS / Release / Reviewer 是稳定协作合同，定义职责、检查点、文件 ownership 和交付证据。
- 社区 agent：只作为专业能力 adapter，例如前端、后端、安全、测试、代码审查、专项领域顾问。
- 工具原生 subagent：只执行主 Agent 分配的有界任务，不拥有动作模式裁决、
  契约冻结、共享域仲裁、最终验收、发版或 Git Flow 权限。
- 外部 orchestrator：可参考其角色库或局部执行能力，不得替代 Workflow Core 和主 Agent 的收口责任。

Fan-out 准入：
- Discovery 可并行做多模块只读调研。
- Execution 只有在任务可独立验证、文件域清晰、契约已冻结时才能 fan-out。
- Verification 可并行跑测试、lint、构建、截图或专项 review，但主 Agent 必须收口证据。
- API、字段、错误码、共享类型或权限点会跨边界改变时，使用 `contract-handoff`。
- 多执行方确实会并发写入同一共享域时，使用 `shared-domain-arbiter`。
- 发生跨任务、跨工具、长时异步或审计协作时，记录参与方、任务范围、可写文件域、验证证据和未测风险。

跨会话执行：
- 每个 agent 单独开会话时，必须使用 `agent-session-protocol` 或项目等价 mailbox。
- run 目录使用“时间 + 任务短标题”，agent 目录使用“序号 + 中文角色 + 本次职责”，方便用户查找。
- `session_id` 只作为追踪字段写入 manifest/status，不作为上下文事实源。
- 主 Agent 只读取结构化 outbox、status 和 evidence；agent 之间不得自由群聊。
- 发现契约冲突、越权请求、范围漂移、重复阻塞或证据不足时，停止 fan-out 并收敛回单线主控。

不建议全量安装社区 agent 库。推荐按项目白名单维护少量映射，例如：

| TIC 角色 | 可适配的社区专家能力 | 使用边界 |
| --- | --- | --- |
| CI | codebase onboarding / investigator | 只读调研，输出证据和候选规则 |
| FE | frontend developer | 只写授权前端域，不改共享契约 |
| BE | backend architect / developer | 只写授权后端域，不私改接口契约 |
| QA / Reviewer | code reviewer / testing evidence collector | 输出问题、证据和未测项，不代替最终验收 |
| Security | appsec / security reviewer | 只做专项风险评审，阻断项交回 PM |
| Multi-Agent Advisor | multi-agent systems architect | 评审拓扑和故障模式，不接管总控 |

### 9.3 推荐组合链路

```text
需求 / 问题
  -> OpenSpec /opsx:explore 或 /opsx:propose
  -> openspec/changes/<change-id>/
  -> Superpowers writing-plans / TDD / debugging / code review
  -> 测试、构建、联调、人工验收
  -> OpenSpec /opsx:sync 或 /opsx:archive
```

### 9.4 不建议的做法

- 先写 `docs/superpowers/specs/`，再让 OpenSpec 被动补录。
- 把 Superpowers 的临时头脑风暴材料当成已确认需求。
- 绕过 OpenSpec 直接修改跨端契约。
- 把同一需求同时维护在 OpenSpec specs 和另一套 Superpowers spec 中。
- 把 `tic-workflow-orchestrator` 写成复制所有子 Skill 模板的巨型 Skill。
- 让社区 agent 库或工具原生 orchestrator 替代 TIC Agent Contract。
- 全量安装外部 agent 后由模型在没有 ownership 和验证边界时自由派发任务。

## 10. 老项目接入模式

老项目不要求使用指定业务脚手架，也不要求先做技术栈迁移。

接入目标是把现有项目纳入统一的规则、规格、契约、验证和归档链路。不要为了接入范式而重构业务代码。

### 10.1 接入原则

- 保留现有技术栈和目录结构。
- 先记录真实现状，不先写理想架构。
- 先接入规则层和规格层；Superpowers 执行层可按团队工具现状启用。
- 新需求从接入日起走新链路，历史债务分批治理。
- 不因接入 OpenSpec 或 Superpowers 触发大规模重构。

### 10.2 推荐落地结构

```text
legacy-project/
├── ai-rules/Team-Intelligence-Center/ # 组织规则子模块
├── openspec/                          # 从当前真实行为开始沉淀
├── .superpowers/                       # 可选，本地运行态，默认 gitignore
├── ai-harness/                        # 老项目适配、记忆、决策、runbook
├── docs/                              # 补齐 PRD、契约、外部服务说明
└── <legacy-code>/                      # 原有业务代码，保持现状
```

如果老项目无法调整根目录，也可以把 `ai-rules/`、`openspec/`、`ai-harness/`、`docs/` 放在仓库根目录下的治理目录中，但需要在 README 里写清楚位置。

### 10.3 老项目接入步骤

1. 添加组织规则：

   ```bash
   git submodule add <Team-Intelligence-Center-repo-url> ai-rules/Team-Intelligence-Center
   git submodule update --init --recursive
   ```

2. 初始化 OpenSpec：

   ```bash
   openspec init --tools codex,cursor,qoder,opencode --force
   ```

3. 如团队明确选择 Superpowers，按当前工具的官方插件机制独立安装，并按
   团队约定处理 `.superpowers/`；TIC bootstrap 不安装插件。

4. 执行项目治理接入 Skill：

   ```text
   请读取 ai-rules/Team-Intelligence-Center/Skills/project-governance-bootstrap.md，
   按该技能初始化本项目的 AI 治理入口。
   ```

5. 新建或校准项目适配层：

   ```text
   ai-harness/
   ├── project-adapter.md
   └── memory/
       ├── project-context.md
       ├── decision-log.md
       └── runbooks.md
   ```

6. 反向梳理项目现状：

   - 使用 `Prompts/ai-prd-editor.rules.md` 整理存量 PRD 和业务事实。
   - 使用 `Skills/code-investigator.md` 调研目录、技术栈、模块边界。
   - 使用 `Skills/code-investigator.md` 的 candidate rules 子流程从代码中抽取候选业务规则。

7. 建立第一版主规格：

   - 确定的现状写入 `openspec/specs/`。
   - 不确定的现状写入候选清单，不直接写成稳定事实。
   - 接口、字段、枚举、错误码写入 `docs/api-contracts/`。

8. 对需要持久规格的新需求使用 OpenSpec 路径：

   ```text
   /opsx:propose -> 契约冻结 -> /opsx:apply -> Superpowers 执行 -> 验证 -> /opsx:archive
   ```

### 10.4 老项目现状可信度

存量项目常有“代码、文档、线上行为不一致”的问题。建议按可信度标记事实：

| 等级 | 来源 | 处理方式 |
| --- | --- | --- |
| S1 | 已验证的线上行为、自动化测试、真实接口响应 | 可写入 `openspec/specs/` |
| S2 | 当前代码路径和数据库结构可直接证明 | 可写入 specs，但注明来源 |
| S3 | 老文档、注释、历史需求单 | 先写入候选规则，等待确认 |
| S4 | 口头描述、AI 推测、无法复现的行为 | 不写入稳定规格，只做风险记录 |

### 10.5 老项目改造边界

老项目接入时默认禁止：

- 为了套模板而迁移框架。
- 未冻结契约就改跨端接口。
- 未验证现状就删除旧逻辑。
- 把 AI 推测直接写成稳定规格。
- 一次性补全所有历史文档后才允许开发。

推荐做法：

- 每次新需求顺手补齐受影响模块的事实。
- 每次修 bug 都把复现条件和修复后的行为写入对应 spec。
- 每次接口变动都更新 `docs/api-contracts/`。
- 反复出现且确认具有长期复用价值的问题，显式维护到 runbook 或
  decision log。

## 11. 上手检查清单

如果项目明确采用完整 OpenSpec / Superpowers 组合，再检查：

- `ai-rules/Team-Intelligence-Center/` 已存在并固定版本。
- `Skills/project-governance-bootstrap.md` 已执行，或等价治理入口已人工补齐。
- `openspec/config.yaml` 已包含项目上下文。
- `openspec/specs/` 至少有一个工作区或核心领域 spec。
- `openspec validate --all --no-interactive` 能通过。
- Codex、Cursor、Qoder、OpenCode 中至少团队实际使用的工具已生成 `/opsx:*` 入口。
- 如果团队启用 Superpowers，它已通过独立安装流程就绪，且
  `.superpowers/` 已按团队约定处理。
- Superpowers 产物边界已写明：OpenSpec 是规格事实源，Superpowers 是执行方法层。
- `docs/` 已声明 PRD、API 契约、外部服务文档位置。
- `ai-harness/` 已声明项目角色映射、记忆和 runbook 位置。
- README 已说明如何启动、验证、提交和归档。

老项目还应额外检查：

- README 已说明现有技术栈和真实启动方式。
- `ai-harness/project-adapter.md` 已映射原有模块和职责边界。
- 至少一个核心业务流程已完成现状调研。
- 不确定规则没有写入稳定 spec。
- 新需求已开始使用 OpenSpec change 流程。

## 12. 常见问题

### Q1：为什么终端执行 `opsx` 报 command not found？

因为 `opsx` 不是终端命令。终端使用 `openspec`，AI 工具内使用 `/opsx:*`。

### Q2：每次和 AI 对话都要打 `/opsx` 吗？

不需要。`/opsx:*` 是阶段入口。正常沟通直接说需求，只有探索、立项、实现、同步、归档时使用。

### Q3：OpenSpec 会替代 PRD 吗？

不会。OpenSpec 管活跃变更和稳定规格；PRD 仍然放在项目 `docs/PRD/`。复杂需求通常先 OpenSpec，再沉淀 PRD。

### Q4：Superpowers 会替代 OpenSpec 吗？

不会。Superpowers 负责让 Agent 更稳地执行计划、测试、调试和 review；OpenSpec 仍然负责变更规格和稳定行为事实。两者冲突时，以 OpenSpec 和项目人工确认事实为准。

### Q5：已有老项目能接吗？

可以。先把组织规则作为 submodule 接入，再 `openspec init --tools ...`，如团队使用 Superpowers 则安装对应插件，最后用 `ai-prd-editor` 和 `code-investigator` 反向梳理现状，逐步把稳定行为写入 `openspec/specs/`。

### Q6：不同工具生成的命令数量不一致怎么办？

先执行：

```bash
openspec config list
openspec update --force
```

命令数量由 OpenSpec profile、workflow 和 delivery mode 决定，不要求所有工具文件数量完全相同；要求的是团队遵守同一套 OpenSpec 工件和组织规则。

### Q7：老项目一定要迁移到指定业务脚手架吗？

不需要。老项目优先接入规则层、规格层、项目适配层和文档层。技术栈迁移应作为独立变更评估，不应作为接入范式的前置条件。

## 13. 参考资料

- [OpenSpec README](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec OPSX Workflow](https://github.com/Fission-AI/OpenSpec/blob/main/docs/opsx.md)
- [OpenSpec Supported Tools](https://github.com/Fission-AI/OpenSpec/blob/main/docs/supported-tools.md)
- [OpenSpec Commands](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
- [Superpowers README](https://github.com/obra/superpowers)
