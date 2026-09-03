# Team-Intelligence-Center 0.5.3 轻量自动化设计

## 目标

自动化层只负责安装、更新、发现规则源和验证规则包，不把研发方法固化成
一条强制流水线。

0.5.3 的边界是：

- `Workflow/core.md` 提供 outcome-driven 的五维独立决策；
- `Skills/*.md` 提供可独立选择的 Capability；
- Codex wrapper 的 description 只镜像精确激活事实，不编码前后阶段；
- `ai-harness/project-adapter.md` 保存项目事实和治理配置；
- 脚本保证生成、刷新和保留行为可重复；
- Git、发布、生产写入和正式晋升仍需要显式授权。

## 包内资产

| 资产 | 用途 |
| --- | --- |
| `VERSION` / `manifest.json` | 版本、策略、生命周期和安装产物 |
| `Workflow/core.md` | 任务契约、五维判断、受保护动作和证据边界 |
| `Workflow/capability-schema.md` | `tic_capability.v1` 契约 |
| `Workflow/scenarios.json` | 可执行的行为场景基线 |
| `Global-Rules/coding-rules.md` | 工程行为和安全边界 |
| `Global-Rules/git-rules.md` | Git 分支、提交、版本、tag 与回灌标准 |
| `Skills/` | 可独立选择的能力 |
| `templates/` | 项目入口、adapter、memory 和 wrapper |
| `tools/` | 安装、更新、建议和验证脚本 |

## 非目标

本包不自动：

- 为每个任务调用 Orchestrator；
- 串联 Capability；
- 为普通任务创建 PRD、SDD、Walkthrough、Release Handoff 或 session artifact；
- 在产品基线确认前自动开始会冻结产品行为的持久实现；
- 检索或提取 Collaboration Memory；
- 安装 Git hooks、CodeGraph、Playwright 或供应商工具；
- 执行分支、提交、push、merge、tag、发布或生产操作；
- 覆盖现有 Project Adapter、共享 memory 或项目自定义内容。

## 安装模型

### 项目入口

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --preview \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project

bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

脚本先解析目标路径，再生成 marker-bounded `AGENTS.md`、锁文件、工具入口、
规则使用说明、adapter、session protocol 和共享 memory 骨架。

### 刷新

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --refresh \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

普通刷新：

- 更新受管理入口；
- 保留 lock 中未知的项目字段；
- 逐字节保留已有 `ai-harness/project-adapter.md`；
- 逐文件保留 `ai-harness/memory/`；
- 不创建 `.tic/local/` 中的个人文件。

显式 `--regenerate-adapter` 才会备份并重建 adapter。

### Codex 全局 Loader

```bash
bash /path/to/Team-Intelligence-Center/tools/install-codex-global.sh \
  --dry-run \
  --rules-dir /path/to/Team-Intelligence-Center
```

全局安装只写轻量 Loader 和 `tic-*` wrapper。它按项目优先顺序解析规则源，
不复制完整 Skills，不替代项目 `AGENTS.md`。

## 更新模型

稳定通道：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project
```

当前分支：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --channel current \
  --project /path/to/project
```

指定版本：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --ref 0.5.3 \
  --project /path/to/project
```

更新器按顺序：

1. 选择 stable、current 或显式 ref；
2. 更新规则源；
3. 执行 `tools/validate-pack.sh`；
4. 刷新 Codex 全局 Loader；
5. 刷新目标项目入口。

`--preview` 只显示计划；`--no-pull`、`--no-global`、`--no-project` 可关闭
对应步骤。

## 规则源解析

项目安装不把本机绝对路径写进提交文件：

1. gitignored `.tic-rules.local` 明确声明 `rules_source=local_config`，且
   `rules_dir=` 可访问并包含 `Workflow/core.md` 时，作为分支无关的本机覆盖；
2. 否则 `.tic-rules.lock` 的项目相对 `rules_path=` 是提交态规则源；
3. 无可用 lock 路径时，再读取 `.tic-rules.local` 的非空 `rules_dir=`；
4. 全局 Loader 只提供 fallback；项目事实和 Project Adapter 始终优先。

## Workflow 自动化边界

### 五维决策

```text
planning_depth       inline / brief / living
execution_authority  autonomous / confirmation-required
verification_scope   targeted / integration / e2e / operational
review_level         self / independent / user-decision
fact_persistence     task-context / openspec / prd / runbook / release-record
```

五个维度分别判断。脚本不为任务选择等级；普通任务不需要调用 Orchestrator。

### Capability 激活

脚本不负责为任务选择 Skill。执行方根据每个 `tic_capability.v1` 头部的
`activation.when`、`activation.not_when`、`side_effects`、`artifacts` 和
`requires` 独立选择能力。

`related` 只表示可发现关系，不表示调用顺序。

### Artifact 激活

额外 artifact 必须有明确消费者和用途：

- 异步 reviewer 或 QA 需要复核时生成 Walkthrough；
- 大型新产品或重大用户旅程缺少已确认基线时生成 PRD 草稿；
- 产品 owner 需要判断基线是否可实现时执行 PRD Review；
- 产品维护者需要同步长期行为事实时生成 PRD 草稿；
- 发布 owner 需要部署和回滚材料时生成 Release Handoff；
- 跨任务或审计接力确实需要时生成 session artifacts；
- 用户明确要求维护长期经验时生成 memory 候选。

没有消费者时不创建。

## 验证模型

验证与动作模式分别判断：

- 静态文档结论使用结构、链接和 schema 检查；
- 代码行为结论使用项目原生测试；
- UI 结论在可运行时使用真实界面证据；
- 用户可见新产品在实现前明确角色、主旅程、信息架构和关键状态；
- 局部测试不足以证明关键旅程时启用 `e2e-verification`；
- 认证、权限、资金、隐私、迁移和跨服务关键链路需要相称的高置信证据。

项目 adapter 的 `verification.e2e` 声明 runner、环境、认证状态路径、数据
策略、清理命令、核心旅程和 evidence root。认证状态保持本地，只清理本次
验证拥有的数据。

verdict 使用：

- `passed`
- `failed`
- `partial`
- `blocked`
- `waived`

禁用某个 runner 不等于验证通过。

## Collaboration Memory 自动化边界

bootstrap 首次创建：

```text
ai-harness/memory/README.md
ai-harness/memory/project-context.md
ai-harness/memory/decision-log.md
ai-harness/memory/runbooks.md
ai-harness/memory/team-collaboration.md
```

这些文件只是可用存储，不代表每个任务自动读取或写入。读取、提取、review、
promote、reconcile、audit 和 deprecate 由用户明确要求或已确认项目约定
触发。

`.tic/local/` 保持 gitignored。脚本不把个人偏好、原始聊天、密钥、认证
状态或未经确认的敏感推断写入共享 memory。

## Git 自动化边界

`tools/git-advice.sh` 和 `tools/git-advice.ps1` 只读：

- 解析项目声明的基线、分支、版本和 tag 策略；
- 报告 remote fetch 状态；
- 报告基线同步差距；
- 检查本地和远端同名分支；
- 扫描默认和项目声明的 release registry root；
- 输出建议命令。

`tools/validate-branch-name.*` 和 `tools/validate-commit-msg.*` 分别校验
`tic-gitflow-v1` 分支名与 `conventional-chinese-v1` 提交信息。校验器只读，
可以由 Agent、commit-msg hook 或 CI 调用；TIC 默认不自动安装 Git hook。

它们不执行 `git fetch, switch, add, commit, push, merge, tag`。

实际 Git Flow 使用前应获得授权，并在创建分支前运行
`git fetch <authoritative-remote> --prune --tags`。已 push 的 release tag 默认不可移动，
tag 后仍需记录项目要求的回灌或收尾证据。

## 验证器

```bash
bash tools/validate-pack.sh
```

验证器覆盖：

- `VERSION` 与 manifest 一致；
- Workflow Core 保持规划、授权、验证、Review 和事实持久化五维独立；
- 场景 fixture 覆盖普通修改、共享契约、关键旅程、生产迁移、memory 和
  Git 写入；
- 全部 Skills 满足 `tic_capability.v1`；
- Orchestrator 保持有界兼容能力；
- bootstrap 幂等且保留 lock、adapter 和 shared memory；
- Codex 全局安装能渲染当前版本 Loader 和 wrapper；
- Shell 更新兼容 Bash 3.2 的空参数路径；
- Git 建议脚本保持只读，分支名和提交信息校验器覆盖统一策略。

PowerShell 存在时运行等价 fixture；不存在时输出 warning，不把静态检查
写成 runtime 通过。
