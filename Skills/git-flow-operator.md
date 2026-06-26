---
schema: tic_skill.v1
id: git-flow-operator
status: canonical
phase: execution
role: PM / Tech Lead / Release Manager
risk_min: standard
inputs:
  - git_operation_request
  - branch_context
outputs:
  - git_flow_confirmation_card
  - git_operation_evidence
requires: []
delegates_to: []
---

# Git Flow Operator（分支与发版合并操作技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager**
- 触发时机：新需求开始、创建 feature/release/hotfix 分支、功能收尾、发版合并、tag、push、hotfix 回灌
- 输出物：分支操作计划、分支映射、合并/tag 门禁、执行证据、回灌记录
- 适用场景：单仓库 Git Flow、多项目联动 Git Flow、子模块/独立目录版本冻结、release/hotfix 收尾

---

## 0. 核心原则

AI 不得静默创建分支、合并、tag 或 push。分支创建必须先给出候选分支、命名依据和执行命令，等待用户确认无误后再执行。

Git Flow 的状态变更和最终证据必须使用原生 `git` 命令或保留 raw/proxy 原始输出。rtk 等输出压缩工具只可用于只读预览（如 status/log/diff 的辅助阅读），不得替代创建分支、合并、tag、push、回灌、子模块指针更新和最终审计证据。

**分支与 tag 命名规则**：

- `feature/<business-slug>`：用于新需求和常规修复，后缀表达业务目的或 issue，例如 `feature/offline-refund`、`feature/1234-offline-refund`。
- `release/<version>`：用于发版冻结，`<version>` 必须匹配 `数字.数字.三位数字`，例如 `release/1.0.004`。
- `hotfix/<version>`：用于线上紧急修复，版本格式同 release，例如 `hotfix/1.0.005`。
- 发布 tag 使用纯版本号：`<version>`，例如 `1.0.004`。不得添加 `v` 前缀。
- 禁止同一项目混用 `1.0.004` 和 `v1.0.004` 两种 tag 风格；发现混用时必须暂停并让用户裁决。
- 若历史 tag 全部为 `v` 前缀，不得自动新增无 `v` tag；先输出历史风格和目标风格的冲突，让用户确认迁移或延续策略。
- 禁止纯流水号 release/hotfix：`release/012`、`hotfix/013`。

**版本推导必须先扫描历史最大值**：

1. `git fetch --all --prune`（若网络或权限不允许，说明缺口）。
2. 扫描本地和远端分支：`release/[0-9]+.[0-9]+.[0-9]{3}`、`hotfix/[0-9]+.[0-9]+.[0-9]{3}`。
3. 扫描可见 tag、`docs/releases/`、发版记录和项目约定中的版本号。
   - `docs/releases/` 仅把匹配 `数字.数字.三位数字` 的一级目录视为版本目录，例如 `1.0.004`。
   - 日期、业务名或其他非版本号目录只能作为历史遗留资料，不参与最大版本推导。
4. 按 `major.minor.patch` 数值比较取历史最大版本，默认递增第三段，生成候选分支。
5. 若没有任何历史版本，默认从 `1.0.001` 开始；若第三段已到 `999`，暂停让用户确认是否进位。
6. 输出版本证据和候选命令，等待用户确认。

**Release 目录主键**：

- 发版交接目录一律以版本号为一级入口：`docs/releases/<version>/`。
- `<version>` 必须与本次 release/hotfix tag 完全一致，格式为 `数字.数字.三位数字`，例如 `1.0.004`。
- 禁止在 `docs/releases/` 下新建日期、业务名、需求名或其他非版本号一级目录。
- 业务名、需求名或变更主题应放入版本目录内的 `changes/<business-slug>/`，具体结构由 `Skills/release-handoff.md` 定义。
- 版本号是发版容器唯一主键，对齐分支、tag、父仓库子模块指针和发版证据；业务名只是容器内容。

**必须显式确认**：

- 创建任何 `feature/*`、`release/*`、`hotfix/*` 分支。
- 合并到 `master` 或 `develop`。
- 创建 tag。
- push 任意分支或 tag。
- hotfix 回灌 `develop` 和活跃 `release/*`。
- 任何会覆盖、丢弃或重写历史的操作。

---

## 1. 分支职责

| 分支 | 用途 | 来源 | 去向 |
|------|------|------|------|
| `master` | 生产可发布或已发布代码 | `release/*` / `hotfix/*` 合入 | tag、生产发布 |
| `develop` | 日常集成主线 | `feature/*`、`release/*`、`hotfix/*` 回灌 | `release/*` |
| `feature/<business-slug>` | 新需求或常规修复 | `develop` | `develop` |
| `release/<version>` | 发版冻结、预发/生产准备 | `develop` | `master` + 回灌 `develop` |
| `hotfix/<version>` | 线上紧急修复 | `master` | `master` + `develop` + 活跃 `release/*` |

---

## 2. 分支创建确认流程

创建分支前必须输出确认卡，不得直接执行：

```markdown
## Git Flow 分支创建确认

- 目标类型：feature / release / hotfix
- 目标基线：develop / master / <commit>
- 命名依据：业务名 / issue / 历史最大版本
- 已扫描来源：本地分支、远端分支、tag、docs/releases、发版记录
- 历史最大版本：<release/hotfix/tag 适用；feature 可写不适用>
- 候选分支：<feature/business-slug | release/version | hotfix/version>
- 候选 tag：<release/hotfix 适用；无 v 前缀>
- 起点 commit：<sha>
- 待执行命令：git switch -c <branch> <base>
- 等待用户确认：是
```

用户确认前，只能输出计划和证据；不得创建分支。

---

## 3. 新需求开始

### 3.1 单项目

1. 确认当前仓库为目标项目。
2. 确认当前分支或目标基线为 `develop`。
3. 从用户需求、issue 编号或 OpenSpec change id 推导候选 `feature/<business-slug>`。
4. 等待用户确认。
5. 用户确认后创建分支并记录起点 commit。

### 3.2 多项目联动

1. 识别父工作区、子模块、独立目录和涉及项目。
2. 推导同一个候选 `feature/<business-slug>`。
3. 对所有涉及仓库检查是否已存在同名分支；若已占用，暂停并要求用户裁决。
4. 输出分支映射表和待执行命令。
5. 等待用户确认。
6. 用户确认后，在父工作区和涉及项目创建同名 `feature/<business-slug>`。
7. 不涉及项目不强制开分支，但必须记录冻结 commit。

分支映射表：

| 项目 | 类型 | 分支 | 起点 commit | 是否本次改动 | 说明 |
|------|------|------|-------------|--------------|------|

---

## 4. Release 开始

1. 按“版本推导”推导候选 `release/<version>` 和 tag `<version>`。
2. 等待用户确认。
3. 用户确认后，从 `develop` 创建 `release/<version>`。
4. 多项目发版时，在参与项目创建或切换同名 release 分支。
5. 冻结父仓库、子模块、独立目录、SQL/脚本、外部制品版本。
6. 生成或更新 `docs/releases/<version>/`。
   - 不得使用日期或业务名作为 `docs/releases/` 一级目录。
   - 单需求 release train 也使用版本号目录，业务名放入 `changes/<business-slug>/`。
7. release 分支只允许：
   - 修复发版阻塞问题。
   - 调整配置、版本号、SQL/脚本。
   - 补充发版文档、冒烟清单、证据记录。
   - 处理 QA/预发验收反馈。

release 分支不得继续塞新需求。

---

## 5. Hotfix 开始

1. 按“版本推导”推导候选 `hotfix/<version>` 和 tag `<version>`。
2. 等待用户确认。
3. 用户确认后，从 `master` 创建目标 hotfix 分支。
4. 只修改修复必需范围。
5. 记录事故背景、影响面、修复验证、回滚方式。
6. 完成后必须回灌：
   - `master`
   - `develop`
   - 所有仍活跃且受影响的 `release/*`

---

## 6. Feature 收尾

合回 `develop` 前必须检查：

- 工作树是否干净，是否存在未跟踪文件。
- 变更是否仍在 OpenSpec/issue 范围内。
- 测试、构建、lint/type-check 是否有证据。
- 文档、runbook、OpenSpec tasks 是否更新。
- 多项目分支映射是否完整。

合并动作必须由用户明确触发，AI 不得在普通实现流程中静默合并。

---

## 7. Release 收尾

用户明确确认后，按顺序执行。确认卡必须一次性列出完整链路，不得只确认到 tag：

1. 合并 `release/<version>` 到 `master`。
2. 在 `master` 的 release 合并提交上创建 tag：`<version>`，不得加 `v` 前缀。
3. 立即进入 tag 后回灌门禁，合并 `release/<version>` 回 `develop`。
4. 更新父工作区子模块指针与发版证据。
5. 按需 push 分支和 tag。

执行前必须确认：

- Release evidence 完整。
- 总冒烟和项目级冒烟通过或有明确豁免。
- SQL/脚本 manifest 已执行并记录结果。
- 回滚方案可执行，不可逆数据点已披露。
- `docs/releases/<version>/` 已随 release 结果回灌到 `develop`，或已记录用户明确延后/豁免。

---

## 8. Hotfix 收尾

用户明确确认后，按顺序执行。确认卡必须一次性列出完整链路，不得只确认到 tag：

1. 合并 `hotfix/<version>` 到 `master`。
2. 在 `master` 的 hotfix 合并提交上创建 hotfix tag：`<version>`，不得加 `v` 前缀。不得直接在 `hotfix/*` 分支提交上创建发布 tag。
3. 立即进入 tag 后回灌门禁，合并或 cherry-pick 回 `develop`。
4. 回灌所有活跃且受影响的 `release/*`。
5. 更新事故记录和发版记录。

创建 tag 前必须核对：

- `git rev-parse <tag>^{commit}` 目标必须等于 `master` 当前发布提交。
- 若多仓同版本发布，每个仓库都必须分别确认 `master` 发布提交、tag 名、tag 落点和远端是否已有同名 tag。
- 发现 tag 名正确但落点不在 `master`，或落点正确但 tag 名错误时，先暂停说明；删除、重建或推送远端 tag 必须等待用户明确确认。

---

## 9. Tag 后回灌门禁

release/hotfix 创建 tag 后，Git Flow 任务不得视为完成。AI 必须继续处理回灌状态，直到满足以下任一条件：

- `develop` 已包含 release/hotfix 的回灌结果，并记录目标分支、回灌方式、commit 和验证命令。
- `develop` 已包含对应的 `docs/releases/<version>/` 发版目录和发版证据；缺失时 Git Flow 收尾不得标为完成。
- 所有仍活跃且受影响的 `release/*` 已完成 hotfix 回灌，或已记录“不受影响”的判断依据。
- 用户明确要求延后或豁免回灌，并记录负责人、原因、后续命令和风险；此时最终状态必须标为“回灌未完成”，不得标为完成。

tag 创建后的下一步输出必须包含：

- `develop` 回灌状态：未开始 / 已确认待执行 / 已完成 / 用户明确延后。
- 待执行或已执行命令：如 `git switch develop && git merge --no-ff release/<version>`。
- tag 落点证据：`git rev-parse <tag>^{commit}` 与 `master` 发布提交。
- 回灌证据：`git log --oneline --decorate -n 5 develop`、`git merge-base --is-ancestor <release-or-hotfix-tip> develop`，或 cherry-pick 对应 commit 证据。
- 发版目录证据：`docs/releases/<version>/` 在 `develop` 中存在，且目录名与 tag 完全一致。
- push 状态：未 push / 已 push `master` / 已 push `develop` / 已 push tag。
- 输出过滤状态：若过程中查看过 rtk 摘要，必须同时保留 raw 输出或重跑原生命令作为最终证据。

默认不得在 `develop` 回灌完成前标记 Git Flow 收尾完成；若用户要求先 push tag，AI 仍必须把 `develop` 回灌列为阻塞中的下一步。

---

## 10. 输出模板

```markdown
## Git Flow 操作结果

### 当前状态
- 仓库：
- 当前分支：
- 目标分支：
- 历史最大版本：
- 候选版本来源：

### 已执行
- 

### 等待人工确认
- 分支创建 / 合并 / tag / push：
- 待执行命令：

### Tag 后回灌门禁
- develop 回灌状态：未开始 / 已确认待执行 / 已完成 / 用户明确延后
- tag 落点证据：
- 回灌证据：
- 输出过滤状态：
- push 状态：
- 最终状态：完成 / 回灌未完成

### 分支映射
| 项目 | 分支 | commit | 状态 |
|------|------|--------|------|

### 验证证据
- 

### 下一步
- 
```
