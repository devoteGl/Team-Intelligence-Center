# Windsurf 项目规则入口

本项目使用 Team-Intelligence-Center 作为轻量 AI 协作规则层。

请先读取项目根目录 `AGENTS.md`，再按其中的规则源解析读取 `.tic-rules.lock`、`.tic-rules.local` 和 `ai-harness/project-adapter.md`。

执行 TIC 能力时只引用规则源中的 `Skills/*.md`，不要把完整 Skills 复制进 Windsurf 全局规则。

主线边界：TIC 负责风险分级、路由、检查点和证据闭环；OpenSpec 是规格事实源；Superpowers 是执行方法层。SDD + TDD 是 standard / critical 任务中的阶段语义，不是另一套独立工具链。

consulting / micro 任务保持轻量；standard / critical 任务按 `AGENTS.md` 中的检查点、OpenSpec / Superpowers 接合点和验证要求推进。
