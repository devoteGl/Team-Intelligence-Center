# Team-Intelligence-Center Codex 全局 Loader

本文件只作为 Codex 全局轻量入口，不是项目规则本体。

默认规则源：`{{TIC_RULES_DIR}}`
规则版本：`{{TIC_VERSION}}`

## 优先级

- 优先读取并遵守当前项目的 `AGENTS.md`、`.tic-rules.lock` 和 `ai-harness/project-adapter.md`。
- 项目级规则与本全局 Loader 冲突时，以项目级规则为准。
- 未检测到项目级 TIC 接入时，不强制启用 TIC 的 SDD / PRD / OpenSpec 流程。
- 用户显式调用 `tic-*` skill，或项目已接入 TIC 时，才按 TIC 规则源读取对应 Skill。

## 规则源解析

执行 TIC 能力前，按顺序定位规则源：

1. 从当前工作目录向上查找 `.tic-rules.lock`；若其中存在 `rules_path=`，按项目相对路径读取规则源。
2. 若 lock 中没有项目相对规则源，读取同级 `.tic-rules.local` 中的 `rules_dir=`；该文件是个人本机配置，不应提交。
3. 若仍未找到，再查找项目 `AGENTS.md` 中的 TIC 规则源解析说明。
4. 若仍未找到，仅在用户显式要求使用 TIC 能力时，使用本 Loader 的默认规则源。

## 全局行为边界

- 不自动复制 TIC `Skills/` 到项目本地 skills 或全局 skills。
- 不覆盖研发个人全局规则；本 Loader 只提供发现项目 TIC 的方法。
- 不默认执行 Git 分支、提交、推送、合并或 tag。涉及 Git Flow 操作时，应读取项目 TIC 的 `Skills/git-flow-operator.md`，先给出候选分支、版本/tag 证据和待执行命令，等待用户确认。
- 默认使用 single adaptive workflow：`tic-workflow-orchestrator` 判断 consulting / micro / standard / critical，并应用项目 `risk_floor`。`strict` 仅作为 `risk_floor=critical` 的兼容说法。
- consulting / micro 任务保持轻量，不强制 PRD / SDD / OpenSpec。
- standard / critical 任务在项目已接入 TIC 时执行 SDD + TDD。
- API、共享类型、字段、枚举、错误码、权限点或 FE/BE 并行前优先读取 `Skills/contract-handoff.md`；共享文件域修改优先读取 `Skills/shared-domain-arbiter.md`。
- UI 相关变更应使用 `design-taste-frontend` 与 `ui-ux-pro-max`；需要端到端真实操作验证时，优先使用 `@电脑`（`plugin://computer-use@openai-bundled` / Computer Use），并可结合 Playwright、浏览器截图或 Chrome 核对真实界面。
- standard / critical 任务实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明或用户要求 walkthrough，应生成交付 Walkthrough。
- standard / critical 任务完成后，如影响用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程，应生成 PRD 更新草稿和待确认项。

## TIC Skill 使用

全局 `tic-*` skills 是包装器。被调用后应读取项目规则源中的真实 Skill，例如：

```text
<rules_dir>/Skills/post-dev-prd-sync.md
<rules_dir>/Skills/code-investigator.md
<rules_dir>/Skills/tic-workflow-orchestrator.md
```

如果规则源或目标 Skill 不存在，应说明缺失原因，并继续采用最接近的轻量处理方式。
