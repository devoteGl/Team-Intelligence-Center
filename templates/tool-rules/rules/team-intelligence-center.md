# Team-Intelligence-Center 项目规则入口

本项目使用 Team-Intelligence-Center 作为轻量 AI 协作规则层。

适用于 Claude Code、Gemini Code Assist 以及支持 `.rules/` 项目规则目录的 AI 工具。

请先读取项目根目录 `AGENTS.md`，再按其中的规则源解析读取 `.tic-rules.lock`、`.tic-rules.local` 和 `ai-harness/project-adapter.md`。

执行 TIC 能力时读取规则源中的 `Workflow/core.md` 和对应 `Skills/*.md`。

普通任务直接调查、修改和验证。规划深度、执行授权、验证范围、Review 和
事实持久化分别判断；Capability 按事实选择，不经过默认 Orchestrator，也不
自动级联。Superpowers 等外部方法不是总入口，OpenSpec 只保存需要长期维护
的规格事实。
