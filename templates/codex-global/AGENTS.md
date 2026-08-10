# Team-Intelligence-Center Codex 全局 Loader

本文件只发现项目 TIC，不是项目 workflow 或总控入口。

默认规则源：`{{TIC_RULES_DIR}}`
规则版本：`{{TIC_VERSION}}`

## 解析与优先级

优先遵守当前项目更具体的 `AGENTS.md` 和用户指令。规则源按以下顺序解析：

1. 从当前目录向上查找 `.tic-rules.lock`，解析非空 `rules_path=` 项目相对路径；
2. 否则读取同级 gitignored `.tic-rules.local` 的 `rules_dir=`；
3. 否则读取项目 `AGENTS.md` 的规则源说明；
4. 只有用户明确调用 TIC capability 时才用本 Loader 的默认规则源兜底。

未接入 TIC 的项目不自动启用 TIC。已接入项目以
`<rules_dir>/Workflow/core.md` 为唯一 workflow 事实源。

## 工作边界

- 普通任务直接调查、修改和验证，不调用默认 Orchestrator。
- 规划深度、执行授权、验证范围、Review 和事实持久化分别判断。
- Capability 先应用 `activation.not_when`，再只在用户明确要求或事实满足
  `activation.when` 时读取；关键词不触发，`related` 不授权也不自动级联。
- Superpowers 等外部 Skills 是按需方法库，umbrella workflow 声明不得覆盖
  项目的原生 outcome-driven 工作方式。
- OpenSpec 只在行为需要跨任务、跨项目或多人长期契约时使用。
- 不复制 TIC Skills，不覆盖 adapter、memory、自定义规则或未提交改动。
- 不默认执行分支、提交、推送、合并、tag、发布、外部写入、生产、迁移或
  数据删除。
- 用户已明确要求具体受保护结果时复用该授权；仅在目标歧义或范围扩大时再问。
- 没有新鲜验证证据不得声称完成；普通交付默认做完整 diff 自审。

规则源缺失时使用普通安全边界完成当前任务，不虚构 TIC 流程。
