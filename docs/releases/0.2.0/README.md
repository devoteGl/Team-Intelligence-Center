# 0.2.0 发布记录

- 状态：待发布（本地验收通过）
- 目标日期：2026-07-27
- 基线版本：`0.1.0`
- 发布 tag：待用户确认后创建
- 发布归属：Team-Intelligence-Center

## 版本目标

让 TIC 更适配 Codex / GPT-5.6 的自主执行、原生 subagent 和渐进式技能加载，同时保留组织级风险治理、规格事实源、人工确认边界和证据归档。

## 计划变更

- 精简普通任务的阶段门禁。
- 以风险信号替代乘法复杂度分。
- 区分同线程原生 subagent 与跨线程 agent session artifact。
- 统一默认版本格式为 SemVer。
- 增加稳定版、当前分支和指定 ref 更新通道。
- 补充现有使用者的升级、锁定和回退文档。

## 发布前检查

- [x] `VERSION` 与 `manifest.json` 一致
- [x] 规则包校验通过
- [x] Shell 更新路径完成验证
- [ ] PowerShell 更新路径运行验证（当前环境无 PowerShell；已做结构对照）
- [x] 临时业务项目安装与刷新验证通过
- [x] 0.1.0 归档记录可追溯
- [x] Changelog 已更新
- [ ] tag、push 和远端 Release 已由用户确认

验证证据见 [../../test-evidence/tic-0.2.0/README.md](../../test-evidence/tic-0.2.0/README.md)。
