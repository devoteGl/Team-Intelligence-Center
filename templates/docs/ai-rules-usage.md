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

## 规则来源

Team-Intelligence-Center 源路径：

```text
{{TIC_RULES_DIR}}
```

请把源规则库作为稳定知识基座。除非团队明确决定，不要把大型流程包、vendor 资产或历史 PRD 档案复制进业务项目。

