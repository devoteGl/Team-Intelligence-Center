---
business: e2e-verification-standardization
version: 0.3.0
release_tag: 0.3.0
release_owner_type: project
release_owner_id: Team-Intelligence-Center
release_registry_root: docs/releases
date: 2026-07-31
---

# E2E 验证标准化

## 发版概览

- mode：`single`
- tag 类型：`release`
- tag 仓库：Team-Intelligence-Center
- tag 来源：`release/0.3.0`
- tag 目标：`44a5360a6e1307eeeee177b452703e4b25474d5e`
- 远端状态：本地 annotated tag 已创建；按用户要求未 push
- 部署触发：tag push 后进入 stable 更新通道
- 发布对象：E2E canonical Skill、Codex wrapper、工作流路由、
  Project Adapter schema、bootstrap 与验证规则
- 不发布对象：业务代码、数据库、生产配置和具体项目测试脚手架

## 使用说明

新项目首次接入会在 `project-adapter.md` 中获得 `verification.e2e`
配置。已有项目普通升级仍逐字节保留现有 adapter；需要补充新字段时，
显式使用 `project-adapter-maintainer(mode=migrate)`。

`tic-workflow-orchestrator` 在 standard / critical 任务中判断 E2E 为
`not-required`、`targeted`、`required` 或 `required-gate`。项目原生
可重复套件优先；Playwright Test、MCP、Browser、Chrome 和 Computer
Use 都是可替换实现能力。

## QA 冒烟

- `bash tools/validate-pack.sh` 返回 `Validation passed.`
- 新项目 bootstrap 生成 `verification.e2e` schema。
- 普通 refresh 保持已有 `project-adapter.md` 校验和不变。
- 显式 regenerate 先备份旧 adapter，再生成新 schema。
- 重复 refresh 不累积 `AGENTS.md` 文件末尾空行。
- 临时 Codex 安装包含 `tic-e2e-verification` wrapper。
- stable 更新通道选择 `0.3.0`，项目 lock 更新为 `0.3.0`。

## 监控与反馈

- 观察 E2E gate 是否导致 consulting / micro 任务成本异常上升。
- 观察 `required-gate`、`blocked`、`partial` 和 `waived` 是否被如实记录。
- 观察老项目是否误以为普通升级会自动改写 adapter。
- PowerShell 运行时 fixture 作为长期验证项，在 Windows / pwsh 环境补证据。
- 业务项目反馈写回对应项目的 adapter、验证证据和 TIC 候选规则。

## 回滚

- 规则包回滚目标为 tag `0.2.2`。
- 使用显式 ref 更新可回到旧规则：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project \
  --ref 0.2.2
```

- 已有项目 adapter 在普通 0.3.0 更新中不会被改写，因此回滚不需要恢复
  adapter。
- 如果项目曾显式迁移 E2E schema，可保留未知扩展字段；如确需移除，
  必须先备份并由项目 owner 确认。
- 无数据库、数据迁移或不可逆步骤。

## 发布结果

- 本地 `master` 与 `0.3.0^{commit}` 均指向
  `44a5360a6e1307eeeee177b452703e4b25474d5e`。
- 本地 `develop` 已通过
  `a68955e4690aaf74437d2449f8e2999d08b59bb4` 完成回灌。
- 隔离 tag 安装冒烟通过；远端 stable 选择待后续 push 后验证。
- tag 落点、远端状态、develop 回灌和 stable 更新结果见
  `docs/releases/0.3.0/evidence.md`。
