---
schema: tic_capability.v1
id: git-flow-operator
status: canonical
category: git
activation:
  when:
    - 用户明确要求分支、提交、推送、合并、tag 或回灌操作
  not_when:
    - 普通研发任务没有明确 Git 生命周期授权
side_effects: external-write
artifacts:
  default: git-operation-evidence
  when_needed:
    - Git 或发布操作需要审计和回灌记录
requires: []
related:
  - release-handoff
---

# Git Flow Operator（分支与发版合并操作技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager**
- 触发时机：用户明确要求创建分支、提交、推送、合并、tag 或回灌操作
- 输出物：分支操作计划、分支映射、合并/tag 门禁、执行证据、回灌记录
- 适用场景：单仓库 Git Flow、多项目联动 Git Flow、子模块/独立目录版本冻结、release/hotfix 收尾

---

## 0. 核心原则

AI 不得静默创建分支、合并、tag 或 push。分支创建必须先给出候选分支、命名依据和执行命令，等待用户确认无误后再执行。

Git Flow 的状态变更和最终证据必须使用原生 `git` 命令或保留 raw/proxy 原始输出。rtk 等输出压缩工具只可用于只读预览（如 status/log/diff 的辅助阅读），不得替代创建分支、合并、tag、push、回灌、子模块指针更新和最终审计证据。

**分支创建新鲜度门禁**：

- 创建任何 `feature/*`、`release/*`、`hotfix/*` 分支前，必须先执行 `git fetch --all --prune --tags`。若网络或权限不允许，必须说明远端状态可能过期，并等待用户明确确认是否继续；不得把过期本地引用当成权威事实。
- 创建前必须同时检查 `refs/heads/<branch>` 和 `refs/remotes/*/<branch>`。任一位置已存在同名分支，或本地/远端同名分支指向不同 commit，必须暂停并让用户裁决。
- 创建前必须从 `ai-harness/project-adapter.md`、项目 `AGENTS.md` 或现有分支事实解析 `branch_strategy` 与基线，并记录基线新鲜度。未声明且仓库明显采用 Git Flow 时，`feature/*` 和 `release/*` 可候选基于 `develop`，`hotfix/*` 可候选基于 `master`；无法判断时不得猜测基线。
- 本地基线必须与 upstream 或指定远端基线一致。若本地落后、领先或分叉，必须先同步、改用明确远端基线或等待用户确认。
- `tools/git-advice.*` 是只读建议脚本，不主动 fetch，不替代本门禁。只有在刚完成 fetch 或脚本输出的远端状态缺口已被人工接受后，才可把建议用于确认卡。

**分支与 tag 命名规则**：

- `feature/<business-slug>`：用于新需求和常规修复，后缀表达业务目的或 issue，例如 `feature/offline-refund`、`feature/1234-offline-refund`。
- `release/<version>`：用于发版冻结，默认 `<version>` 使用 SemVer，例如 `release/1.2.4`。
- `hotfix/<version>`：用于线上紧急修复，版本格式同 release，例如 `hotfix/1.2.5`。
- `version_format`、`tag_policy` 以项目适配器或既有历史为准；默认 `semver + preserve-existing`。
- 禁止同一项目无说明地混用 `1.2.4` 和 `v1.2.4` 两种 tag 风格；发现混用时必须暂停并让用户裁决。
- 若项目明确使用 `three-digit-patch`、CalVer 或其他格式，应按项目规则解析，不得强制改写为 SemVer。
- 禁止纯流水号 release/hotfix：`release/012`、`hotfix/013`。

**版本推导必须先扫描历史最大值**：

1. 先完成“分支创建新鲜度门禁”中的 `git fetch --all --prune --tags`。
2. 按项目 `version_format` 扫描本地和远端 release/hotfix 分支；默认 SemVer 匹配 `数字.数字.数字`。
3. 扫描可见 tag、发版登记根、发版记录和项目约定中的版本号。
   - 默认扫描 `docs/releases/`；若 `ai-harness/project-adapter.md` 声明 `release_registry_root`，同时扫描该登记根。
   - 发版登记根仅把匹配项目版本策略的一级目录视为版本目录；默认 SemVer，例如 `1.2.4`。
   - 日期、业务名或其他非版本号目录只能作为历史遗留资料，不参与最大版本推导。
4. 按 `major.minor.patch` 数值比较取历史最大版本，默认递增第三段，生成候选分支。
5. 默认 SemVer 没有历史版本时从 `1.0.0` 开始；已有版本默认递增 patch。major/minor 变化必须来自发布意图或用户确认，不能仅按数值猜测。
6. 输出版本证据和候选命令，等待用户确认。

**Release 目录主键**：

- 发版交接目录一律以版本号为一级入口：`<release-registry-root>/<version>/`，默认 `docs/releases/<version>/`。
- `<version>` 必须与本次 release/hotfix tag 完全一致，并符合项目版本策略；默认 SemVer，例如 `1.2.4`。
- 禁止在发版登记根下新建日期、业务名、需求名或其他非版本号一级目录。
- 业务名、需求名或变更主题应放入版本目录内的 `changes/<business-slug>/`，具体结构由 `Skills/release-handoff.md` 定义。
- 版本号是发版容器在该登记根内的唯一主键，对齐分支、tag、父仓库子模块指针和发版证据；业务名只是容器内容。
- 发版计划归属于拥有发布窗口、版本号/tag、上线顺序和统一回滚的 `release_owner`；多项目场景必须在父工作区、子项目或外部协调仓之间明确一个主归属。

**必须显式确认**：

- 创建任何 `feature/*`、`release/*`、`hotfix/*` 分支。
- 合并到项目长期分支。
- 创建 tag。
- push 任意分支或 tag。
- hotfix 回灌项目集成分支和活跃 `release/*`。
- 任何会覆盖、丢弃或重写历史的操作。

---

## 1. Git Flow profile 的分支职责

下表仅适用于项目已声明或仓库事实明确采用 Git Flow 的情况；trunk-based 或自定义策略使用项目自己的长期分支与基线。

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
- 目标基线：<feature_base / release_base / hotfix_base / commit>
- 命名依据：业务名 / issue / 历史最大版本
- 已扫描来源：本地分支、远端分支、tag、发版登记根、发版记录
- 远端刷新状态：已 fetch / fetch 失败并已确认风险
- 基线同步状态：up-to-date / behind / ahead / diverged / no-upstream
- 同名分支检查：refs/heads=<存在/不存在>；refs/remotes=<存在/不存在>；diverged=<yes/no>
- 历史最大版本：<release/hotfix/tag 适用；feature 可写不适用>
- 候选分支：<feature/business-slug | release/version | hotfix/version>
- 候选 tag：<release/hotfix 适用；无 v 前缀>
- release owner：<workspace / project / subproject / external + owner id>
- release registry root：<默认 docs/releases 或项目声明路径>
- 起点 commit：<sha>
- 待执行命令：git switch -c <branch> <base>
- 等待用户确认：是
```

用户确认前，只能输出计划和证据；不得创建分支。

---

## 3. 新需求开始

### 3.1 单项目

1. 确认当前仓库为目标项目。
2. 执行 `git fetch --all --prune --tags`，并记录刷新结果。
3. 确认项目 `feature_base`；Git Flow profile 可候选 `develop`，并校验本地基线与 upstream 或指定远端基线一致。
4. 从用户需求、issue 编号或 OpenSpec change id 推导候选 `feature/<business-slug>`。
5. 同时检查 `refs/heads/<candidate>` 和 `refs/remotes/*/<candidate>` 是否已存在或分叉；若已占用，暂停并要求用户裁决。
6. 等待用户确认。
7. 用户确认后创建分支并记录起点 commit。

### 3.2 多项目联动

1. 识别父工作区、子模块、独立目录和涉及项目。
2. 对所有涉及仓库执行 `git fetch --all --prune --tags`，并记录刷新结果。
3. 推导同一个候选 `feature/<business-slug>`。
4. 对所有涉及仓库同时检查 `refs/heads/<candidate>` 和 `refs/remotes/*/<candidate>` 是否已存在或分叉；若已占用，暂停并要求用户裁决。
5. 确认所有需要开分支的仓库目标基线与 upstream 或指定远端基线一致。
6. 输出分支映射表和待执行命令。
7. 等待用户确认。
8. 用户确认后，在父工作区和涉及项目创建同名 `feature/<business-slug>`。
9. 不涉及项目不强制开分支，但必须记录冻结 commit。

分支映射表：

| 项目 | 类型 | 分支 | 起点 commit | 是否本次改动 | 说明 |
|------|------|------|-------------|--------------|------|

---

## 4. Release 开始

1. 执行“分支创建新鲜度门禁”，确认项目 `release_base` 与 upstream 或指定远端基线一致；Git Flow 未显式配置时可候选 `develop`，但必须披露依据。
2. 按“版本推导”推导候选 `release/<version>` 和 tag `<version>`。
3. 同时检查 `refs/heads/release/<version>` 和 `refs/remotes/*/release/<version>` 是否已存在或分叉；若已占用，暂停并要求用户裁决。
4. 等待用户确认。
5. 用户确认后，从已确认新鲜的 `release_base` 创建 `release/<version>`。
6. 多项目发版时，在参与项目创建或切换同名 release 分支。
7. 冻结父仓库、子模块、独立目录、SQL/脚本、外部制品版本。
8. 生成或更新 `<release-registry-root>/<version>/`。
   - 默认登记根为 `docs/releases`；如项目声明其他 `release_registry_root`，按项目声明执行。
   - 不得使用日期或业务名作为发版登记根一级目录。
   - 单需求 release train 也使用版本号目录，业务名放入 `changes/<business-slug>/`。
   - 发版目录必须记录 `release_owner`、`release_tag`、tag 目标 commit、远端 tag 状态、部署触发方式，以及 SDD/TDD/PRD 落盘状态。
9. release 分支只允许：
   - 修复发版阻塞问题。
   - 调整配置、版本号、SQL/脚本。
   - 补充发版文档、冒烟清单、证据记录。
   - 处理 QA/预发验收反馈。

release 分支不得继续塞新需求。

---

## 5. Hotfix 开始

1. 执行“分支创建新鲜度门禁”，确认项目 `hotfix_base` 与 upstream 或指定远端基线一致；Git Flow 未显式配置时可候选 `master`，但必须披露依据。
2. 按“版本推导”推导候选 `hotfix/<version>` 和 tag `<version>`。
3. 同时检查 `refs/heads/hotfix/<version>` 和 `refs/remotes/*/hotfix/<version>` 是否已存在或分叉；若已占用，暂停并要求用户裁决。
4. 等待用户确认。
5. 用户确认后，从已确认新鲜的 `hotfix_base` 创建目标 hotfix 分支。
6. 只修改修复必需范围。
7. 记录事故背景、影响面、修复验证、回滚方式。
8. 完成后必须回灌：
   - 项目发布分支
   - 项目集成分支
   - 所有仍活跃且受影响的 `release/*`

---

## 6. Feature 收尾

合回项目集成分支前必须检查：

- 工作树是否干净，是否存在未跟踪文件。
- 变更是否仍在 OpenSpec/issue 范围内。
- 测试、构建、lint/type-check 是否有证据。
- 文档、runbook、OpenSpec tasks 是否更新。
- 多项目分支映射是否完整。

合并动作必须由用户明确触发，AI 不得在普通实现流程中静默合并。

---

## 7. Release 收尾

用户明确确认后，按顺序执行。确认卡必须一次性列出完整链路，不得只确认到 tag：

1. 合并 `release/<version>` 到项目发布分支。
2. 在发布合并提交上按项目 `tag_policy` 创建 tag。
3. 立即进入 tag 后回灌门禁，按项目策略合并 `release/<version>` 回集成分支。
4. 更新父工作区子模块指针与发版证据。
5. 按需 push 分支和 tag。

执行前必须确认：

- Release evidence 完整。
- 总冒烟和项目级冒烟通过或有明确豁免。
- SQL/脚本 manifest 已执行并记录结果。
- 回滚方案可执行，不可逆数据点已披露。
- `<release-registry-root>/<version>/` 已随 release 结果进入项目声明的集成或收尾目标，或已记录用户明确延后/豁免。
- Release Handoff 已记录 `release_owner`、`release_tag`、tag 目标 commit、远端状态、部署触发方式，以及 SDD/TDD/PRD 落盘状态。

---

## 8. Hotfix 收尾

用户明确确认后，按顺序执行。确认卡必须一次性列出完整链路，不得只确认到 tag：

1. 合并 `hotfix/<version>` 到项目发布分支。
2. 在发布合并提交上按项目 `tag_policy` 创建 hotfix tag。不得直接在 `hotfix/*` 分支提交上创建发布 tag。
3. 立即进入 tag 后回灌门禁，按项目策略合并或 cherry-pick 回集成分支。
4. 回灌所有活跃且受影响的 `release/*`。
5. 更新事故记录和发版记录。

创建 tag 前必须核对：

- `git rev-parse <tag>^{commit}` 目标必须等于项目当前发布提交。
- 若多仓同版本发布，每个仓库都必须分别确认发布提交、tag 名、tag 落点和远端是否已有同名 tag。
- 已 push 的发布 tag 默认不可移动；发现 tag 名正确但落点不在项目发布提交，或落点正确但 tag 名错误时，先暂停说明；删除、重建或推送远端 tag 必须等待用户明确确认。

---

## 9. Tag 后回灌门禁

release/hotfix 创建 tag 后，Git Flow 任务不得视为完成。AI 必须继续处理回灌状态，直到满足以下任一条件：

- 项目集成分支已包含 release/hotfix 的回灌结果，并记录目标分支、回灌方式、commit 和验证命令。
- 项目集成分支已包含对应的 `<release-registry-root>/<version>/` 发版目录和发版证据；缺失时 Git Flow 收尾不得标为完成。
- 所有仍活跃且受影响的 `release/*` 已完成 hotfix 回灌，或已记录“不受影响”的判断依据。
- 用户明确要求延后或豁免回灌，并记录负责人、原因、后续命令和风险；此时最终状态必须标为“回灌未完成”，不得标为完成。

tag 创建后的下一步输出必须包含：

- 项目集成分支回灌状态：未开始 / 已确认待执行 / 已完成 / 用户明确延后。
- 待执行或已执行命令：必须使用项目声明的集成分支。
- tag 落点证据：`git rev-parse <tag>^{commit}` 与项目发布提交。
- 回灌证据：项目集成分支的 `git log`、`git merge-base --is-ancestor`，或 cherry-pick 对应 commit 证据。
- 发版目录证据：`<release-registry-root>/<version>/` 在项目声明的集成或收尾目标中存在，且目录名与 tag 完全一致。
- push 状态：未 push / 已 push 发布分支 / 已 push 集成分支 / 已 push tag。
- 输出过滤状态：若过程中查看过 rtk 摘要，必须同时保留 raw 输出或重跑原生命令作为最终证据。

默认不得在项目要求的回灌或收尾完成前标记 Git Flow 完成；若用户要求先 push tag，AI 仍必须把剩余收尾列为阻塞中的下一步。

---

## 10. 输出模板

```markdown
## Git Flow 操作结果

### 当前状态
- 仓库：
- 当前分支：
- 目标分支：
- 远端刷新状态：
- 基线同步状态：
- 同名分支检查：
- 历史最大版本：
- 候选版本来源：
- release owner：
- release registry root：

### 已执行
- 

### 等待人工确认
- 分支创建 / 合并 / tag / push：
- 待执行命令：

### Tag 后回灌门禁
- 项目集成分支回灌状态：未开始 / 已确认待执行 / 已完成 / 用户明确延后
- tag 落点证据：
- 回灌证据：
- 发版目录证据：
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
