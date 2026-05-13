# 公司研发范式 + OpenSpec 落地指南

本文面向公司内所有业务项目，说明如何把 `Team-Intelligence-Center`、OpenSpec、项目模板和不同 AI 编码工具组合成统一研发范式。

结论先行：这套组合可以作为公司的统一开发范式。关键不是绑定某一个 AI 工具，而是让所有工具共同遵守同一套规则、规格、契约、验证和归档链路。

## 1. 范式分层

推荐每个项目按四层组织：

| 层级 | 目录建议 | 职责 |
| --- | --- | --- |
| 公司规则层 | `ai-rules/Team-Intelligence-Center/` | 通用角色、流程、Prompts、Skills、提交纪律 |
| OpenSpec 规格层 | `openspec/` | 活跃变更、稳定规格、设计说明、任务清单、归档 |
| 项目适配层 | `ai-harness/` | 当前项目的角色映射、记忆、决策、runbook |
| 长期文档层 | `docs/` | PRD、API 契约、外部服务、设计资料、验收记录 |

业务代码仍然放在各项目自己的工程目录。范式只管协作链路和产物边界，不替代业务工程本身。

## 2. 模板组合

公司可以把以下模板作为多端项目的默认基座：

| 端 | 推荐模板 | 主要职责 |
| --- | --- | --- |
| 后端 | [go-zero](https://go-zero.dev/zh-cn/) | API、鉴权、业务规则、回调、定时任务、数据一致性 |
| 管理后台 | [NexusAI/admin-template](https://ycbl.xadazhihui.cn:18443/NexusAI/admin-template) | 运营后台、权限、配置、数据看板 |
| 用户前端 | [Unibest](https://unibest.tech/) | H5、小程序、移动端交互、端侧状态流 |

模板决定工程起点，OpenSpec 和公司规则决定交付过程。一个推荐项目结构如下：

```text
your-project/
├── ai-rules/Team-Intelligence-Center/ # 公司规则子模块
├── openspec/                          # OpenSpec 规格层
├── ai-harness/                        # 当前项目适配与记忆
├── docs/                              # PRD、契约、设计、外部服务
├── backend/                           # go-zero 服务端
├── frontend-admin/                    # 管理后台
└── frontend-client/                   # Unibest 用户端
```

目录名可按项目实际调整，但职责边界应保持稳定。

## 3. 标准开发链路

```text
需求 / 问题
  -> /opsx:explore       # 可选：先探索和澄清
  -> /opsx:propose       # 生成 OpenSpec 变更工件
  -> docs/PRD            # 必要时沉淀 PRD
  -> docs/api-contracts  # 跨端需求先冻结契约
  -> /opsx:apply         # 按 tasks 实现
  -> 验证                # 测试、构建、联调、人工验收
  -> openspec/specs      # 稳定行为同步为主规格
  -> ai-harness/memory   # 稳定事实、决策、踩坑回写
  -> /opsx:archive       # 归档完成变更
```

对应到公司角色：

| 阶段 | 公司角色 | 关键产物 |
| --- | --- | --- |
| 需求拆解 | PM / Tech Lead | proposal、PRD、验收标准 |
| 现状调研 | CI | 影响范围、候选规则、风险清单 |
| 契约冻结 | PM + FE + BE | API 契约、字段、错误码、Mock fixture |
| 并行实现 | FE / BE | 各端代码、交接清单、自测记录 |
| 验收 | QA | 测试结果、回归风险、缺陷记录 |
| 归档 | DS | specs、Changelog、memory、archive |

## 4. OpenSpec 安装方案

OpenSpec 官方要求 Node.js 20.19.0 或更高版本。推荐全局安装：

```bash
npm install -g @fission-ai/openspec@latest
```

进入业务项目根目录后初始化：

```bash
cd your-project
openspec init --tools codex,cursor,qoder,opencode --force
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
  Backend: backend (go-zero)
  Admin: frontend-admin
  Client: frontend-client (Unibest)
  Governance: company AI rules live in ai-rules/Team-Intelligence-Center/
  Project adaptation: ai-harness/ stores project memory, decisions, and runbooks
  Documentation: docs/ stores PRDs, API contracts, vendor docs, and design notes
  Change process: proposal -> specs -> design -> tasks -> implement -> verify -> archive
  Collaboration:
    - Codex, Cursor, Qoder, and OpenCode must follow the same artifact flow
    - tools may differ, but specs, contracts, review gates, and archive steps must stay consistent

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
- 跨端、跨模块、契约变化、回滚风险较高的需求必须先 `/opsx:propose`。

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

| OpenSpec 工件 | 应接合的公司规则 |
| --- | --- |
| `proposal.md` | `Prompts/ai-prd-generator.rules.md`、`Skills/task-decomposer.md` |
| `specs/` | `Prompts/ai-prd-editor.rules.md`、`Skills/candidate-rule-extractor.md` |
| `design.md` | `Skills/code-investigator.md`、`Skills/conflict-arbiter.md` |
| `tasks.md` | `Skills/task-decomposer.md`、`Skills/fe-be-handoff.md` |
| API 契约 | `Skills/api-contract-freezer.md` |
| 验收 | `Skills/prd-review-checklist.md` |
| 归档 | `Skills/changelog-writer.md`、`Skills/session-snapshot-manager.md` |

落地项目不应复制或改写公司规则原文。推荐作为 submodule 接入：

```bash
git submodule add <Team-Intelligence-Center-repo-url> ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

升级公司规则时，只提交 submodule 指针变更，并在项目变更说明里记录升级影响。

## 9. 老项目接入模式

老项目不要求使用 go-zero、admin-template 或 Unibest，也不要求先做技术栈迁移。

接入目标是把现有项目纳入统一的规则、规格、契约、验证和归档链路。不要为了接入范式而重构业务代码。

### 9.1 接入原则

- 保留现有技术栈和目录结构。
- 先记录真实现状，不先写理想架构。
- 先接入规则层和规格层，再逐步补文档。
- 新需求从接入日起走新链路，历史债务分批治理。
- 不因接入 OpenSpec 触发大规模重构。

### 9.2 推荐落地结构

```text
legacy-project/
├── ai-rules/Team-Intelligence-Center/ # 公司规则子模块
├── openspec/                          # 从当前真实行为开始沉淀
├── ai-harness/                        # 老项目适配、记忆、决策、runbook
├── docs/                              # 补齐 PRD、契约、外部服务说明
└── <legacy-code>/                      # 原有业务代码，保持现状
```

如果老项目无法调整根目录，也可以把 `ai-rules/`、`openspec/`、`ai-harness/`、`docs/` 放在仓库根目录下的治理目录中，但需要在 README 里写清楚位置。

### 9.3 老项目接入步骤

1. 添加公司规则：

   ```bash
   git submodule add <Team-Intelligence-Center-repo-url> ai-rules/Team-Intelligence-Center
   git submodule update --init --recursive
   ```

2. 初始化 OpenSpec：

   ```bash
   openspec init --tools codex,cursor,qoder,opencode --force
   ```

3. 新建项目适配层：

   ```text
   ai-harness/
   ├── project-adapter.md
   └── memory/
       ├── project-context.md
       ├── decision-log.md
       └── runbooks.md
   ```

4. 反向梳理项目现状：

   - 使用 `Prompts/ai-prd-editor.rules.md` 整理存量 PRD 和业务事实。
   - 使用 `Skills/code-investigator.md` 调研目录、技术栈、模块边界。
   - 使用 `Skills/candidate-rule-extractor.md` 从代码中抽取候选业务规则。

5. 建立第一版主规格：

   - 确定的现状写入 `openspec/specs/`。
   - 不确定的现状写入候选清单，不直接写成稳定事实。
   - 接口、字段、枚举、错误码写入 `docs/api-contracts/`。

6. 从新需求开始执行标准链路：

   ```text
   /opsx:propose -> 契约冻结 -> /opsx:apply -> 验证 -> /opsx:archive
   ```

### 9.4 老项目现状可信度

存量项目常有“代码、文档、线上行为不一致”的问题。建议按可信度标记事实：

| 等级 | 来源 | 处理方式 |
| --- | --- | --- |
| S1 | 已验证的线上行为、自动化测试、真实接口响应 | 可写入 `openspec/specs/` |
| S2 | 当前代码路径和数据库结构可直接证明 | 可写入 specs，但注明来源 |
| S3 | 老文档、注释、历史需求单 | 先写入候选规则，等待确认 |
| S4 | 口头描述、AI 推测、无法复现的行为 | 不写入稳定规格，只做风险记录 |

### 9.5 老项目改造边界

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
- 每次踩坑都回写 `ai-harness/memory/runbooks.md` 或 `decision-log.md`。

## 10. 上手检查清单

新项目接入完成前，至少检查：

- `ai-rules/Team-Intelligence-Center/` 已存在并固定版本。
- `openspec/config.yaml` 已包含项目上下文。
- `openspec/specs/` 至少有一个工作区或核心领域 spec。
- `openspec validate --all --no-interactive` 能通过。
- Codex、Cursor、Qoder、OpenCode 中至少团队实际使用的工具已生成 `/opsx:*` 入口。
- `docs/` 已声明 PRD、API 契约、外部服务文档位置。
- `ai-harness/` 已声明项目角色映射、记忆和 runbook 位置。
- README 已说明如何启动、验证、提交和归档。

老项目还应额外检查：

- README 已说明现有技术栈和真实启动方式。
- `ai-harness/project-adapter.md` 已映射原有模块和职责边界。
- 至少一个核心业务流程已完成现状调研。
- 不确定规则没有写入稳定 spec。
- 新需求已开始使用 OpenSpec change 流程。

## 11. 常见问题

### Q1：为什么终端执行 `opsx` 报 command not found？

因为 `opsx` 不是终端命令。终端使用 `openspec`，AI 工具内使用 `/opsx:*`。

### Q2：每次和 AI 对话都要打 `/opsx` 吗？

不需要。`/opsx:*` 是阶段入口。正常沟通直接说需求，只有探索、立项、实现、同步、归档时使用。

### Q3：OpenSpec 会替代 PRD 吗？

不会。OpenSpec 管活跃变更和稳定规格；PRD 仍然放在项目 `docs/PRD/`。复杂需求通常先 OpenSpec，再沉淀 PRD。

### Q4：已有老项目能接吗？

可以。先把公司规则作为 submodule 接入，再 `openspec init --tools ...`，最后用 `ai-prd-editor` 和 `code-investigator` 反向梳理现状，逐步把稳定行为写入 `openspec/specs/`。

### Q5：不同工具生成的命令数量不一致怎么办？

先执行：

```bash
openspec config list
openspec update --force
```

命令数量由 OpenSpec profile、workflow 和 delivery mode 决定，不要求所有工具文件数量完全相同；要求的是团队遵守同一套 OpenSpec 工件和公司规则。

### Q6：老项目一定要迁移到公司推荐模板吗？

不需要。老项目优先接入规则层、规格层、项目适配层和文档层。技术栈迁移应作为独立变更评估，不应作为接入范式的前置条件。

## 12. 参考资料

- [OpenSpec README](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec OPSX Workflow](https://github.com/Fission-AI/OpenSpec/blob/main/docs/opsx.md)
- [OpenSpec Supported Tools](https://github.com/Fission-AI/OpenSpec/blob/main/docs/supported-tools.md)
- [OpenSpec Commands](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
