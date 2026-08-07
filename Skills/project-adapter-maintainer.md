---
schema: tic_capability.v1
id: project-adapter-maintainer
status: canonical
category: governance
activation:
  when:
    - 用户要求维护 adapter 或错误的 adapter 阻止当前接入与升级
  not_when:
    - 普通任务可以直接读取现有项目事实
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 项目需要 adapter 审计、迁移或修复记录
requires: []
related:
  - code-investigator
---

# Project Adapter Maintainer（项目适配器维护技能）

## 技能用途

- 服务角色：**PM / CI / DS / Tech Lead**
- 触发时机：创建、补全、审计、迁移或修复 `ai-harness/project-adapter.md`
- 输出物：证据清单、适配器差异、冲突与待确认项、验证结果
- 适用场景：首次接入后的项目画像补全、TIC 版本升级、工作区拓扑变化、升级覆盖恢复、项目命令或发布策略调整

本技能维护的是项目级事实与治理配置，不是一次性生成的 AI 摘要。

---

## 0. 核心原则

### 0.1 现有事实优先

- 已有非占位内容默认视为项目维护的事实，不得用自动探测结果覆盖。
- `待补充`、`待确认`、空值和明确标记为示例的内容可以被证据补全。
- 自动探测只负责提供候选值；发生冲突时保留现值并输出待确认项。
- 不因 TIC 规则包升级而重置项目角色、模块边界、命令、风险、产物归属或本地决策。

### 0.2 证据优先级

按以下顺序解析事实：

1. 用户本轮明确确认的项目决策。
2. 当前适配器中的非占位内容和本地决策。
3. Git HEAD、文件历史和 `.tic-backups/` 中可追溯的旧适配器。
4. 项目 `AGENTS.md`、`.tic-rules.lock`、OpenSpec、README、CI 和发布文档。
5. 实际代码、配置、目录、包清单、构建脚本、分支和 tag。
6. TIC 模板与默认值。

低优先级来源不得静默覆盖高优先级来源。

### 0.3 内容边界

适配器应该记录：

- 项目或工作区身份、主要用户和技术栈。
- 父工作区、子项目、子模块和关联仓库。
- 模块边界、入口、常用命令和验证方式。
- E2E policy、runner、环境启动、认证、测试数据、核心旅程、清理和证据根。
- SDD、TDD 证据、PRD、契约、Walkthrough、记忆和发版资料的归属与落盘根。
- Git 分支、版本、tag 和部署触发策略。
- 认证、资金、迁移、生产配置和外部集成风险。
- 必须跨 AI 会话延续的项目级决策。

适配器不应该记录：

- 当前任务进度、临时分支状态或一次性调试结论。
- 未经验证的业务推测。
- 密钥、Token、密码、个人目录或机器专属绝对路径。
- cookie、storage state 内容、验证码或其他可复用认证材料；adapter 只能记录 gitignored 的项目相对路径。
- TIC 通用规则正文的重复副本。

---

## 1. 维护模式

| 模式 | 使用场景 | 默认动作 |
| --- | --- | --- |
| `create` | 文件不存在 | 从模板和项目证据创建，未知项保留待确认 |
| `enrich` | 文件存在但信息不足 | 只补空值、占位值和缺失章节 |
| `audit` | 用户要求检查准确性 | 只读核对，不修改文件 |
| `migrate` | TIC schema 升级 | 只增加缺失字段，保留已有值与自定义章节 |
| `repair` | 文件被覆盖、截断或误生成 | 从工作树、HEAD、历史和备份恢复，再合并新 schema |

未明确模式时：

- 文件不存在：使用 `create`。
- 文件存在且疑似被覆盖：使用 `repair`。
- TIC 版本变化：使用 `migrate`。
- 其他情况：先使用 `audit`，再根据证据建议 `enrich`。

---

## 2. 执行流程

### Step 1：解析项目与规则源

读取：

```text
AGENTS.md
.tic-rules.lock
.tic-rules.local（仅用于本机规则源解析）
ai-harness/project-adapter.md
```

从 lock 解析 TIC 版本和规则源。不得把 `.tic-rules.local` 的绝对路径写入提交文件。

### Step 2：建立恢复与差异基线

文件存在时依次检查：

```bash
git status --short -- ai-harness/project-adapter.md
git diff -- ai-harness/project-adapter.md
git log --follow -- ai-harness/project-adapter.md
```

按需检查最近的：

```text
.tic-backups/*/ai-harness/project-adapter.md
```

输出当前文件、HEAD、最近备份和目标 schema 的差异。不得在未展示恢复来源时直接替换当前文件。

### Step 3：调查项目事实

优先调用 `code-investigator` 做只读证据调查，不复制其正文。

至少检查：

- `.gitmodules`、嵌套 Git 仓库、workspace 配置和一级业务目录。
- `package.json`、`go.mod`、`pom.xml`、`build.gradle`、`pyproject.toml`、Docker 和 CI 文件。
- README、Makefile、包管理脚本和测试配置中的真实命令。
- `docs/`、`openspec/`、`ai-harness/` 和现有产物目录。
- 本地与远端长期分支、release/hotfix 分支、tag 和发版登记目录。
- 认证、资金、迁移、生产配置、第三方回调和密钥引用位置。

工作区存在 `.gitmodules` 或多个独立仓库时，不得仅根据根目录技术栈文件判断整个工作区。

### Step 4：标注事实可信度

| 等级 | 含义 | 可否直接写入 |
| --- | --- | --- |
| S1 | 用户确认或项目正式文档声明 | 可以 |
| S2 | 代码、配置、Git 或目录事实可验证 | 可以，注明证据 |
| S3 | 合理推断 | 只能进入待确认项 |
| S4 | 信息缺失 | 保留 `待确认` |

### Step 5：执行保护性合并

按以下规则生成候选差异：

1. 保留全部自定义章节和未知扩展字段。
2. 保留已有非占位值。
3. 只增加目标 schema 缺失的章节和字段。
4. 占位值只有在存在 S1/S2 证据时才替换。
5. 当前值与证据冲突时，不自动选择；输出冲突、来源和建议。
6. `repair` 模式以最完整的可追溯版本为主体，再合并当前版本新增字段。
7. 写入前展示 diff；涉及归属、Git、部署或风险策略变化时等待人工确认。

禁止通过 `bootstrap --force` 或模板整文件覆盖来完成普通迁移。完整重生成只用于用户明确要求丢弃现有适配器的场景，并且必须先备份和确认。

### Step 6：验证

完成后检查：

- 文件不包含个人绝对路径、密钥或临时状态。
- `artifact_ownership` 与父子项目关系一致。
- 所有声明的 artifact root 有明确归属；路径不存在时标记为待创建，不伪造存在。
- 常用命令来自真实脚本、CI、Makefile 或项目文档。
- E2E 命令、runner、base URL、认证和数据策略来自项目证据；未知项保留空值或 `待确认`。
- `auth_state_path` 是项目相对路径，认证状态本身已 gitignored，清理命令不会作用于所有权不明的数据。
- `branch_strategy`、基线、版本格式和 tag 策略与 Git 历史一致。
- 风险边界与项目实际敏感面一致。
- 当前文件保留了原有自定义章节、本地决策和未知扩展字段。
- `memory_root` 指向共享、可提交的项目记忆；个人画像仍在 gitignored 的
  `.tic/local/`，不得写入 adapter。
- 再次执行 `audit` 不产生无意义漂移。

---

## 3. 最小结构

项目可以扩展章节，但至少应覆盖：

```text
# 项目适配说明
## 项目画像
## 项目关系
## 产物归属与落盘
## 常用命令
## 模块地图
## 风险边界
## 本地决策
```

产物与发布配置至少包含：

```yaml
artifact_ownership:
  owner_type: project
  owner_id: "待确认"
  parent_workspace: ""
  child_projects: []
  related_repositories: []
artifact_roots:
  sdd_root: "docs/sdd"
  tdd_evidence_root: "docs/test-evidence"
  prd_root: "docs/PRD"
  prd_draft_root: "docs/PRD/drafts"
  walkthrough_root: "docs/walkthroughs"
  memory_root: "ai-harness/memory"
verification:
  e2e:
    policy: risk-based
    runner: project-native
    start_command: ""
    test_command: ""
    base_url: ""
    test_root: ""
    evidence_root: "docs/test-evidence"
    auth_mode: "待确认"
    auth_state_path: ""
    auth_state_policy: local-only
    data_strategy: "待确认"
    setup_command: ""
    cleanup_command: ""
    core_journeys: []
release_ownership:
  owner_type: project
  owner_id: "待确认"
  release_registry_root: "docs/releases"
  version_policy: independent
  version_format: semver
  branch_strategy: project-defined
  feature_base: "待确认"
  release_base: "待确认"
  hotfix_base: "待确认"
  tag_policy: "preserve-existing"
  deployment_trigger: "待确认"
```

这些是 schema 默认项，不是覆盖项目事实的默认值。

---

## 4. 输出格式

```markdown
## Project Adapter Maintenance

- Mode: create / enrich / audit / migrate / repair
- Project root:
- TIC version:
- Current adapter:
- Recovery source:
- Evidence inspected:

### Preserved
- 自定义章节：
- 非占位字段：
- 本地决策：

### Added or changed
| Field / section | Old | New | Evidence | Confidence |
| --- | --- | --- | --- | --- |

### Conflicts and pending decisions
| Item | Current | Evidence | Suggested action |
| --- | --- | --- | --- |

### Validation
- Absolute path / secret scan:
- Ownership consistency:
- Command evidence:
- Git/release evidence:
- Idempotency:
```

没有写入授权时只输出审计和候选 diff，不修改文件。
