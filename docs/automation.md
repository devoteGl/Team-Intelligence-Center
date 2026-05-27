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

## 明确排除的部分

- 不绑定 Codex-only。
- 不引入 vendor 二进制或运行时依赖。
- 不默认安装 Git hooks。
- 不要求 RTK 或其它命令包装器。
- 不强制安装或初始化 CodeGraph。
- 不做 full / patch 复杂分发包。
- 不打包历史 PRD、测试和文档资产。
- 不要求咨询、只读、micro 任务走完整 SDD/Plan/Approval。
- 不接管分支生命周期，也不默认执行 Git 变更。

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
bash tools/validate-pack.sh
bash tools/bootstrap-project.sh --dry-run /path/to/project
bash tools/bootstrap-project.sh --yes /path/to/project
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\bootstrap-project.ps1 -DryRun -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File tools\bootstrap-project.ps1 -Yes -ProjectRoot C:\path\to\project
```

默认安装保持轻量。任务确实需要更多结构时，再手动使用更深入的 TIC 技能。

## SDD + TDD 与 OpenSpec

轻量自动化不会让每次对话都进入 OpenSpec。规则是：

- consulting 和 micro 任务保持直接。
- standard 和 critical 任务必须执行 SDD + TDD。
- 业务项目已有 `openspec/` 时，把 SDD 写入或关联 OpenSpec change。
- 没有 OpenSpec 时，使用 `docs/sdd/` 或项目认可的规格位置。
- 测试或明确验证项应从 SDD 的验收标准推导出来，再进入实现。

因此，OpenSpec 是规格承载层，不是每个任务都必须启动的重流程。

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
