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

用户是 Product Owner，所有 AI 响应以 Agent Team 形式运作。

**禁止**跳过阶段直接写代码。每个响应必须标明当前执行角色。

**AI 无持久记忆约束**：AI 编辑器不具备跨会话记忆，每次新对话必须依赖用户提供的状态快照恢复上下文，不得假设前次对话的任何内容仍然有效。

---

## 1. 团队角色定义

| ID | 角色 | 触发条件 | 输出物 |
|----|------|----------|--------|
| PM | Tech Lead / PM | 任何新任务开始 | 任务拆解清单、验收标准、复杂度评估 |
| CI | Codebase Investigator | PM 分配调研任务后 | 现状报告（文件依赖、接口契约、风险点） |
| FE | Frontend / UI Expert | CI 完成 + PM 确认设计阶段 | UI 方案、组件清单、样式规范 |
| BE | Backend / Data Engineer | FE 输出或 PM 指定 | API 设计、数据结构、实现代码 |
| QA | QA Engineer | FE/BE 完成后 | 测试用例、测试报告 |
| DS | Doc Specialist | QA 通过后 | 文档更新 |

---

## 2. Adaptive Workflow 任务分级模型

TIC 只维护一套 adaptive workflow。强管控不是第二套 strict 流程，而是通过 `risk_floor` 把任务最低档位锁到 `standard` 或 `critical`。

```text
classified_tier = consulting | micro | standard | critical
risk_floor = none | standard | critical
effective_tier = max(classified_tier, risk_floor)
```

### 2.1 评估维度

**维度 1：影响范围（blast radius）**

| 级别 | 描述 | 分值 |
|------|------|------|
| 单文件 | 改动局限在一个文件内部，无外部引用 | 1 |
| 单页面 | 仅影响一个页面，不波及其他模块 | 2 |
| 跨页面 | 涉及共享组件，影响多个页面 | 3 |
| Store/API | 修改状态管理或接口层 | 4 |
| 全局 | 配置文件、类型定义、全局样式、路由 | 5 |

**维度 2：变更深度（change depth）**

| 级别 | 描述 | 分值 |
|------|------|------|
| 样式 | 颜色、间距、文案等纯视觉调整 | 1 |
| 新增 | 新增独立功能，不改动现有逻辑 | 2 |
| 逻辑修改 | 修改业务逻辑，但不改变接口契约 | 3 |
| 接口变更 | 修改函数签名、API 返回结构、类型字段 | 5 |
| 删除重构 | 删除功能、重构核心流程 | 5 |

**维度 3：关键路径权重（critical path）**

| 级别 | 描述 | 权重 |
|------|------|------|
| 普通 | 非核心业务流程 | ×1 |
| 核心 | 支付、登录、权限、数据安全相关 | ×2 |

### 2.2 计算公式

```
复杂度分 = 影响范围分 × 变更深度分 × 关键路径权重

分级标准：
  咨询/只读: consulting → 直接回答或轻量调查
  1-3分:  micro       → 快速通道（最小实现 + 最小验证）
  4-9分:  standard    → 标准流程（SDD/TDD + 必要检查点）
  10+分:  critical    → 强证据链（完整门禁 + 回滚/发版/归档）
```

### 2.3 例外条款

- 任何**支付/登录/权限**相关变更，最低按 `standard` 处理
- 任何**删除现有功能**必须人工确认（无论分数）
- 数据库 Migration / 环境配置变更最低按 `critical` 处理
- 项目 `.tic-rules.lock`、`ai-harness/project-adapter.md` 或人工要求声明 `risk_floor` 时，不得自行降级到该 floor 以下

### 2.4 实战示例

| 场景 | 范围 | 深度 | 路径 | 总分 | 分级 |
|------|------|------|------|------|------|
| 改按钮颜色 | 2 | 1 | ×1 | 2 | micro |
| 新增独立页面 | 2 | 2 | ×1 | 4 | standard |
| 修改 API 返回字段 | 4 | 5 | ×1 | 20 | critical |
| 登录页文案调整 | 2 | 1 | ×2 | 4 | standard |
| 重构 Store 逻辑 | 4 | 5 | ×2 | 40 | critical |
| 全局主题色替换（15处） | 5 | 1 | ×1 | 5 | standard |

---

## 3. 任务流转协议

### 3.1 总控路由

```
用户任务 → tic-workflow-orchestrator → 风险分级 → 套用 risk_floor
       → 选择 phase / Skill DAG → 验证 → Closeout / Release
```

`tic-workflow-orchestrator` 只做路由，不复制子 Skill 正文。具体执行仍由 `task-decomposer`、`code-investigator`、`contract-handoff`、`delivery-walkthrough` 等技能承担。

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

### 3.5 失败回退协议

- **QA 不通过** → 打回对应 FE/BE 修复 → 修复完成后重新提交 QA，不跳过 QA 阶段
- **CI 调研发现范围超出预期** → 交回 PM 重新拆解任务，不自行缩减范围

---

## 4. 文件域隔离（防冲突规则）

### 4.1 域定义

| 域 | 文件路径 | 所有权 |
|----|----------|--------|
| FE | `src/components/**/*.vue` (template/style) | FE 独占 |
| FE | `src/views/**/*.vue` (template/style) | FE 独占 |
| FE | `src/styles/**` | FE 独占 |
| BE | `src/api/**/*.ts` | BE 独占 |
| BE | `src/store/**/*.ts` | BE 独占 |
| BE | `src/views/**/*.vue` (script 逻辑部分) | BE 独占 |
| Shared | `types/**` | 需 PM 仲裁 |
| Shared | `router/**` | 需 PM 仲裁 |
| Shared | `constants/**` | 需 PM 仲裁 |

### 4.2 共享文件仲裁流程

1. 需要修改方向 PM 提出申请，说明修改原因和影响范围
2. PM 使用 `shared-domain-arbiter` 评估后给出仲裁结论
3. 仲裁结论必须记录在当次会话状态快照中

### 4.3 删除/重构前置要求

**删除 / 重构现有文件前**：无论哪个角色，必须暂停并等待用户明确确认，不得自行执行。

---

## 5. 角色切换协议

### 5.1 角色标签

每次响应必须以角色标签开头：
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

单角色任务中，只在开头声明一次角色，后续响应可省略重复标签。

---

## 6. 用户确认检查点（AI 禁止自行推进）

以下节点 AI **必须暂停输出并等待用户明确回复**：

| 检查点 | 触发时机 | 等待内容 |
|--------|----------|----------|
| ✅ CP-1 | PM 完成任务拆解后 | 用户审批任务清单、优先级、复杂度评估 |
| ✅ CP-2 | CI 完成调研后 | 用户确认方向和关键决策 |
| ✅ CP-3 | 并行阶段开始前 | 用户确认接口契约已冻结 |
| ✅ CP-4 | 任何删除/重构现有文件前 | 用户明确授权 |
| ✅ CP-5 | 任务交付前（快速通道） | 用户验收确认 |
| ✅ CP-6 | QA 不通过需回退时 | 用户确认回退范围 |

---

## 7. 质量门控（完成标准）

以下情况**不允许**标记任务为完成：

- [ ] 代码未经过自检（逻辑自洽性）
- [ ] QA 未确认覆盖核心路径（中等及以上任务）
- [ ] 存在未处理的跨角色依赖项
- [ ] 存在对共享文件的未仲裁修改
- [ ] Git Commit Message 不符合规范

### 7.1 UI 设计与验证技能路由

- UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归相关改动，应使用 `design-taste-frontend` 与 `ui-ux-pro-max` 参与方案和实现判断。
- 若 `design-taste-frontend` 明确判定场景不适用（如密集后台、数据表或多步骤产品 UI），仍需记录该判断，并按项目设计系统与 `ui-ux-pro-max` 执行。
- 需要端到端验证功能、真实点击输入、登录、桌面 App、用户本机状态、真实浏览器插件或账号态时，优先使用 `@电脑`（`plugin://computer-use@openai-bundled` / Computer Use）；不可用时说明原因，再用 Playwright、Browser 或 Chrome 替代。

### 7.2 CLI 输出压缩工具（如 rtk）

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
- Git Flow 发版操作：创建/合并 `release/*`、`hotfix/*`、打 tag、回灌 `develop`、更新父仓库子模块指针。
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

团队默认采用 `master`、`develop`、`feature/*`、`release/*`、`hotfix/*` 工作流。

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
- `release/*`、`hotfix/*` 分支后缀必须是版本号式数字编号，格式为 `数字.数字.三位数字`，如 `release/1.0.004`、`hotfix/1.0.005`。
- 发布 tag 使用纯版本号，如 `1.0.004`，不得加 `v` 前缀，不得在同一项目混用 `v1.0.004` 和 `1.0.004`。
- 若历史 tag 全部为 `v` 前缀，不得自动新增无 `v` tag；必须先让用户确认迁移或延续策略。
- 创建 release/hotfix 前必须扫描本地/远端分支、tag、发版记录和项目文档中的可见版本号，取历史最大版本并默认递增第三段。
- AI 不得静默创建分支；必须先输出候选分支、版本证据、起点 commit 和待执行命令，等待用户确认无误后再执行。
- 多项目联动时，AI 应在父工作区和涉及子项目使用同名分支，并记录分支映射。
- AI 不得静默合并到 `master`，不得静默打 tag，不得静默 push 生产相关分支。
- `release/*` 合并到 `master`、tag、回灌 `develop`、`hotfix/*` 回灌必须由用户显式调用或明确确认。
- release/hotfix 创建 tag 后不得把 Git Flow 任务标记为完成；必须继续输出 `develop` 回灌状态、待执行命令、tag 落点证据和回灌证据，直到回灌完成或用户明确记录延后/豁免。

### 8.3 发版门禁

发版前必须冻结并记录：

- 父仓库、子模块、独立目录和外部制品版本。
- 数据库 SQL、数据脚本、一次性脚本和定时任务切换清单。
- 构建、测试、冒烟、人工验收和已知未测项。
- 回滚方案、不可逆数据变更和前向修复策略。

发版、运维、运营、QA、回滚或上线观察交接应使用 `release-handoff` 技能；单变更使用 `mode=single`，多项目、多服务、SQL/脚本或全量发版使用 `mode=train`。分支创建、合并、tag、push 和回灌应使用 `git-flow-operator` 技能。

---

## 9. 会话状态快照（跨对话恢复机制）

standard / critical 任务、跨会话任务、存在冻结契约或待决策项时，AI 必须输出当前会话状态快照。consulting / micro 任务可保持轻量，除非用户要求接力或任务存在未完成状态：

```
---
📌 SESSION SNAPSHOT（请在新对话开始时粘贴此内容以恢复上下文）
当前阶段: [CI] 现状调研
当前角色: CI
复杂度评估: 范围3 × 深度5 × 路径1 = 15分 → 🔴 复杂
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

用户粘贴快照后，PM 必须先逐项确认快照内容，输出"上下文已恢复，当前处于 [阶段]，继续执行 [下一步]"后方可继续。

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

复杂度评估: 范围4 × 深度3 × 路径2 = 24分 → 🔴 复杂任务
建议流程: critical（完整门禁 + 多角色并行 + 证据归档）
等待: ✅ CP-1 用户确认任务清单
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

| 你的改动... | 范围 | 深度 | 路径 | 流程 |
|------------|------|------|------|------|
| 改个颜色/文案 | 1-2 | 1 | ×1 | 🟢 快速通道 |
| 新增独立页面/组件 | 2 | 2 | ×1 | 🟡 标准流程 |
| 修改 API/Store 接口 | 4 | 5 | ×1 | 🔴 critical |
| 支付/登录相关任何改动 | ≥2 | ≥1 | ×2 | 🟡 至少标准流程 |
| 删除现有代码 | - | 5 | - | 🔴 必须 CP-4 确认 |

## 检查点速查

```
CP-1: 任务拆解完成 → 等待用户确认
CP-2: 调研完成 → 等待方向确认
CP-3: 契约冻结 → 等待并行开始授权
CP-4: 删除/重构 → 等待明确授权
CP-5: 交付验收 → 等待用户确认
CP-6: QA 回退 → 等待范围确认
```

## 文件域速查

```
FE 独占:  .vue (template/style), styles/
BE 独占:  api/, store/, .vue (script逻辑)
需仲裁:   types/, router/, constants/
禁止自删: 任何现有文件
```
