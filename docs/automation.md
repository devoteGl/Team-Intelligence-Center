# 轻量自动化设计

Team-Intelligence-Center 仍然是规则和技能知识库。自动化层只负责安装一个很小的项目入口，并校验规则包是否完整。

## 从 Codex_Project 吸收的部分

- 基于 `manifest.json` 的版本和资产声明。
- 可重复执行的项目 bootstrap。
- 用 marker 边界合并 `AGENTS.md`。
- `--dry-run` 安装预览。
- 用轻量 lock 文件辅助诊断。
- 首次接入时生成项目适配说明，包含技术栈、依赖、Node 版本、包管理器、项目关系和常见命令线索；后续升级保护项目维护的事实。
- single adaptive workflow：按风险分级处理任务，并通过 `risk_floor` 锁定强管控项目的最低档位。
- 机器可读 `tic_skill.v1` contract，用于校验 Skill phase、风险档、canonical / alias / subflow 生命周期。
- standard / critical 任务默认执行规格驱动与验收驱动验证；自动测试和可观察验证都可以承接验收标准。
- OpenSpec 作为规格事实源，用于已启用 OpenSpec 或需要长期行为追踪的变更；Superpowers 作为执行方法层。
- UI 相关变更使用当前环境可用的设计与 UI/UX 专业能力，并优先核对真实界面；安装了 `design-taste-frontend` 与 `ui-ux-pro-max` 时优先使用。
- standard / critical 实现完成后，生成面向异步 review 和验收的交付 Walkthrough artifact。
- standard / critical 交付后，如产品行为发生变化，生成基于证据的 PRD 更新草稿。
- 简化入口：提供一条命令安装包装器，底层仍复用幂等 bootstrap。
- Codex 全局只安装轻量 Loader 和 `tic-*` skill 包装器，不承载项目规则本体。

## 明确排除的部分

- 不绑定 Codex-only。
- 不引入 vendor 二进制或运行时依赖。
- 不默认安装 Git hooks。
- 不要求 RTK 或其它命令包装器。
- 不强制安装或初始化 CodeGraph。
- 不做 full / patch 复杂分发包。
- 不打包历史 PRD、测试和文档资产。
- 不要求咨询、只读、micro 任务走完整 SDD/Plan/Approval。
- 不要求所有 UI micro 任务跑完整端到端流程。
- 不接管分支生命周期，也不默认执行 Git 变更。
- 不自动把 `Skills/` 差量复制到业务项目本地 skills 或开发者全局 skills。
- 不把完整项目规则写入 Codex 全局 `AGENTS.md`。
- 不提交 `.omx/`、`.superpowers/` 等本地运行态目录作为长期规格事实源。

## 安装产物

bootstrap 脚本只写入：

```text
AGENTS.md
.tic-rules.lock
docs/ai-rules-usage.md
.cursorrules
.windsurfrules
.rules/team-intelligence-center.md
ai-harness/project-adapter.md
```

同时写入本机配置：

```text
.tic-rules.local    # 个人本机规则库绝对路径，自动 gitignored
.gitignore          # 补充 .tic-rules.local 和 .tic-backups/
```

`AGENTS.md` 会写入 marker 块中，方便项目已有规则和 TIC 轻量规则共存。

`.tic-rules.lock` 是可提交的稳定元信息，只保存规则版本、接入模式和项目相对 `rules_path`。当规则库不在业务项目目录内时，`rules_path` 为空；解析器必须把空值视为“没有项目内规则源”，再读取 `.tic-rules.local`。个人绝对路径只写入 `.tic-rules.local`。

`ai-harness/project-adapter.md` 不是空模板。bootstrap 会自动探测：

- `package.json`、`pnpm-workspace.yaml`、`tsconfig.json`、`go.mod`、`pyproject.toml` 等技术栈文件。
- `.nvmrc`、`.node-version`、`package.json engines.node` 中声明的 Node 版本。
- `pnpm-lock.yaml`、`yarn.lock`、`package-lock.json`、`bun.lock*` 推断包管理器。
- `package.json` 中的 scripts、dependencies、devDependencies、peerDependencies 和 workspaces。
- `.gitmodules`、`openspec/`、`apps/`、`packages/` 等项目关系线索和子项目路径。
- `artifact_ownership`、`artifact_roots` 和 `release_ownership` 默认块，用于声明 SDD、TDD 证据、PRD、Walkthrough 和发版登记根的归属与落盘位置。

已有 `ai-harness/project-adapter.md` 在普通安装、`--refresh` / `-Refresh`、`--force` / `-Force` 和日常升级中都不会覆盖。项目画像的补全、审计、迁移和修复由 `Skills/project-adapter-maintainer.md` 处理。只有用户明确放弃现有内容时，才使用 `--regenerate-adapter` / `-RegenerateAdapter`；脚本会先备份再替换。

## 推荐使用流程

macOS / Linux / WSL：

```bash
cd /path/to/project
bash /path/to/Team-Intelligence-Center/tools/install.sh
bash /path/to/Team-Intelligence-Center/tools/install.sh --preview
bash /path/to/Team-Intelligence-Center/tools/install.sh --refresh
bash /path/to/Team-Intelligence-Center/tools/update.sh --project /path/to/project
bash /path/to/Team-Intelligence-Center/tools/update.sh --preview --project /path/to/project
bash /path/to/Team-Intelligence-Center/tools/update.sh --channel current --project /path/to/project
bash /path/to/Team-Intelligence-Center/tools/update.sh --ref 0.2.2 --project /path/to/project
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -Preview -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -Refresh -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\update.ps1 -ProjectRoot C:\path\to\project
```

默认安装保持轻量。任务确实需要更多结构时，再手动使用更深入的 TIC 技能。

底层高级入口仍保留：`tools/bootstrap-project.sh` / `tools/bootstrap-project.ps1` 支持 `--force` / `-Force`、`--regenerate-adapter` / `-RegenerateAdapter`、`--rules-dir` / `-RulesDir` 等参数。日常研发优先使用 `install.*`。

规则升级入口是 `tools/update.sh` / `tools/update.ps1`。默认 `stable` 通道选择最高 SemVer release tag；`current` 通道 fast-forward 当前分支；显式 `ref` 用于锁定 tag、分支或 commit。规则源验证成功后，再刷新 Codex 全局 Loader、`tic-*` wrapper 和业务项目入口。需要谨慎检查时先加 `--preview` / `-Preview`。

`0.1.0` 首次升级通常仍只需执行原来的一条更新命令：旧更新器 fast-forward 正常维护的发布或集成分支后，会取得新版脚本并完成刷新。只有 detached HEAD、自定义旧分支或未取得当前稳定版本时，才需手动 fetch tags 并 checkout 明确 tag。之后普通使用者跟随 stable tag，贡献者跟随 current，生产或需复现项目锁定 ref；submodule 由父项目 owner 统一更新并提交指针。

## 规格、验证与 OpenSpec

轻量自动化不会让每次对话都进入 OpenSpec。规则是：

- consulting 和 micro 任务保持直接。
- standard 和 critical 任务必须有规格和从验收标准推导的自动测试或可观察验证。
- 项目可通过 `risk_floor=standard|critical` 禁止任务降级到过轻流程。
- 业务项目已有 `openspec/` 时，把 SDD 语义写入或关联 OpenSpec change，OpenSpec 是规格事实源。
- 没有 OpenSpec 时，使用 `docs/sdd/` 或项目认可的规格位置。
- 测试或明确验证项应从 SDD 的验收标准推导出来，再进入实现。
- SDD、TDD 证据、PRD 草稿、Walkthrough 和 Release Handoff 的归属与落盘根以 `ai-harness/project-adapter.md` 为准；未声明时使用轻量默认路径。
- TDD 证据索引默认写入 `docs/test-evidence/<change-id>/README.md`，具体测试代码仍放在项目测试目录。

因此，规格与验证是交付语义，不是独立 Skill 链；OpenSpec 是规格承载层，不是每个任务都必须启动的重流程。

## Adaptive Workflow Orchestrator

当前版本推荐以 `Skills/tic-workflow-orchestrator.md` 作为 TIC 工作流入口。

它只负责：

- 识别 consulting / micro / standard / critical。
- 套用项目 `risk_floor`。
- 输出 phase、Skill DAG、检查点、产物和跳过项说明。
- 指明 OpenSpec / Superpowers 接合点。

它不负责：

- 复制子 Skill 模板正文。
- 替代 Superpowers planning / TDD / debugging / review。
- 替代 OpenSpec 成为规格事实源。
- 引入绕过 OpenSpec / Superpowers 的独立 SDD/TDD Skill 链。
- 接管 Git branch、tag、push、merge。

推荐 canonical 技能：

```text
tic-workflow-orchestrator
task-decomposer
code-investigator
contract-handoff
shared-domain-arbiter
delivery-walkthrough
release-handoff
post-dev-prd-sync
changelog-writer
git-flow-operator
project-governance-bootstrap
```

旧入口保留兼容：

```text
api-contract-freezer + fe-be-handoff -> contract-handoff
conflict-arbiter -> shared-domain-arbiter
release-ops-handoff + release-train-handoff -> release-handoff
candidate-rule-extractor -> code-investigator 子流程
prd-review-checklist -> 验收 checklist
session-snapshot-manager -> 总控/全局规则快照模板
```

## 开发后 PRD 同步

开发完成后的 PRD 自动化应生成“基于证据的更新草稿”，而不是直接把代码推断写成正式 PRD。

- standard / critical 任务完成后，若影响用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程，应执行 `Skills/post-dev-prd-sync.md`。
- 证据来源包括 OpenSpec / SDD、git diff、commit、测试结果、UI 验证、API 契约和用户确认。
- 输出为 PRD 更新草稿、证据清单、候选规则和待确认项。
- PRD 草稿默认写入 `docs/PRD/drafts/<change-id>-prd-update.md`；正式 PRD 默认归 `docs/PRD/` 或项目声明位置。
- 多项目变更只能有一个 PRD 主归属，其他项目作为引用或子项，避免同一业务事实在多个项目各自转正。
- S2/S3 代码反推内容不得自动转正；人工确认后再同步到正式 PRD、OpenSpec specs 或项目约定位置。

## 交付 Walkthrough

Walkthrough 是完成态交付 artifact，用来让 PM、Reviewer、QA、运维或运营在没有全程跟随 Agent 执行的情况下快速恢复上下文。

- standard / critical 实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明，或用户要求 walkthrough，应执行 `Skills/delivery-walkthrough.md`。
- 证据来源包括需求来源、OpenSpec / SDD、git diff、改动文件、测试/构建、接口契约、截图、录屏、日志和人工确认。
- 输出重点是交付摘要、用户可见变化、技术走查、变更文件与影响面、验证证据、Review 指引、未测项、风险和后续动作。
- Walkthrough 不替代发版 runbook。需要部署、运营使用、回滚和上线观察时，继续执行 `Skills/release-handoff.md`；单变更使用 `mode=single`，多项目、多服务、SQL/脚本使用 `mode=train`。

## UI 变更验证

UI 相关任务的验证重点是真实界面，而不是只看代码。

- UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归相关改动，应使用当前环境可用的设计与 UI/UX 专业能力；安装了 `design-taste-frontend` 与 `ui-ux-pro-max` 时优先使用。能力不可用或不适用时，按项目设计系统继续并说明替代依据。
- 本地应用可运行时，优先使用 Playwright、浏览器截图、Computer Use 或 Chrome 打开页面并核对。
- 涉及端到端验证功能、真实点击输入、登录、桌面 App、用户本机状态、浏览器插件或真实账号态时，优先使用当前环境可用的 Computer Use、浏览器自动化或截图验证。
- 默认核对页面是否可打开、核心流程是否可操作、样式是否错位、桌面/移动端是否异常、控制台是否有关键错误。
- micro 级纯文案或无行为样式微调，可做最小截图、局部检查或说明级验证。
- 无法运行或自动核对界面时，最终报告必须说明原因、替代验证和剩余 UI 风险。

## 可选 Git 建议

TIC 提供只读 Git 建议脚本，帮助研发命名分支和提交，但不让自动化修改仓库状态。

macOS / Linux / WSL：

```bash
bash tools/git-advice.sh --type feature "lightweight automation"
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\git-advice.ps1 -Type feature "lightweight automation"
```

脚本只检查：

- 当前仓库根目录、分支、上游和变更文件数量。
- 当前分支是否像长期分支。
- 本地 / 远端 `release/<version>`、`hotfix/<version>`、tag 和发版登记根中的可见最大版本号；默认登记根是 `docs/releases/`。
- 远端刷新状态、建议分支本地/远端占用状态、基线分支与 upstream 的同步状态。
- 建议的业务名 feature 分支、符合项目版本策略的 release/hotfix 分支、保留既有前缀风格的 tag 和提交标题。
- 本地运行态文件、密钥和本地配置风险。

脚本不会执行 `git fetch`、`git switch`、`git add`、`git commit`、`git push`、`git merge`、`git tag` 或删除分支。分支创建前仍必须先执行 `git fetch --all --prune --tags`，再由 `git-flow-operator` 输出确认卡，用户确认后才执行。

## 可选 CodeGraph 上下文增强

CodeGraph 只作为上下文增强层，帮助 AI 在老项目、monorepo、跨模块改动或重构前理解调用关系和影响面。它不替代 SDD + TDD，也不是 bootstrap 的默认产物。

TIC 不打包 CodeGraph，也不自动安装。研发需要时先按 `colbymchenry/codegraph` 官方说明安装 CLI，然后使用 helper：

macOS / Linux / WSL：

```bash
bash tools/codegraph-helper.sh status --project /path/to/project
bash tools/codegraph-helper.sh init --project /path/to/project
bash tools/codegraph-helper.sh context --project /path/to/project "订单状态流转"
bash tools/codegraph-helper.sh impact --project /path/to/project src/order/service.ts
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\codegraph-helper.ps1 -Command status -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File tools\codegraph-helper.ps1 -Command init -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File tools\codegraph-helper.ps1 -Command context -ProjectRoot C:\path\to\project "订单状态流转"
powershell -ExecutionPolicy Bypass -File tools\codegraph-helper.ps1 -Command impact -ProjectRoot C:\path\to\project src\order\service.ts
```

`status` 是只读检查；只有显式执行 `init` 才可能在业务项目生成 `.codegraph/`。helper 不会通过 `npx` 自动下载或安装 CodeGraph。原始 `.codegraph/` 是否提交由业务项目决定，不确定时只保留人工整理后的摘要。

## Skills 分发策略

默认策略是“引用规则库，不复制 Skills”。

- bootstrap / install 在业务项目写入 `AGENTS.md`、`.tic-rules.lock`、`docs/ai-rules-usage.md`、`ai-harness/project-adapter.md`，并生成本机 `.tic-rules.local`。
- 业务项目优先通过 `.tic-rules.lock` 中的非空项目相对 `rules_path` 读取 `Skills/*.md`；没有项目内规则库时，再通过 gitignored 的 `.tic-rules.local` 读取个人本机规则源。
- 不自动差量复制到项目本地 skills，也不写入 `~/.codex/skills` 等全局目录，避免覆盖研发个人配置或产生版本漂移。
- 团队确实需要本地镜像时，应作为单独的显式同步任务执行，并记录来源版本、覆盖范围和回滚方式。

## Codex 全局 Loader

Codex 全局只适合安装发现入口，不适合承载整套项目规则。

安装内容：

```text
~/.codex/AGENTS.md                    # marker-bounded TIC Loader
~/.codex/skills/tic-*/SKILL.md        # Codex 原生 skill 包装器
```

这些包装器只负责定位项目 `.tic-rules.lock` 的非空项目相对 `rules_path` 或 `.tic-rules.local` 的本机 `rules_dir`，再读取 `<rules_dir>/Skills/*.md`。它们不是 TIC Skill 正文本体。

macOS / Linux / WSL：

```bash
bash tools/install-codex-global.sh --dry-run
bash tools/install-codex-global.sh --yes
```

测试或指定目录：

```bash
bash tools/install-codex-global.sh --yes --codex-home /tmp/codex-home
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\install-codex-global.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File tools\install-codex-global.ps1 -Yes
```

全局 Loader 的优先级原则：

- 项目 `AGENTS.md` 和 `.tic-rules.lock` 优先。
- 没有项目 TIC 接入时，不强制项目走 SDD / PRD / OpenSpec。
- 用户显式调用 `tic-*` skill 时，才用默认规则源作为兜底。
- 新 wrapper 优先提供 `tic-workflow-orchestrator`、`tic-contract-handoff`、`tic-shared-domain-arbiter`、`tic-release-handoff`；旧 wrapper 保留兼容并可回退到旧 Skill 文件。

## 研发如何拉取规则

以 Git 作为分发边界。

研发本机维护或试用规则库：

```bash
git clone https://github.com/devoteGl/Team-Intelligence-Center.git
bash Team-Intelligence-Center/tools/update.sh --project /path/to/business-project
```

业务项目需要锁定规则版本时，推荐使用 submodule：

```bash
git submodule add https://github.com/devoteGl/Team-Intelligence-Center.git .ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

然后在已拉取的规则目录中执行 bootstrap，并传入业务项目路径。后续升级时，研发在业务项目中执行规则库的 `tools/update.sh` 即可。
