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

1. 从当前工作目录向上查找 `.tic-rules.lock`；若其中存在非空 `rules_path=`，按项目相对路径读取规则源。
2. 若 lock 中没有非空项目相对规则源，读取同级 `.tic-rules.local` 中的 `rules_dir=`；该文件是个人本机配置，不应提交。
3. 若仍未找到，再查找项目 `AGENTS.md` 中的 TIC 规则源解析说明。
4. 若仍未找到，仅在用户显式要求使用 TIC 能力时，使用本 Loader 的默认规则源。

## 全局行为边界

- 不自动复制 TIC `Skills/` 到项目本地 skills 或全局 skills。
- 不覆盖研发个人全局规则；本 Loader 只提供发现项目 TIC 的方法。
- 不默认执行 Git 分支、提交、推送、合并或 tag。涉及 Git Flow 操作时，应读取项目 TIC 的 `Skills/git-flow-operator.md`，先执行或要求执行 `git fetch --all --prune --tags`，再给出候选分支、版本/tag 证据、release owner、release registry root、基线同步状态、同名分支检查和待执行命令，等待用户确认；release/hotfix 打 tag 后必须继续输出 `develop` 回灌状态、tag 落点、发版目录、命令和证据，不得把 tag 视为完成态。
- rtk 等 CLI 输出压缩工具只作为项目级可选效率工具；未检测到项目显式启用时不强制使用。Git Flow、发版、迁移、破坏性和生产命令必须保留原生命令或 raw 输出；团队启用前必须确认 telemetry 已关闭。
- 默认使用 single adaptive workflow：`tic-workflow-orchestrator` 判断 consulting / micro / standard / critical，并应用项目 `risk_floor`。`strict` 仅作为 `risk_floor=critical` 的兼容说法。
- 新任务先做轻量 Intent Intake，识别目标、危险词、自治诉求、缺失信息、建议档位和确认方式；用户类型判断只影响解释粒度，不降低高危动作确认要求。
- “全自动”“你看着办”“不用问我”只授权可逆低风险步骤；删除、迁移、发版、push、merge、tag、生产配置或 PRD/OpenSpec 转正仍必须暂停确认。
- consulting / micro 任务保持轻量，不强制 PRD / SDD / OpenSpec。
- standard / critical 任务在项目已接入 TIC 时执行 SDD + TDD，并按 `ai-harness/project-adapter.md` 记录 SDD、TDD 证据、PRD 草稿、Walkthrough 和 Release Handoff 的归属与落盘根。
- API、共享类型、字段、枚举、错误码、权限点或 FE/BE 并行前优先读取 `Skills/contract-handoff.md`；共享文件域修改优先读取 `Skills/shared-domain-arbiter.md`。
- 如启用 subagent / multi-agent / 社区 agent，必须由项目 `tic-workflow-orchestrator` 先判断是否允许 fan-out；外部 agent 只能作为能力适配，必须遵守 TIC Agent Contract、文件 ownership、检查点和证据要求。
- 如每个 agent 独立开会话，应读取项目 `Skills/agent-session-protocol.md` 或 `ai-harness/agent-session-protocol.md`；`session_id` 只做追踪，事实源必须落盘到 manifest、outbox、status 和 evidence。
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
