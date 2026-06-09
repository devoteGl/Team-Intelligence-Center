# AI 规则使用说明

本项目已用轻量模式接入 Team-Intelligence-Center。

## 已安装内容

- `AGENTS.md`：项目级 AI 协作入口。
- `.tic-rules.lock`：轻量安装元信息，用于诊断当前接入的规则版本。
- `docs/ai-rules-usage.md`：本说明文件。
- `ai-harness/project-adapter.md`：项目命令、模块和风险边界适配说明。

## 如何与 AI 协作

先用自然语言描述任务。AI 应按风险分级处理：

- consulting / 只读任务：直接回答，不改文件。
- micro 任务：保持改动很窄，并执行最小验证。
- standard 任务：使用相关 TIC 技能，执行 SDD + TDD，并完成验证。
- critical 任务：需要明确人工确认、回滚思路和更强验证。

UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归相关变更，应优先核对真实界面。能运行本地应用时，优先使用 Playwright、浏览器截图、Computer Use 或 Chrome；无法自动核对时，在最终报告中说明替代验证和剩余 UI 风险。

standard / critical 任务实现完成后，如需要异步 review、QA 验收、UI/浏览器证据、脚本交付说明，或你明确要求“walkthrough / 交付走查”，AI 应生成交付 Walkthrough。它应说明交付摘要、用户可见变化、技术走查、变更文件、验证证据、Review 指引、未测项、风险和后续动作。

standard / critical 任务完成后，如影响用户可见行为、UI、API、数据模型、状态流转、业务规则或运营流程，AI 应生成 PRD 更新草稿和待确认项。草稿必须基于证据，不自动转正为正式 PRD。

## 规则来源

Team-Intelligence-Center 源路径：

```text
{{TIC_RULES_DIR}}
```

请把源规则库作为稳定知识基座。除非团队明确决定，不要把大型流程包、vendor 资产或历史 PRD 档案复制进业务项目。

Skills 默认从上述源路径读取，不自动差量复制到项目本地 skills 或开发者全局 skills，避免版本漂移和覆盖个人配置。
