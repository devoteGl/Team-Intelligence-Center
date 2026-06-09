# 轻量自动化设计

Team-Intelligence-Center 仍然是规则和技能知识库。自动化层只负责安装一个很小的项目入口，并校验规则包是否完整。

## 从 Codex_Project 吸收的部分

- 基于 `manifest.json` 的版本和资产声明。
- 可重复执行的项目 bootstrap。
- 用 marker 边界合并 `AGENTS.md`。
- `--dry-run` 安装预览。
- 用轻量 lock 文件辅助诊断。
- 自动生成项目适配说明，包含技术栈、依赖、Node 版本、包管理器、项目关系和常见命令线索。
- 按风险分级处理任务。
- standard / critical 任务默认执行 SDD + TDD。
- OpenSpec 作为可选规格承载层，用于已启用 OpenSpec 或需要长期行为追踪的变更。
- UI 相关变更优先核对真实界面，可使用 Playwright、浏览器截图、Computer Use 或 Chrome。
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

## 安装产物

bootstrap 脚本只写入：

```text
AGENTS.md
.tic-rules.lock
docs/ai-rules-usage.md
ai-harness/project-adapter.md
```

`AGENTS.md` 会写入 marker 块中，方便项目已有规则和 TIC 轻量规则共存。

`ai-harness/project-adapter.md` 不是空模板。bootstrap 会自动探测：

- `package.json`、`pnpm-workspace.yaml`、`tsconfig.json`、`go.mod`、`pyproject.toml` 等技术栈文件。
- `.nvmrc`、`.node-version`、`package.json engines.node` 中声明的 Node 版本。
- `pnpm-lock.yaml`、`yarn.lock`、`package-lock.json`、`bun.lock*` 推断包管理器。
- `package.json` 中的 scripts、dependencies、devDependencies、peerDependencies 和 workspaces。
- `openspec/`、`apps/`、`packages/` 等项目关系线索。

已有 `ai-harness/project-adapter.md` 默认不会覆盖；需要刷新画像时使用 `--force` / `-Force`。

## 推荐使用流程

macOS / Linux / WSL：

```bash
cd /path/to/project
bash /path/to/Team-Intelligence-Center/tools/install.sh
bash /path/to/Team-Intelligence-Center/tools/install.sh --preview
bash /path/to/Team-Intelligence-Center/tools/install.sh --refresh
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -Preview -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File C:\path\to\Team-Intelligence-Center\tools\install.ps1 -Refresh -ProjectRoot C:\path\to\project
```

默认安装保持轻量。任务确实需要更多结构时，再手动使用更深入的 TIC 技能。

底层高级入口仍保留：`tools/bootstrap-project.sh` / `tools/bootstrap-project.ps1` 支持 `--force` / `-Force`、`--rules-dir` / `-RulesDir` 等参数。日常研发优先使用 `install.*`。

## SDD + TDD 与 OpenSpec

轻量自动化不会让每次对话都进入 OpenSpec。规则是：

- consulting 和 micro 任务保持直接。
- standard 和 critical 任务必须执行 SDD + TDD。
- 业务项目已有 `openspec/` 时，把 SDD 写入或关联 OpenSpec change。
- 没有 OpenSpec 时，使用 `docs/sdd/` 或项目认可的规格位置。
- 测试或明确验证项应从 SDD 的验收标准推导出来，再进入实现。

因此，OpenSpec 是规格承载层，不是每个任务都必须启动的重流程。

## 开发后 PRD 同步

开发完成后的 PRD 自动化应生成“基于证据的更新草稿”，而不是直接把代码推断写成正式 PRD。

- standard / critical 任务完成后，若影响用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程，应执行 `Skills/post-dev-prd-sync.md`。
- 证据来源包括 OpenSpec / SDD、git diff、commit、测试结果、UI 验证、API 契约和用户确认。
- 输出为 PRD 更新草稿、证据清单、候选规则和待确认项。
- S2/S3 代码反推内容不得自动转正；人工确认后再同步到正式 PRD、OpenSpec specs 或项目约定位置。

## 交付 Walkthrough

Walkthrough 是完成态交付 artifact，用来让 PM、Reviewer、QA、运维或运营在没有全程跟随 Agent 执行的情况下快速恢复上下文。

- standard / critical 实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明，或用户要求 walkthrough，应执行 `Skills/delivery-walkthrough.md`。
- 证据来源包括需求来源、OpenSpec / SDD、git diff、改动文件、测试/构建、接口契约、截图、录屏、日志和人工确认。
- 输出重点是交付摘要、用户可见变化、技术走查、变更文件与影响面、验证证据、Review 指引、未测项、风险和后续动作。
- Walkthrough 不替代发版 runbook。需要部署、运营使用、回滚和上线观察时，继续执行 `Skills/release-ops-handoff.md` 或 `Skills/release-train-handoff.md`。

## UI 变更验证

UI 相关任务的验证重点是真实界面，而不是只看代码。

- 本地应用可运行时，优先使用 Playwright、浏览器截图、Computer Use 或 Chrome 打开页面并核对。
- 涉及登录、桌面 App、用户本机状态、浏览器插件或真实账号态时，可以使用 Computer Use / Chrome。
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
- 建议的短分支名和提交标题。
- 本地运行态文件、密钥和本地配置风险。

脚本不会执行 `git switch`、`git add`、`git commit`、`git push`、`git merge`、`git tag` 或删除分支。

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

`status` 是只读检查；只有显式执行 `init` 才可能在业务项目生成 `.codegraph/`。原始 `.codegraph/` 是否提交由业务项目决定，不确定时只保留人工整理后的摘要。

## Skills 分发策略

默认策略是“引用规则库，不复制 Skills”。

- bootstrap / install 只在业务项目写入 `AGENTS.md`、`.tic-rules.lock`、`docs/ai-rules-usage.md` 和 `ai-harness/project-adapter.md`。
- 业务项目通过 `.tic-rules.lock` 和 `AGENTS.md` 中的规则来源路径读取 `Skills/*.md`。
- 不自动差量复制到项目本地 skills，也不写入 `~/.codex/skills` 等全局目录，避免覆盖研发个人配置或产生版本漂移。
- 团队确实需要本地镜像时，应作为单独的显式同步任务执行，并记录来源版本、覆盖范围和回滚方式。

## Codex 全局 Loader

Codex 全局只适合安装发现入口，不适合承载整套项目规则。

安装内容：

```text
~/.codex/AGENTS.md                    # marker-bounded TIC Loader
~/.codex/skills/tic-*/SKILL.md        # Codex 原生 skill 包装器
```

这些包装器只负责定位项目 `.tic-rules.lock` 或项目 `AGENTS.md` 中的规则源，再读取 `<rules_dir>/Skills/*.md`。它们不是 TIC Skill 正文本体。

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

## 研发如何拉取规则

以 Git 作为分发边界。

研发本机维护或试用规则库：

```bash
git clone https://ycbl.xadazhihui.cn:18443/NexusAI/Team-Intelligence-Center.git
git pull --ff-only
```

业务项目需要锁定规则版本时，推荐使用 submodule：

```bash
git submodule add https://ycbl.xadazhihui.cn:18443/NexusAI/Team-Intelligence-Center.git .ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

然后在已拉取的规则目录中执行 bootstrap，并传入业务项目路径。
