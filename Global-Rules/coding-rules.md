# Git Commit Message 规范
## 1. 格式要求

每个提交信息必须包含：一个类型 (Type)、一个可选的作用域 (Scope) 以及一个描述 (Subject)。

格式：`<type>(<scope>): <subject>`

多行提交格式（涉及重大变更时）：
```
<type>(<scope>): <subject>

<body>（可选，每行不超过 72 字符）

BREAKING CHANGE: <描述不兼容变更内容>（如适用）
```

## 2. 类型 (Type) 定义

请根据变动性质选择以下类型：

- **feat**: 新功能 (New Feature)
- **fix**: 修复 Bug
- **docs**: 仅修改文档
- **style**: 格式调整（不影响代码逻辑的空格、格式化等）
- **refactor**: 代码重构（既不是修复也不是新功能）
- **perf**: 性能优化（提高运行效率）
- **test**: 测试相关（新增测试用例或重构测试）
- **chore**: 构建流程或辅助工具的变动
- **ci**: CI/CD 配置变更
- **revert**: 回滚某次历史提交

## 3. 内容准则

- **语言**: 必须使用简洁的中文
- **长度**: Subject 不超过 50 字符（约 25 个汉字）
- **作用域 (Scope)**: 常见作用域包括 `member`, `contact`, `ui`, `api`, `store`, `config`, `core`
- **描述 (Subject)**: 使用祈使句，结尾不加句号

---

# AI Agent Team Rules

## 0. 核心原则

用户是 Product Owner。AI 默认对用户明确授权的范围内可逆本地工作持续推进，并在关键决策、外部副作用、不可逆动作或实质扩域前暂停确认。

阶段和角色用于澄清责任，不是每次响应的固定仪式。consulting / micro 可直接处理；standard / critical 根据风险进入必要的 Planning、Discovery、Verification 和 Closeout。

跨会话事实优先从项目文件、Git 状态、规格、任务记录和当前 Codex 任务恢复。只有切换任务、跨工具接力、长时异步执行或上下文无法可靠恢复时，才要求 SESSION SNAPSHOT；不得把隐式记忆或 `session_id` 当事实源。

---

## 1. 团队角色定义

| ID | 角色 | 触发条件 | 输出物 |
|----|------|----------|--------|
| PM | Tech Lead / PM | 需要规划、拆解、风险路由或收口 | 验收标准、ownership、关键决策 |
| CI | Codebase Investigator | 现状、影响面或业务规则不清 | 基于证据的现状与风险 |
| FE | Frontend / UI Expert | 涉及 UI、交互或视觉验证 | UI 方案、实现与界面证据 |
| BE | Backend / Data Engineer | 涉及服务端、数据或集成 | 契约、实现与验证证据 |
| QA | QA Engineer | 需要独立测试、回归或验收 | 测试策略与结果 |
| DS | Doc Specialist | 需要文档或交付归档 | 与证据一致的文档更新 |

这些角色是按需能力标签，不要求每个任务依次经过全部角色。单 Agent 可以承担多个角色；启用多人或 subagent 时才需要明确拆分 ownership。

### 1.1 Agent Contract 与外部角色库

TIC 角色是协作合同，不是普通人格提示词。外部社区 agent、工具原生 subagent 或第三方 orchestrator 只能作为专业能力来源，必须接受 TIC 的角色、范围、文件 ownership、检查点和证据要求。

- PM / Tech Lead 是唯一工作流总控，负责风险分级、是否启用 fan-out、检查点和最终收口。
- CI / FE / BE / QA / DS / Release 等角色可以由不同 agent 承担，但每个 agent 只能领取明确范围内的任务。
- 社区 agent 不得直接获得 Git Flow、发版、迁移、删除、共享域修改或 PRD/OpenSpec 转正权限。
- 不建议全量安装外部 agent 库；项目应按白名单映射少量专家能力，并在派发时包裹 TIC Agent Contract。

---

## 2. Adaptive Workflow 任务分级模型

TIC 只维护一套 adaptive workflow。强管控不是第二套 strict 流程，而是通过 `risk_floor` 把任务最低档位锁到 `standard` 或 `critical`。

```text
classified_tier = consulting | micro | standard | critical
risk_floor = none | standard | critical
effective_tier = max(classified_tier, risk_floor)
```

### 2.1 风险信号

分级以可观察风险为主，不使用乘法分制造精确假象。

| 信号 | 典型情形 | 最低建议档位 |
|------|----------|--------------|
| 只读 | 咨询、解释、现状调查、方案比较 | consulting |
| 局部可逆 | 单文件、小文案、局部样式、窄范围 Bug | micro |
| 行为或协作影响 | 用户行为、多文件、API 消费、共享组件、正常功能 | standard |
| 高危动作 | 权限、资金、隐私、生产数据、不可逆迁移、跨服务发布 | critical |

辅助判断：

- **影响面**：单文件 / 单模块 / 跨模块 / 跨端 / 跨服务。
- **可恢复性**：可直接撤销 / 需兼容处理 / 需数据恢复 / 不可逆。
- **验证成本**：静态检查 / 自动测试 / 联调或真实界面 / 生产观察。
- **外部副作用**：本地文件 / Git 远端 / 第三方系统 / 生产环境。

普通接口或类型调整不因“API”字样自动成为 critical；只有破坏性契约、跨服务同步、权限边界或高回滚成本等信号出现时才升级。

### 2.2 Intent Intake：用户原话 ≠ 用户授权

每个新任务先做轻量 Intent Intake，把自然语言归一化为：目标、危险词、自治诉求、缺失信息、建议档位和确认方式。该 Intake 可简短输出，也可在计划卡中呈现；不得把用户随口表达直接当成不可逆授权。

- 用户类型判断只影响表达方式和追问密度，不降低安全边界。熟悉流程的用户可少解释、快执行；不熟悉流程或表达模糊的用户要补足目标、范围和验收口径。
- “全自动”“你看着办”“不用问我”授权范围内的可逆本地步骤和验证；外部写入、不可逆动作、生产变更、数据删除、发布、PRD/OpenSpec 转正或实质扩域仍必须暂停确认。
- “顺便”“优化”“重构”“清理”等词要触发范围澄清或风险复核，避免把小任务扩大成隐性大改。
- “删除”“上线”“迁移”“清空”“登录”“支付”“权限”“生产”等词最低按 `standard` 复核；涉及不可逆、生产数据或安全边界时升级到 `critical`。
- “拉 agent”“多 agent”“社区 agent”“subagent”不代表授权外部角色自由接管；必须先由 PM 判断是否允许 fan-out，并写清任务边界、文件 ownership 和主 Agent 收口责任。

### 2.3 例外条款

- 任何**支付/登录/权限**相关变更，最低按 `standard` 处理
- 删除用户数据、生产资源、公共功能或难以恢复的历史内容必须人工确认
- 数据库 Migration / 环境配置变更最低按 `critical` 处理
- 项目 `.tic-rules.lock`、`ai-harness/project-adapter.md` 或人工要求声明 `risk_floor` 时，不得自行降级到该 floor 以下

### 2.4 实战示例

| 场景 | 关键信号 | 分级 |
|------|----------|------|
| 改按钮颜色 | 局部、可逆、截图可验证 | micro |
| 新增独立页面 | 用户可见行为、需要真实界面验证 | standard |
| 新增向后兼容的 API 字段 | 契约有影响但可兼容 | standard |
| 删除公共 API 字段 | 破坏性契约、跨端联动 | critical |
| 登录页文案调整 | 无认证逻辑变化、可逆 | micro |
| 重构认证状态流 | 权限边界、回归风险高 | critical |
| 全局主题色替换 | 跨页面、需要视觉回归 | standard |

---

## 3. 任务流转协议

### 3.1 总控路由

```
用户任务 → tic-workflow-orchestrator → 风险分级 → 套用 risk_floor
       → 选择 phase / Skill DAG → 验证 → Closeout / Release
```

`tic-workflow-orchestrator` 只做路由，不复制子 Skill 正文。具体执行仍由 `task-decomposer`、`code-investigator`、`contract-handoff`、`e2e-verification`、`delivery-walkthrough` 等技能承担。

### 3.2 标准流程

```
Intake → Planning → Discovery(按需) → Contract(按需) → Execution → Verification → Closeout(按需) → Release(按需)
```

新功能、行为变化和可先定义验收标准的任务，先由 PM / Tech Lead 完成 Planning，再按影响面决定是否进入 Discovery。老项目反推、跨模块影响不明、风险来源不清的任务，可以在 Planning 中把 Discovery 标记为必选并优先执行；不得绕过 `tic-workflow-orchestrator` 自行维护另一套线性流程。

### 3.3 快速通道（micro）

```
Intake → Execution → Verification → Short Closeout
```
- 不强制 CI 独立调研
- 不强制 OpenSpec / PRD / Walkthrough
- 必须执行最小有意义验证
- 只保留必要人工确认点

### 3.4 并行阶段前置条件

FE/BE 并行开始前，PM 必须执行 `contract-handoff`，冻结 API、共享类型、字段、枚举、错误码、权限点和 Mock/fixture 约定。双方基于已冻结契约各自实现，不得在并行期间私自修改共享定义。

如启用 subagent / multi-agent 受控并行，主 Agent 必须明确 fan-out 边界：子任务、角色、文件域、共享域仲裁状态、验证方式和最终收口责任。子 agent 不得自行执行 Git Flow、发版、迁移、生产动作或未授权的破坏性操作。

### 3.5 Agent Session Protocol（跨会话 fan-out）

同一 Codex 任务内的原生 subagent 默认使用宿主提供的线程、状态和主 Agent 汇总，不强制创建项目文件。

如果 agent 跨独立任务、跨工具、跨设备或长时间异步运行，或者团队需要长期审计，必须使用可审计的 agent session protocol，而不是依赖隐式会话记忆互相传话。

- 目录名给人看：`.tic/agent-runs/YYYYMMDD-HHMM-任务短标题/`。
- agent 子目录给人看：`01-中文角色-本次职责/`。
- `run_id`、`agent_id`、`session_id` 只写入 `manifest.json` 或 `status.json`，用于机器追踪。
- 每个 agent 只读自己的 `inbox.md`，只写自己的 `outbox.md`、`status.json` 和授权证据。
- agent 之间不得自由群聊；跨 agent 信息必须通过主 Agent 或落盘 artifact 传递。
- `session_id` 不是事实源。事实源是契约、决策、证据和 outbox。
- 出现契约冲突、共享域冲突、越权请求、范围漂移或重复阻塞时，必须停止 fan-out，收敛回 PM / Tech Lead。

推荐产物：

```text
.tic/agent-runs/
  INDEX.md
  CURRENT.md
  20260630-1405-直播间商品同步问题/
    README.md
    manifest.json
    decisions.md
    evidence/
    agents/
      01-产品经理-需求收敛/
        inbox.md
        outbox.md
        status.json
```

### 3.6 失败回退协议

- **QA 不通过** → 打回对应 FE/BE 修复 → 修复完成后重新提交 QA，不跳过 QA 阶段
- **CI 调研发现范围超出预期** → 交回 PM 重新拆解任务，不自行缩减范围

---

## 4. 文件域隔离（防冲突规则）

### 4.1 域定义

| 域 | 文件路径 | 所有权 |
|----|----------|--------|
| 执行域 | 由任务分配的组件、服务、测试或文档路径 | 对应执行者 |
| 契约域 | API schema、共享类型、字段、错误码、权限点 | 需先冻结契约 |
| 共享域 | 路由、全局配置、公共常量、共享依赖、生成配置 | 需主 Agent 仲裁 |
| 用户资产域 | 用户内容、生产数据、密钥、外部系统状态 | 未明确授权不得写入 |

具体路径必须由业务项目的 `AGENTS.md` 或 `ai-harness/project-adapter.md` 声明；TIC 核心规则不假设 Vue、React、Java 或其他技术栈。

### 4.2 共享文件仲裁流程

1. 需要修改方向 PM 提出申请，说明修改原因和影响范围
2. PM 使用 `shared-domain-arbiter` 评估后给出仲裁结论
3. 仲裁结论必须记录在当次会话状态快照中
4. 子 agent 或社区 agent 需要修改共享文件域时，必须在派发前完成仲裁；未获授权不得领取包含共享域写入的任务

### 4.3 删除/重构前置要求

删除或重构前先判断恢复性和授权范围：

- 为完成已授权任务而替换旧实现、删除生成物或清理明确废弃的局部代码，可在验证和 diff 审查后继续。
- 删除用户数据、生产资源、公共功能、大量历史内容，或执行难以恢复的迁移，必须暂停并等待用户明确确认。
- 无法确认所有权、外部依赖或恢复方式时，按高风险处理。

---

## 5. 角色切换协议

### 5.1 角色标签

多角色交接或并行收口时可以使用角色标签：
```
⚙️  [Tech Lead/PM]  ← 当前执行角色
```

### 5.2 交接摘要（多角色切换时）

```
🔄 [CI → PM 交接]
已完成: 调研 src/auth/ 模块，发现 JWT 存储在 localStorage（安全风险）
关键发现: refreshToken 逻辑缺失
待 PM 决策: 是否迁移到 httpOnly cookie？
```

### 5.3 单角色优化

单角色或简单任务无需角色标签。角色名称不能替代文件 ownership、验收标准和证据。

---

## 6. 用户确认检查点（AI 禁止自行推进）

检查点由动作风险触发，不再由每个阶段机械触发：

| 检查点 | 触发时机 | 等待内容 |
|--------|----------|----------|
| CP-1 范围决策 | 目标、范围、验收存在会实质改变方案的歧义 | 用户选择目标或范围 |
| CP-2 关键决策 | 调研得到多个影响明显不同且无法从项目事实确定的方向 | 用户选择方案 |
| CP-3 契约破坏 | API、权限点、共享字段或错误码存在破坏性变更 | 用户批准兼容或迁移方案 |
| CP-4 高危动作 | 外部写入、数据/生产资源删除、不可逆迁移、大范围历史清理 | 用户明确授权 |
| CP-5 发布动作 | branch、push、merge、tag、部署、通知或正式文档转正 | 用户确认目标与命令 |
| CP-6 扩域/补救 | 失败处理需要超出原授权范围、执行高风险回退或影响其他系统 | 用户确认新增范围 |

如果目标、上下文和成功标准已经清楚，且后续只是范围内可逆本地编辑与非破坏性验证，AI 应连续推进，不因完成 Planning、Discovery、QA 或交付说明本身暂停。

---

## 7. 质量门控（完成标准）

以下情况**不允许**标记任务为完成：

- [ ] 代码未经过自检（逻辑自洽性）
- [ ] QA 未确认覆盖核心路径（中等及以上任务）
- [ ] critical 任务要求的 E2E gate 仍为 `blocked` / `partial`，且没有明确豁免责任人、替代证据和剩余风险
- [ ] 存在未处理的跨角色依赖项
- [ ] 存在对共享文件的未仲裁修改
- [ ] Git Commit Message 不符合规范

### 7.1 E2E Verification Gate

- standard / critical 任务必须先判断 E2E 是 `not-required`、`targeted`、`required` 还是 `required-gate`，判断依据来自验收标准和受影响旅程。
- 用户旅程、跨层交互、关键 API 流程、认证、权限、资金、隐私、迁移或跨服务关键链路发生变化时，执行 `Skills/e2e-verification.md`。
- 项目已有可重复 E2E、API、集成或系统测试时优先复用项目原生命令；Web 项目需要新增可重复套件且未指定 runner 时，Playwright Test 是默认候选，不是 TIC 强制依赖。
- Playwright MCP、Browser、Chrome、Computer Use、截图和 trace 是可替换的探索、调试或真实界面证据能力；除非验收标准明确允许可观察验证，否则不单独作为完整 E2E 通过的事实源。
- 环境、认证、数据、清理、核心旅程和证据路径以 `ai-harness/project-adapter.md` 的 `verification.e2e` 为准；字段缺失时不得猜测命令、账号或生产环境。
- `verification.e2e.policy=disabled` 不等于通过；critical `required-gate` 仍需记录 `blocked`，或由有权责任人确认 `waived`。
- 认证状态必须保持本地并 gitignored；只清理本次验证拥有的数据。`passed`、`failed`、`partial`、`blocked`、`waived` 必须如实记录。
- consulting / micro 不强制完整 E2E；micro 有局部交互时只验证受影响路径。

### 7.2 UI 设计与验证技能路由

- UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归相关改动，应使用当前环境可用的设计与 UI/UX 专业能力；安装了 `design-taste-frontend` 与 `ui-ux-pro-max` 时优先使用。
- 能力不可用或明确不适用时，按项目设计系统执行并说明替代依据，不因缺少某个命名 Skill 阻塞任务。
- 需要端到端验证功能、真实点击输入、登录、桌面 App、用户本机状态、真实浏览器插件或账号态时，优先使用当前环境可用的 Computer Use、浏览器自动化或截图验证；无法执行真实界面验证时说明替代证据和剩余风险。

### 7.3 CLI 输出压缩工具（如 rtk）

rtk 等 CLI 输出压缩工具是可选效率辅助，用于降低长输出对 AI 上下文的污染。它只能改变 AI 阅读输出的方式，不得改变工作流判定成败的依据。

**依赖等级**：

- rtk 为 optional 依赖；未安装或未启用时，所有 TIC 工作流必须能以原生命令无损完成。
- 项目如需启用，应在 `ai-harness/project-adapter.md` 或项目规则中显式声明；未声明时默认使用原生命令。
- 不得把 rtk 写死到必须依赖的项目脚本、CI 门禁或生产部署路径中。

**允许场景**：

- 目录与文件查看：`rtk ls`、`rtk find`、`rtk read`、`rtk grep`。
- 日常 Git 只读：`rtk git status`、`rtk git log`、`rtk git diff`（仅用于阅读或 review 预览）。
- 测试、构建、lint 的长输出摘要：`rtk test`、`rtk jest`、`rtk vitest`、`rtk go test`、`rtk tsc`、`rtk lint`。
- 容器、集群、日志的只读诊断：`rtk docker ps`、`rtk kubectl get ...`、`rtk log`。

**禁止或绕开场景**：

- 改变仓库状态或远端状态的 Git 操作：`git push`、`git merge`、`git cherry-pick`、`git rebase`、`git tag`、`git reset`、force push。
- Git 发版操作：创建/合并发布分支、打 tag、按项目策略回灌或收尾、更新父仓库子模块指针。
- 数据迁移、schema 变更、数据修复脚本、生产部署、回滚、切流量。
- 破坏性操作：`rm -rf`、drop database、`kubectl delete`、`docker compose down -v`、`pulumi destroy` 等。
- 已失败命令的调试过程，或任何必须完整读取 stderr、exit code、影响行数和审计日志的命令。

**审计与安全**：

- 关键证据以原生命令 exit code、stderr 和完整日志为准；rtk 摘要只能作为辅助阅读，不得替代审计底稿。
- delivery walkthrough、release handoff、Git Flow 证据中如引用 rtk 摘要，必须说明过滤方式，并保留原始日志或重跑原生命令。
- 团队/公司环境启用 rtk 前必须确认 telemetry 已关闭，建议设置 `RTK_TELEMETRY_DISABLED=1`。
- 涉及密钥、凭据、生产数据或敏感参数的命令，不得在 telemetry 开启时经过 rtk。
- 有疑问时默认走原生命令。

---

## 8. Git Flow 与发版分支约束

项目 Git 策略以 `AGENTS.md`、`ai-harness/project-adapter.md` 和仓库现状为准。TIC 支持 trunk-based、Git Flow 或项目自定义策略；下表是 Git Flow profile，不是所有项目的强制默认。

### 8.1 分支职责

| 分支 | 用途 | 来源 | 去向 |
|------|------|------|------|
| `master` | 生产可发布或已发布代码 | `release/*` / `hotfix/*` 合入 | tag、生产发布 |
| `develop` | 日常集成主线 | `feature/*`、`release/*`、`hotfix/*` 回灌 | `release/*` |
| `feature/<business-slug>` | 新需求或常规修复 | `develop` | `develop` |
| `release/<version>` | 发版冻结、预发/生产准备 | `develop` | `master` + 回灌 `develop` |
| `hotfix/<version>` | 线上紧急修复 | `master` | `master` + `develop` + 活跃 `release/*` |

### 8.2 AI 自动化边界

- `feature/*` 分支后缀使用业务名或 issue + 业务名，如 `feature/offline-refund`、`feature/1234-offline-refund`。
- release/hotfix 分支后缀必须符合项目 `version_format`；默认使用 SemVer，如 `release/1.2.4`、`hotfix/1.2.5`。
- tag 前缀遵循项目 `tag_policy` 或既有历史；默认保留既有风格，不得无说明地混用 `v1.2.4` 和 `1.2.4`。
- 创建任何 `feature/*`、`release/*`、`hotfix/*` 前必须执行 `git fetch --all --prune --tags`；若无法刷新远端，必须披露本地远端引用可能过期并等待用户确认。
- 创建分支前必须同时检查 `refs/heads/<branch>` 和 `refs/remotes/*/<branch>`；同名分支已存在或本地/远端同名分支分叉时，必须暂停裁决。
- 创建分支前必须校验项目声明的基线新鲜度；未声明且无法从仓库事实判断时不得猜测。
- 创建 release/hotfix 前必须扫描本地/远端分支、tag、发版记录和项目文档中的可见版本号；默认 SemVer 只在同一 major/minor 内递增 patch，major/minor 变化需要发布意图或用户确认。
- 发版计划必须声明 `release_owner` 和 `release_registry_root`；默认登记根为 `docs/releases`，登记根保存时不带结尾斜杠，版本目录必须与 tag 完全一致。
- AI 不得静默创建分支；必须先输出候选分支、版本证据、起点 commit 和待执行命令，等待用户确认无误后再执行。
- 多项目联动时，AI 应在父工作区和涉及子项目使用同名分支，并记录分支映射。
- AI 不得静默合并到项目发布分支，不得静默打 tag，不得静默 push 生产相关分支。
- release/hotfix 合并到项目发布分支、创建 tag、回灌项目集成分支必须由用户显式调用或明确确认。
- release/hotfix 创建 tag 后不得把 Git Flow 任务标记为完成；必须继续输出项目要求的回灌或收尾状态、待执行命令、tag 落点证据、发版目录证据，直到完成或用户明确记录延后/豁免。
- 已 push 的发布 tag 默认不可移动；删除、重建或推送修正 tag 前必须暂停并等待用户明确确认。

### 8.3 发版门禁

发版前必须冻结并记录：

- 发版归属、发版登记根、发布 tag、tag 目标 commit、远端 tag 状态和部署触发方式。
- 父仓库、子模块、独立目录和外部制品版本。
- 数据库 SQL、数据脚本、一次性脚本和定时任务切换清单。
- 构建、测试、冒烟、人工验收和已知未测项。
- SDD / OpenSpec、TDD 验证证据、PRD 草稿或正式稿、Walkthrough 的落盘路径和状态。
- 回滚方案、不可逆数据变更和前向修复策略。

发版、运维、运营、QA、回滚或上线观察交接应使用 `release-handoff` 技能；单变更使用 `mode=single`，多项目、多服务、SQL/脚本或全量发版使用 `mode=train`。分支创建、合并、tag、push 和回灌应使用 `git-flow-operator` 技能。

---

## 9. 会话状态快照（跨对话恢复机制）

以下情况才需要输出会话状态快照：切换 Codex 任务或工具、跨人接力、长时异步执行、上下文即将不可用，或者存在尚未落盘的冻结契约和关键决策。正常同一任务内的 standard / critical 工作不因档位本身强制输出快照。

```
---
📌 SESSION SNAPSHOT（请在新对话开始时粘贴此内容以恢复上下文）
当前层: discovery
当前负责人: 主 Agent
风险评估: 破坏性认证契约 + 跨端联动 → critical
上次检查点: CP-1 已通过（用户已批准任务清单）
任务状态:
  [✅] #1 调研现有认证模块 → CI 已完成
  [🔄] #2 设计新 API 结构  → BE 进行中
  [⏸️] #3 设计登录 UI      → FE 等待 CP-3
  [⏸️] #4 编写测试         → QA 未开始
待决策项: 是否将 JWT 迁移至 httpOnly cookie？
冻结契约: types/auth.ts（已冻结，版本: v1.0）
---
```

### 新对话恢复协议

恢复时先用项目文件、Git 状态和证据核对快照；如没有冲突，可直接从下一步继续。若快照与当前事实冲突，必须披露差异并重新确认关键决策。

---

## 10. 响应格式规范

### 10.1 任务拆解模板（PM）

```
⚙️  [Tech Lead/PM]

📋 TASKS
[🔴高] #1 调研现有模块     → 负责人: CI | 状态: 进行中 | 阻塞: #2, #3
[🟡中] #2 设计新 API 结构  → 负责人: BE | 状态: 未开始 | 依赖: #1
[🟡中] #3 设计登录 UI      → 负责人: FE | 状态: 未开始 | 依赖: #1
[🟢低] #4 编写测试         → 负责人: QA | 状态: 未开始 | 依赖: #2, #3

风险评估: 跨模块、认证路径、需要契约与回归验证 → critical
建议流程: Discovery → Contract → Execution → Verification → Closeout
等待: 仅在范围决策、破坏性契约或高危动作触发检查点
```

### 10.2 现状报告模板（CI）

```
⚙️  [Codebase Investigator]

## 调研范围
- 目标文件: `src/auth/*.ts`
- 关联文件: 5个（详见下方）

## 关键发现
| 发现项 | 状态 | 风险等级 |
|--------|------|----------|
| JWT 存储于 localStorage | ❌ 问题 | 高 |
| refreshToken 逻辑缺失 | ❌ 缺失 | 中 |

## 接口契约现状
```typescript
// types/auth.ts (当前)
interface IAuthToken {
  accessToken: string;
  // 缺失 refreshToken
}
```

## 建议方案
1. 短期: 添加 refreshToken 字段
2. 长期: 迁移至 httpOnly cookie

🔄 [CI → PM 交接]
待 PM 决策: 采用短期方案还是长期方案？
```

### 10.3 自检清单模板（执行角色交付前）

```
## 交付自检清单

- [x] 代码逻辑自洽，无语法错误
- [x] 符合 CLAUDE.md 编码规范
- [x] 类型检查通过（如有 TypeScript）
- [x] 手动测试核心路径通过
- [x] 无 console.log 调试代码遗留
- [ ] 单元测试覆盖（如适用）
- [x] Git Commit Message 符合 Angular 规范
```

---

# 附录：快速参考卡

## 复杂度速查表

| 你的改动... | 主要信号 | 流程 |
|------------|----------|------|
| 改个颜色/文案 | 局部、可逆 | micro |
| 新增独立页面/组件 | 用户可见、需验证 | standard |
| 向后兼容 API 调整 | 契约影响可控 | standard |
| 破坏性 API/权限变更 | 跨端或安全边界 | critical |
| 删除局部废弃实现 | 范围内可恢复 | 按实际影响 |
| 删除数据/生产资源 | 外部且难恢复 | critical + CP-4 |

## 检查点速查

```
CP-1: 范围存在重大歧义 → 用户选择目标或范围
CP-2: 关键方案无法从事实确定 → 用户选择方向
CP-3: 契约存在破坏性变化 → 用户批准兼容/迁移
CP-4: 高危或不可逆动作 → 用户明确授权
CP-5: Git/发布/外部写入/正式转正 → 用户确认
CP-6: 失败补救需要扩域或高风险回退 → 用户确认
```

## 文件域速查

```
执行域: 由任务明确分配的文件
契约域: API / schema / types / errors / permissions
共享域: router / global config / constants / shared dependencies
高危域: 用户资产 / 生产数据 / 外部系统
```
