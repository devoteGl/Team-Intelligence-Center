# Team-Intelligence-Center 使用指南 📘

> 本文档是 Team-Intelligence-Center（AI 研发团队智能协作中枢）的完整使用手册。
> 阅读本文档后，你将了解如何将本工程引入你的项目，以及如何在日常开发中配合 AI 编辑器使用整套规则体系。

---

## 目录

- [1. 工程概述](#1-工程概述)
- [2. 目录结构](#2-目录结构)
- [3. 快速开始](#3-快速开始)
- [4. Global-Rules 使用说明](#4-global-rules-使用说明)
- [5. Prompts 使用说明](#5-prompts-使用说明)
- [6. Skills 使用说明](#6-skills-使用说明)
- [7. 工作流全景图](#7-工作流全景图)
- [8. 集成方式](#8-集成方式)
- [9. OpenSpec、Superpowers 与多工具统一范式](#9-openspecsuperpowers-与多工具统一范式)
- [10. 常见问题 FAQ](#10-常见问题-faq)

---

## 1. 工程概述

**Team-Intelligence-Center** 是一个面向 AI 编程编辑器的**协作规则引擎库**。它不包含任何业务代码，而是提供一整套标准化的：

- **协作角色定义**（PM / CI / FE / BE / QA / DS）
- **工作流流转协议**（任务拆解 → 调研 → 实现 → 验收 → 归档）
- **System Prompts**（AI-PRD 生成器、AI-PRD 编辑器）
- **执行能力模块**（Skills）

**核心价值**：消除 AI 编辑器在大型项目协作中的常见问题——输出发散、角色越界、信息失真、结构漂移。

---

## 2. 目录结构

```text
Team-Intelligence-Center/
│
├── README.md                           # 项目说明
├── USAGE.md                            # 本使用指南
│
├── Global-Rules/                       # 🔒 全局约束层（不可违反的底线）
│   └── coding-rules.md                 #    Git 规范 + AI Agent Team 多角色协议
│
├── Prompts/                            # 📝 指令层（场景化 System Prompt）
│   ├── ai-prd-generator.rules.md       #    新需求 PRD 生成器
│   └── ai-prd-editor.rules.md          #    存量项目 PRD 编辑器
│
└── Skills/                             # ⚡ 能力层（可复用执行模块）
    ├── code-investigator.md            #    [CI] 代码调研方法论
    ├── api-contract-freezer.md         #    [PM] 接口契约冻结流程
    ├── changelog-writer.md             #    [DS] 双层 Changelog 编写
    ├── prd-review-checklist.md         #    [QA] PRD 质量审查框架
    ├── session-snapshot-manager.md      #    [PM] 会话快照管理
    ├── candidate-rule-extractor.md     #    [CI/BE] 候选规则抽取
    ├── task-decomposer.md              #    [PM] 任务拆解方法
    ├── conflict-arbiter.md             #    [PM] 共享文件仲裁
    ├── fe-be-handoff.md                #    [FE/BE] 前后端交接
    ├── project-governance-bootstrap.md #    [PM/DS] 项目治理接入
    ├── release-ops-handoff.md          #    [PM/Release/DS] 单变更发版交接
    ├── git-flow-operator.md            #    [PM/Release] Git Flow 分支、合并、tag、回灌
    └── release-train-handoff.md        #    [PM/Release/DS] 全量多项目发版总控
```

### 三层架构关系

```text
┌──────────────────────────────────────────────────────┐
│                 Global-Rules（约束层）                  │
│            定义「什么不可以做」——行为边界                  │
├──────────────────────────────────────────────────────┤
│                  Prompts（指令层）                      │
│          定义「AI 是谁、怎么做」——角色身份                 │
├──────────────────────────────────────────────────────┤
│                  Skills（能力层）                       │
│       定义「遇到 X 场景，按此方法做」——执行能力            │
└──────────────────────────────────────────────────────┘
```

---

## 3. 快速开始

### 3.1 最简使用方式（5 分钟上手）

**适用场景**：个人项目或小团队，使用支持自定义 System Prompt 的 AI 编辑器。

1. **复制 `Global-Rules/coding-rules.md` 的内容**到你的 AI 编辑器的全局规则配置中
   - Cursor：放入项目根目录的 `.cursorrules` 文件
   - Windsurf：放入 `.windsurfrules` 文件
   - Claude Code / Gemini Code Assist：放入 `.rules` 目录或全局 System Prompt

2. **根据场景选择 Prompt**：
   - 新项目/新需求 → 使用 `ai-prd-generator.rules.md`
   - 老项目/文档补全 → 使用 `ai-prd-editor.rules.md`

3. **按需引用 Skills**：
   - 在对话中提示 AI："请按照 `code-investigator` 技能执行调研"
   - AI 将按照 Skill 中定义的标准化流程执行

### 3.2 团队集成方式（推荐）

**适用场景**：多人团队、多项目共享统一规范。

```bash
# 方式一：作为 Git Submodule 引入
cd your-project
git submodule add https://your-repo/Team-Intelligence-Center.git .ai-rules

# 方式二：直接复制到项目中
cp -r Team-Intelligence-Center/ your-project/.ai-rules/
```

然后在 AI 编辑器的配置中引用 `.ai-rules/` 目录下的规则文件。

---

## 4. Global-Rules 使用说明

### 4.1 coding-rules.md 包含什么

| 内容块 | 作用 | 何时生效 |
|--------|------|---------|
| Git Commit 规范 | 约束 AI 生成的 commit message 格式 | 每次代码提交 |
| AI Agent Team 角色定义 | 定义 PM/CI/FE/BE/QA/DS 六大角色 | 每次 AI 响应 |
| 任务流转协议 | 约束阶段不可跳跃 | 贯穿整个任务生命周期 |
| 文件域隔离 | 防止 FE/BE 并行时的代码冲突 | 并行开发阶段 |
| 检查点（CP-1~5） | 强制人工确认的节点 | 关键决策节点 |
| 会话快照 | 跨对话恢复上下文 | 每次响应结束 |

### 4.2 如何验证规则生效

规则加载成功后，AI 的每次响应应具备以下特征：
- ✅ 响应以角色标签开头，如 `⚙️ [Tech Lead/PM]`
- ✅ 新任务开始时，PM 输出任务清单
- ✅ 响应末尾附带 SESSION SNAPSHOT
- ✅ 在 CP 检查点主动暂停等待用户确认
- ✅ 不跨越阶段直接写代码

如果 AI 没有表现出以上行为，说明规则未正确加载，请检查配置。

---

## 5. Prompts 使用说明

### 5.1 何时使用 PRD Generator

**场景**：产品经理有一个新需求，需要 AI 帮助生成结构化 PRD。

**工作流**：
```text
PM 口述需求 → AI 结构化追问（7大维度）→ AI 生成 PRD 初稿
→ PM 审阅 → AI 修正 → PRD 终稿 → 自动拆分 FE/BE 任务清单
```

**使用方法**：
1. 将 `ai-prd-generator.rules.md` 的内容加载为 AI 的 System Prompt
2. 向 AI 描述你的需求（任意形式：文字、截图、功能列表、竞品参考均可）
3. AI 会先复述你的需求，然后进入追问阶段
4. 回答 AI 的追问后，AI 产出完整 PRD

### 5.2 何时使用 PRD Editor

**场景**：老项目缺少文档，需要 AI 帮助从代码中还原业务规则。

**工作流**：
```text
AI 读取代码 → 识别业务规则（标注可信度 S1~S4）→ 输出候选规则
→ PM 人工确认 → 转正的规则写入 main-prd.md
```

**使用方法**：
1. 将 `ai-prd-editor.rules.md` 的内容加载为 AI 的 System Prompt
2. AI 会按照交接协议（§13.4）自动读取项目中的 PRD 文件
3. 告诉 AI 当前的工作模式：
   - 整理模式（默认）：忠实整理已有信息
   - 补全模式：在已确认事实基础上补充
   - 演进模式：评估新需求的影响

### 5.3 两个 Prompt 可以同时使用吗？

**不建议同时使用**。它们面向不同场景：

| 维度 | Generator | Editor |
|------|-----------|--------|
| 适用项目 | 新项目/新功能 | 运行中的老项目 |
| 信息来源 | PM 的口述需求 | 代码+历史文档 |
| 输出物 | 全新 PRD | 补全/修复后的 PRD |
| AI 自由度 | 较高（可推导） | 较低（必须有证据） |

---

## 6. Skills 使用说明

### 6.1 Skill 总览

| Skill | 服务角色 | 触发场景 | 优先级 |
|-------|---------|---------|--------|
| `code-investigator` | CI | PM 分配调研任务后 | P0 |
| `api-contract-freezer` | PM | FE/BE 并行前需冻结契约 | P0 |
| `changelog-writer` | DS | QA 验收通过后归档 | P0 |
| `prd-review-checklist` | QA | PRD 产出后审查 | P1 |
| `session-snapshot-manager` | PM | 每次响应结束/新对话恢复 | P1 |
| `candidate-rule-extractor` | CI/BE | 调研阶段抽取业务规则 | P1 |
| `task-decomposer` | PM | 新任务开始时拆解 | P2 |
| `conflict-arbiter` | PM | FE/BE 需修改共享文件时 | P2 |
| `fe-be-handoff` | FE/BE | 契约冻结后开始实现前 | P2 |
| `project-governance-bootstrap` | PM/DS | 项目首次接入公司范式 | P0 |
| `release-ops-handoff` | PM/Release/DS | 单个功能或单个跨项目变更发版交接 | P0 |
| `git-flow-operator` | PM/Release | 新需求开分支、release/hotfix 合并、tag、回灌 | P0 |
| `release-train-handoff` | PM/Release/DS | 全量发版、多项目联动、SQL/脚本发版交付包 | P0 |

### 6.2 如何在对话中引用 Skill

在与 AI 对话时，你可以通过以下方式触发 Skill：

```text
# 方式一：直接指定
"请按照 code-investigator 技能，对 src/order/ 模块执行标准调研"

# 方式二：场景触发
"我需要冻结接口契约"  → AI 自动匹配 api-contract-freezer

# 方式三：角色触发
"切换到 CI 角色开始调研" → AI 自动匹配 code-investigator

# 方式四：项目接入
"请按照 project-governance-bootstrap 技能初始化本项目 AI 治理入口"
```

### 6.3 Skill 在工作流中的位置

```text
[PM] 任务拆解
  └─ Skill: task-decomposer
       │
[CI] 现状调研
  ├─ Skill: code-investigator
  └─ Skill: candidate-rule-extractor
       │
[PM] 方案制定 + 契约冻结
  ├─ Skill: api-contract-freezer
  └─ Skill: conflict-arbiter（并行期间按需触发）
       │
[FE/BE] 并行实现
  └─ Skill: fe-be-handoff
       │
[QA] 测试验收
  └─ Skill: prd-review-checklist
       │
[DS] 文档归档
  └─ Skill: changelog-writer
       │
[PM] 会话结束
  └─ Skill: session-snapshot-manager
```

---

## 7. 工作流全景图

### 7.1 标准需求开发流程

```text
用户提出需求
    │
    ▼
⚙️ [PM] 任务拆解
    │  ├─ 输出任务清单（task-decomposer）
    │  └─ 等待 CP-1：用户审批任务清单 ←── 🛑 必须等待
    │
    ▼
⚙️ [CI] 现状调研
    │  ├─ 执行标准调研（code-investigator）
    │  ├─ 抽取候选规则（candidate-rule-extractor）
    │  └─ 输出调研报告
    │
    ▼
🔄 [CI → PM] 交接
    │
    ▼
⚙️ [PM] 方案制定
    │  ├─ 基于调研报告制定方案
    │  ├─ 等待 CP-2：用户确认方向 ←── 🛑 必须等待
    │  ├─ 冻结接口契约（api-contract-freezer）
    │  └─ 等待 CP-3：用户确认契约冻结 ←── 🛑 必须等待
    │
    ▼
⚙️ [FE] + ⚙️ [BE] 并行实现
    │  ├─ 各自产出交接清单（fe-be-handoff）
    │  ├─ 基于契约独立开发
    │  ├─ 需修改共享文件时 → 仲裁（conflict-arbiter）
    │  └─ 各自完成自测
    │
    ▼
⚙️ [QA] 测试验收
    │  ├─ PRD 质量审查（prd-review-checklist）
    │  ├─ 功能验收测试
    │  ├─ 通过 → 流转到 DS
    │  └─ 不通过 → 打回 FE/BE（CP-5 确认回退范围）
    │
    ▼
⚙️ [DS] 文档归档
    │  ├─ 编写双层 Changelog（changelog-writer）
    │  └─ 同步规则到 main-prd.md
    │
    ▼
📌 输出 SESSION SNAPSHOT（session-snapshot-manager）
```

### 7.2 检查点速查表

| 检查点 | 触发时机 | 不暂停的后果 |
|--------|---------|------------|
| CP-1 | PM 完成任务拆解 | 可能执行不必要的任务 |
| CP-2 | CI 完成调研 | 可能基于错误理解推进 |
| CP-3 | 并行阶段开始前 | FE/BE 可能基于未确认的契约开发 |
| CP-4 | 删除/重构文件前 | 可能误删重要文件 |
| CP-5 | QA 不通过回退时 | 可能回退范围不正确 |

---

## 8. 集成方式

### 8.1 方式一：全局 System Prompt

将 `coding-rules.md` 的完整内容作为 AI 编辑器的全局 System Prompt 加载。

**优点**：所有对话自动生效，无需重复配置
**适用**：个人使用、单项目场景

### 8.2 方式二：Git Submodule

```bash
# 添加为子模块
git submodule add https://your-repo/Team-Intelligence-Center.git .ai-rules

# 更新子模块（获取最新规则）
git submodule update --remote

# 在 .gitignore 中排除（如不想跟踪子模块变更）
echo ".ai-rules" >> .gitignore
```

**优点**：多项目共享统一规范，版本可控
**适用**：团队协作、多项目场景

添加子模块后，可让 AI 执行项目治理接入技能：

```text
请读取 ai-rules/Team-Intelligence-Center/Skills/project-governance-bootstrap.md，
按该技能初始化本项目的 AGENTS、ai-rules-usage、ai-harness 和 openspec。
```

### 8.3 方式三：按需复制

将需要的文件手动复制到项目中：

```bash
# 只需要 Global-Rules
cp Global-Rules/coding-rules.md your-project/.cursorrules

# 需要 PRD 生成能力
cp Prompts/ai-prd-generator.rules.md your-project/PRD/

# 需要特定 Skill
cp Skills/code-investigator.md your-project/.ai-rules/
```

**优点**：灵活，可按需裁剪
**适用**：只需要部分功能的场景

---

## 9. OpenSpec、Superpowers 与多工具统一范式

如果团队同时使用 Codex、Cursor、Qoder、OpenCode 等不同 AI 编码工具，建议在业务项目中引入 OpenSpec 作为统一规格层。若团队已启用 Superpowers，可把它作为执行方法层，与 OpenSpec 搭配使用。

推荐阅读：

- [Design/development-paradigm-openspec-guide.md](./Design/development-paradigm-openspec-guide.md)：公司研发范式 + OpenSpec / Superpowers 落地指南。

### 9.1 推荐项目分层

```text
your-project/
├── ai-rules/Team-Intelligence-Center/ # 公司规则层
├── openspec/                          # OpenSpec 规格层
├── .superpowers/                       # Superpowers 临时执行状态，可加入 .gitignore
├── ai-harness/                        # 项目适配与记忆
├── docs/                              # PRD、契约、设计、外部服务
└── <业务工程目录>/                      # 后端、前端、后台等实现
```

`.superpowers/` 只用于 Superpowers 运行过程中的临时状态、头脑风暴材料或本地辅助产物。除非团队明确要保留某类输出，否则建议加入 `.gitignore`。

### 9.2 安装与初始化

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init --tools codex,cursor,qoder,opencode --force
```

生成后重启对应 IDE 或 AI 工具。

Superpowers 按 AI 工具分别安装。执行 `project-governance-bootstrap` 时会自动检测并尽力安装；Codex App、Codex CLI、Cursor 等需要图形插件市场或交互式命令的环境，会在接入报告中留下人工安装步骤。Gemini CLI、Factory Droid、GitHub Copilot CLI 等存在明确 CLI 命令时，可由 bootstrap 尝试执行。

### 9.3 终端与 AI 工具的区别

`opsx` 不是终端命令。终端使用：

```bash
openspec list
openspec show <change-name>
openspec validate --all --no-interactive
```

AI 工具中使用 `/opsx:*`：

```text
/opsx:explore
/opsx:propose
/opsx:apply
/opsx:archive
```

不需要每次对话都输入 `/opsx`。只有探索、立项、实现、归档等阶段切换时使用；普通沟通和小修小改可直接和 AI 对话。

### 9.4 OpenSpec 与 Superpowers 的分工

| 层级 | 工具 / 目录 | 职责 |
| --- | --- | --- |
| 公司规则层 | `Team-Intelligence-Center` | 角色、流程、Prompts、Skills、提交纪律 |
| 规格事实源 | `openspec/` | proposal、specs、design、tasks、archive |
| 执行方法层 | Superpowers | brainstorming、planning、TDD、debugging、code review、subagent-driven development |
| 长期文档层 | `docs/` | PRD、API 契约、外部服务、设计资料 |
| 项目适配层 | `ai-harness/` | 项目记忆、决策、runbook |

推荐链路：

```text
需求 / 问题
  -> /opsx:explore 或 /opsx:propose
  -> openspec/changes/<change-id>/
  -> Superpowers 执行计划、TDD、调试、review、并行开发
  -> 测试 / 构建 / 验证
  -> /opsx:sync 或 /opsx:archive
```

协作约束：

- 大需求、跨端、跨模块、接口契约变化：先走 OpenSpec。
- Superpowers 的计划、调试和 review 产物必须引用 OpenSpec change id 或任务来源。
- 稳定规格最终回写 `openspec/specs/`，不要把 `docs/superpowers/specs/` 当主事实源。
- 小修、小 bug 可直接用 Superpowers 的 TDD 或 debugging，不强制开 OpenSpec change。
- Superpowers 产生的临时状态默认不提交；确需保留的计划或复盘应归入 `docs/` 或 `ai-harness/memory/`。

### 9.5 与本规则库的关系

- `Team-Intelligence-Center` 定义角色、流程、Prompts、Skills 和工程纪律。
- OpenSpec 定义 proposal、specs、design、tasks、archive 等规格工件。
- Superpowers 定义 Agent 执行方法，例如计划、测试驱动、系统化调试、代码审查和子代理开发。
- 项目 `docs/` 保存长期 PRD、API 契约、外部服务和设计资料。
- 项目 `ai-harness/` 保存项目适配、长期记忆、决策和 runbook。

### 9.6 老项目接入

老项目不要求使用公司推荐的 go-zero、admin-template 或 Unibest 模板，也不要求先迁移技术栈。

推荐方式：

1. 保留现有代码结构。
2. 接入 `ai-rules/Team-Intelligence-Center/`。
3. 执行 `openspec init --tools codex,cursor,qoder,opencode --force`。
4. 如团队已启用 Superpowers，让 `project-governance-bootstrap` 自动检测并尽力安装；不能自动安装的工具按报告人工处理，并把 `.superpowers/` 加入 `.gitignore`。
5. 新建 `ai-harness/`，记录真实项目现状、决策和 runbook。
6. 用 `ai-prd-editor`、`code-investigator`、`candidate-rule-extractor` 反向梳理存量业务。
7. 从新需求开始走 `/opsx:propose -> Superpowers 执行 -> /opsx:archive`。

也可以直接让 AI 执行 `project-governance-bootstrap`，自动生成上述基础入口，再由人补齐 TODO。

详细说明见 [老项目接入模式](./Design/development-paradigm-openspec-guide.md#10-老项目接入模式)。

---

## 10. 常见问题 FAQ

### Q1：AI 没有按照角色协议工作怎么办？

**A**：检查以下几点：
1. `coding-rules.md` 是否完整加载（部分 AI 编辑器有字符限制）
2. 尝试在对话开头明确指令：「请严格按照 AI Agent Team Rules 工作」
3. 如果 AI 模型更换了，SESSION SNAPSHOT 可以帮助恢复上下文

### Q2：Skill 是自动触发还是需要手动调用？

**A**：目前需要手动引用。你可以：
- 在对话中直接提及 Skill 名称
- 通过角色切换间接触发（如切换到 CI 角色，AI 应自动参考 code-investigator）
- 将高频 Skill 的内容直接合并到 System Prompt 中

### Q3：可以只用 Skills 不用 Global-Rules 吗？

**A**：不推荐。三层架构是协同工作的：
- Global-Rules 定义了角色和流程边界
- Skills 依赖这些角色定义来确定「谁在什么时候执行」
- 缺少 Global-Rules 的约束，Skills 的执行时机和输出格式会失去一致性保障

### Q4：Superpowers 会替代 OpenSpec 吗？

**A**：不会。OpenSpec 是规格事实源，Superpowers 是执行方法层。大需求、跨端、跨模块、接口契约变化仍先走 `/opsx:propose`；Superpowers 用于计划、TDD、调试、代码审查和子代理执行。

### Q5：如何为自己的项目定制新的 Skill？

**A**：参考现有 Skill 的结构，每个 Skill 应包含：
1. **技能用途**：服务角色、触发时机、输出物
2. **核心原则**：绝对禁止项
3. **执行流程**：Step-by-Step 操作指南
4. **输出模板**：标准化的输出格式
5. **自检清单**：执行后的质量自查
6. **上下游衔接**：与其他角色的交接关系

### Q6：SESSION SNAPSHOT 丢失了怎么办？

**A**：如果无法恢复快照：
1. PM 需要重新评估当前项目状态
2. 检查 Git 提交历史了解最近的进展
3. 如有 PRD 文档，从文档中恢复任务上下文
4. 重新拆解任务（可能需要再次调研）

### Q7：这套规则适用于哪些 AI 编辑器？

**A**：任何支持 System Prompt 或项目级规则文件的 AI 编辑器，包括但不限于：
- Cursor（`.cursorrules`）
- Windsurf（`.windsurfrules`）
- Claude Code
- Gemini Code Assist
- GitHub Copilot（自定义指令）
- 其他支持 Markdown 规则加载的编辑器

---

> 📌 本指南将随项目演进持续更新。如有疑问或建议，欢迎提出 Issue 或直接修改本文档。
