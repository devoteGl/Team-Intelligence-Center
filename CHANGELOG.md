# Changelog

本文件记录 Team-Intelligence-Center 公开版本。版本详情见 `docs/releases/<version>/README.md`。

## 0.2.1 - 2026-07-27

### Fixed

- 普通安装、`--refresh` / `--force` 和一键升级不再覆盖已有 `ai-harness/project-adapter.md`。
- Shell 与 PowerShell 安装链统一使用显式 `--regenerate-adapter` / `-RegenerateAdapter` 执行有备份的完整重生成。
- 首次生成 adapter 时识别 `.gitmodules` 子项目和多仓工作区归属，避免把工作区误判成单项目。

### Added

- 新增 canonical `project-adapter-maintainer` Skill，支持 `create`、`enrich`、`audit`、`migrate`、`repair` 五种模式。
- 新增 Codex 全局 `tic-project-adapter-maintainer` 轻量 wrapper。
- 新增 adapter 保留、显式重生成、备份恢复和多仓识别的回归测试。

[版本详情](docs/releases/0.2.1/README.md)

## 0.2.0 - 2026-07-27

- 优化 Codex / GPT-5.6 下的自适应工作流和确认边界。
- 增加稳定、当前分支和指定 ref 更新路径。
- 统一默认 SemVer 策略并保留项目级版本策略。
- 将同线程原生 subagent 与跨线程审计 artifact 分层。
- 将会话快照改为跨任务、跨工具、长时异步或审计场景按需生成。
- 让 Git 建议优先解析项目声明的基线，UI 流程按当前环境能力路由。

[版本详情](docs/releases/0.2.0/README.md)

## 0.1.0 - 2026-07-27

- 首个 public preview。
- 提供 adaptive workflow、TIC Skills、轻量 bootstrap、规则发现和交付证据链。

[归档详情](docs/releases/0.1.0/README.md)
