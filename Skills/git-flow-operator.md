# Git Flow Operator（分支与发版合并操作技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager**
- 触发时机：新需求开始、创建 feature/release/hotfix 分支、功能收尾、发版合并、tag、push、hotfix 回灌
- 输出物：分支操作计划、分支映射、合并/tag 门禁、执行证据、回灌记录
- 适用场景：单仓库 Git Flow、多项目联动 Git Flow、子模块/独立目录版本冻结、release/hotfix 收尾

---

## 0. 核心原则

AI 可以自动创建低风险工作分支，但不得静默执行生产相关合并、tag 或 push。

**允许自动执行**：

- 从 `develop` 创建 `feature/<change-id>`。
- 多项目联动时，在父工作区和涉及子项目创建同名 `feature/<change-id>`。
- 用户明确要求时，从 `develop` 创建 `release/<release-id>`。
- 用户明确要求时，从 `master` 创建 `hotfix/<issue-id>`。

**必须显式确认**：

- 合并到 `master`。
- 创建 tag。
- push `master`、`release/*`、`hotfix/*` 或 tag。
- hotfix 回灌 `develop` 和活跃 `release/*`。
- 任何会覆盖、丢弃或重写历史的操作。

---

## 1. 分支职责

| 分支 | 用途 | 来源 | 去向 |
|------|------|------|------|
| `master` | 生产可发布或已发布代码 | `release/*` / `hotfix/*` 合入 | tag、生产发布 |
| `develop` | 日常集成主线 | `feature/*`、`release/*`、`hotfix/*` 回灌 | `release/*` |
| `feature/<change-id>` | 新需求或常规修复 | `develop` | `develop` |
| `release/<release-id>` | 发版冻结、预发/生产准备 | `develop` | `master` + 回灌 `develop` |
| `hotfix/<issue-id>` | 线上紧急修复 | `master` | `master` + `develop` + 活跃 `release/*` |

---

## 2. 新需求开始

### 2.1 单项目

1. 确认当前仓库为目标项目。
2. 确认当前分支或目标基线为 `develop`。
3. 创建 `feature/<change-id>`。
4. 记录起点 commit。

### 2.2 多项目联动

1. 识别父工作区、子模块、独立目录和涉及项目。
2. 在父工作区创建 `feature/<change-id>`。
3. 在涉及项目创建同名 `feature/<change-id>`。
4. 不涉及项目不强制开分支，但必须记录冻结 commit。
5. 输出分支映射表。

分支映射表：

| 项目 | 类型 | 分支 | 起点 commit | 是否本次改动 | 说明 |
|------|------|------|-------------|--------------|------|

---

## 3. Release 开始

1. 从 `develop` 创建 `release/<release-id>`。
2. 多项目发版时，在参与项目创建或切换同名 release 分支。
3. 冻结父仓库、子模块、独立目录、SQL/脚本、外部制品版本。
4. 生成或更新 `docs/releases/<release-id>/`。
5. release 分支只允许：
   - 修复发版阻塞问题。
   - 调整配置、版本号、SQL/脚本。
   - 补充发版文档、冒烟清单、证据记录。
   - 处理 QA/预发验收反馈。

release 分支不得继续塞新需求。

---

## 4. Hotfix 开始

1. 先扫描现有本地/远端 hotfix 分支、tag、发版记录和项目文档，识别当前项目的 hotfix 命名模式。
2. 若项目已有版本号式 hotfix（如 `hotfix/1.0.004`、`hotfix/1.0.007`），必须沿用该模式，并按现有分支 / tag / 发版记录推导下一个未使用版本号；不得改用语义名（如 `hotfix/live-share-entry`）。
3. 若项目没有可识别的既有模式，才使用通用 `hotfix/<issue-id>`。
4. 从 `master` 创建目标 hotfix 分支。
5. 只修改修复必需范围。
6. 记录事故背景、影响面、修复验证、回滚方式。
7. 完成后必须回灌：
   - `master`
   - `develop`
   - 所有仍活跃且受影响的 `release/*`

---

## 5. Feature 收尾

合回 `develop` 前必须检查：

- 工作树是否干净，是否存在未跟踪文件。
- 变更是否仍在 OpenSpec/issue 范围内。
- 测试、构建、lint/type-check 是否有证据。
- 文档、runbook、OpenSpec tasks 是否更新。
- 多项目分支映射是否完整。

合并动作必须由用户明确触发，AI 不得在普通实现流程中静默合并。

---

## 6. Release 收尾

用户明确确认后，按顺序执行：

1. 合并 `release/<release-id>` 到 `master`。
2. 创建 tag，推荐 `v<version>` 或团队约定格式。
3. 合并 `release/<release-id>` 回 `develop`。
4. 更新父工作区子模块指针与发版证据。
5. 按需 push 分支和 tag。

执行前必须确认：

- Release evidence 完整。
- 总冒烟和项目级冒烟通过或有明确豁免。
- SQL/脚本 manifest 已执行并记录结果。
- 回滚方案可执行，不可逆数据点已披露。

---

## 7. Hotfix 收尾

用户明确确认后，按顺序执行：

1. 合并 `hotfix/<issue-id>` 到 `master`。
2. 创建 hotfix tag。
3. 合并或 cherry-pick 回 `develop`。
4. 回灌所有活跃且受影响的 `release/*`。
5. 更新事故记录和发版记录。

---

## 8. 输出模板

```markdown
## Git Flow 操作结果

### 当前状态
- 仓库：
- 当前分支：
- 目标分支：

### 已执行
- 

### 等待人工确认
- 

### 分支映射
| 项目 | 分支 | commit | 状态 |
|------|------|--------|------|

### 验证证据
- 

### 下一步
- 
```
