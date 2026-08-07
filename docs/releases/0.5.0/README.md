# 0.5.0 开发记录

- 状态：本地开发与试运行
- 日期：2026-08-07
- 基线版本：`0.3.0`
- 基线 tag commit：`44a5360a6e1307eeeee177b452703e4b25474d5e`
- 开发分支：`feature/collaboration-intelligence-loop`
- 候选 tag：`0.5.0`（尚未创建）
- 权威远端：`origin`
- 远端状态：按用户要求，本次开发过程不 push
- 发布归属：Team-Intelligence-Center
- release registry root：`docs/releases`

## 版本目标

建立 direct-by-default、按动作升级的 Workflow Core，并把协作记忆作为
显式 Capability 纳入同一能力模型。普通任务不经过默认 Orchestrator，
额外产物由明确消费者驱动。

## 版本变更

- 新增 `Workflow/core.md`、`Workflow/capability-schema.md` 和行为场景。
- 全部 Skills 迁移到 `tic_capability.v1`，取消 metadata 级自动路由。
- Orchestrator 降为显式规划和旧版兼容能力。
- 新增 canonical `Skills/collaboration-memory-maintainer.md`。
- 新增 Codex 全局 `tic-collaboration-memory-maintainer` wrapper。
- 新增 `ai-harness/memory/` 五个共享模板和 `templates/tic-local/` 两个
  本地模板。
- 协作记忆改为用户明确要求或确认长期复用价值时启用。
- Project Adapter 新增 `artifact_roots.memory_root`。
- Shell / PowerShell bootstrap 首次创建共享 memory、普通刷新逐文件保留，
  并自动 gitignore `.tic/local/`。
- 规则、使用指南、manifest、安装说明和验证器同步到 `0.5.0`。

## 交付门禁

| 产物 | 路径 | 状态 |
| --- | --- | --- |
| Workflow SDD | `docs/sdd/tic-0.5.0-workflow-core-redesign.md` | 已落盘 |
| Memory SDD | `docs/sdd/tic-0.5.0-collaboration-intelligence-loop.md` | 已迁移 |
| 验证证据 | `docs/test-evidence/tic-0.5.0/README.md` | 本地验证通过 |
| Walkthrough | `docs/walkthroughs/tic-0.5.0-collaboration-intelligence-loop.md` | 已迁移 |
| Release Handoff | `docs/releases/0.5.0/changes/collaboration-intelligence-loop/README.md` | 已迁移 |
| 历史 Memory 试运行 | 一个父工作区 + 7 子项目 | 已保留，0.5.0 未重跑 |
| 远端 push / tag | 不适用 | 未授权，不执行 |

## 当前边界

- 0.5.0 尚未创建 tag，不进入远端 stable 通道。
- PowerShell 运行时 fixture 延续为长期验证项；本次执行静态对齐。
- 业务行为仍以 OpenSpec / PRD 为事实源，memory 不替代规格。
- 不自动创建或提交个人画像，不自动扫描历史任务，也不默认检索 Memory。
