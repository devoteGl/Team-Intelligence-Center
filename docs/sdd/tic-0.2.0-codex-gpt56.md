# TIC 0.2.0：Codex / GPT-5.6 工作流升级

## 目标

在保留 TIC 风险治理、规格事实源、契约和证据链的前提下，降低普通任务的流程摩擦，并为已接入项目提供可选择、可回退、可验证的版本更新路径。

## 范围

- 将包版本从 `0.1.0` 升级到 `0.2.0`。
- 以发布记录和 Git 提交证据归档 `0.1.0`。
- 把无条件阶段暂停改为基于动作风险的确认边界。
- 用风险信号取代乘法复杂度分作为主分级依据。
- 同线程原生 subagent 默认使用 Codex 自带编排；跨线程、长时或审计场景才落盘 agent run artifact。
- 统一包版本、release/hotfix 分支和 tag 的默认版本格式为 SemVer；保留项目自定义策略。
- 为更新脚本增加 `stable`、`current` 和显式 `ref` 更新方式。
- 补充已有使用者的升级、锁定和回退说明。

## 非目标

- 不创建 Git 分支、commit、tag、push、merge 或远端 Release。
- 不替业务项目决定分支策略、发布窗口或部署方式。
- 不把 TIC 绑定为 Codex-only；Codex 原生能力仍作为可选适配层。
- 不复制 `0.1.0` 全量源码到仓库内形成重复快照。

## 设计依据

- [Codex Best practices](https://learn.chatgpt.com/guides/best-practices)：`AGENTS.md` 应保持实用、准确，并围绕项目上下文、完成标准和验证方式组织。
- [Codex Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)：当前 Codex 原生提供 subagent 线程、状态查看和主线程汇总；并行适合可独立的读取、测试和分析工作，写密集型并行需要控制冲突。
- [OpenAI GPT-5.6 model guidance](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.6)：GPT-5.6 更能从上下文理解意图，提示应保留领域上下文、硬约束、审批边界和成功标准，而不必规定每一步。

这些依据支持“精简机械阶段、保留高风险边界、依赖真实验证、优先使用宿主原生状态”的改造方向。TIC 不把 GPT-5.6 的 API beta multi-agent 等可选能力写成强制依赖。

## 行为规格

### 工作流

1. `consulting` 与 `micro` 任务保持连续执行。
2. `standard` 任务必须有验收口径和验证，但只有存在关键决策、外部副作用或高风险动作时才等待确认。
3. `critical` 任务保留回滚、证据、人工确认和交付归档。
4. 删除生成物、替换旧实现等可恢复的范围内改动，不因“删除/重构”字样一律暂停；删除用户数据、生产资源、公共契约或大范围历史内容仍必须确认。
5. 同一 Codex 任务内的原生 subagent 由主 Agent 收口；只有跨任务、异步接力、长时运行或审计要求时才创建 `.tic/agent-runs/`。

### 版本与更新

1. `VERSION`、`manifest.json` 与生成入口必须一致。
2. 默认稳定更新只接受 SemVer release tag，并在规则库工作树干净时切换到最新稳定 tag。
3. 贡献者可使用 `current` 通道对当前分支执行 fast-forward 更新。
4. 团队可用显式 `ref` 锁定 tag、分支或 commit；更新后项目 lock 记录实际规则版本。
5. 规则源为 submodule 时，更新后必须提醒用户审阅并提交父项目的 submodule 指针。
6. 更新失败不得覆盖业务项目入口或全局包装器。

## 验收标准

- `bash tools/validate-pack.sh` 通过。
- Shell 脚本通过 `bash -n`。
- PowerShell 脚本在可用环境中通过解析检查；不可用时记录未测。
- 在临时 Git 仓库中验证：
  - `current` 通道只 fast-forward 当前分支。
  - `stable` 通道选择最高 SemVer tag。
  - `--ref` 可锁定明确 ref。
  - dirty 规则库拒绝切换版本。
- 临时业务项目安装与刷新后，`.tic-rules.lock` 记录 `0.2.0`。
- 0.1.0 和 0.2.0 发布记录均可追溯，且 0.1.0 指向归档提交。

## 回滚

- 发布前：恢复本次工作树改动即可。
- 发布后：使用 `tools/update.* --ref 0.1.0` 回到归档 tag；若 tag 尚未发布，可使用归档记录中的 commit。
- 业务项目刷新前会继续使用现有备份机制保留被替换入口。
