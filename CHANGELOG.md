# Changelog

本文件记录 Team-Intelligence-Center 公开版本。版本详情见 `docs/releases/<version>/README.md`。

## 0.5.1 - 2026-08-07

### Changed

- 用规划深度、执行授权、验证范围、Review 和事实持久化五个独立维度替代
  `direct`、`structured`、`guarded` 综合模式。
- 任务契约扩展为 outcome、boundaries、done、verification、authority。
- Superpowers 等外部 Skills 降为按需方法库，总控型 Skill 不再是项目入口。
- OpenSpec 明确为长期规格事实源；普通任务不自动创建 change，同一事实只
  保留一个主事实源。
- 验证改为贯穿执行的证据线；每次交付做 diff 自审，高影响变更按需独立
  Review。
- 清理 canonical 与兼容 Skills 中遗留的 CP 检查点和旧任务档位语义。

[版本详情](docs/releases/0.5.1/README.md)

## 0.5.0 - 2026-08-07

### Added

- 新增 `Workflow/core.md`、`Workflow/capability-schema.md` 和行为场景，
  建立 `direct`、`structured`、`guarded` 三模式的动作级决策。
- 新增 canonical `collaboration-memory-maintainer` Skill 和 Codex 全局
  `tic-collaboration-memory-maintainer` wrapper。
- 新增 `ai-harness/memory/` 共享项目记忆骨架，以及 gitignored 的
  `.tic/local/` 个人画像和候选模板。
- 新增有授权、有证据、分范围、可过期、可冲突处理的 Collaboration
  Intelligence Loop。

### Changed

- 全部 Skills 迁移到 `tic_capability.v1`，移除 metadata 级流程路由和
  默认调用链。
- `tic-workflow-orchestrator` 降为显式复杂规划和旧版迁移的兼容能力，
  普通任务不再经过统一入口。
- 产物改为消费者驱动；验证强度与执行模式分别判断；只有受保护动作暂停
  确认。
- 协作记忆改为显式 Capability，不再自动参与每个任务；检索和提取必须由
  用户要求或已确认的项目约定触发。
- Shell / PowerShell bootstrap 首次创建共享 memory，普通安装、刷新和
  升级逐文件保留已有内容，并将 `.tic/local/` 加入 `.gitignore`。
- Project Adapter 新增 `artifact_roots.memory_root`；历史对话分析必须得到
  明确授权，原始聊天、秘密、认证状态和个人敏感信息禁止落盘。

[版本详情](docs/releases/0.5.0/README.md)

## 0.3.0 - 2026-07-31

### Added

- 新增 canonical `e2e-verification` Skill 和 Codex 全局
  `tic-e2e-verification` wrapper。
- 新增按风险触发的 E2E Verification Gate，统一环境、认证、测试数据、
  核心旅程、证据、清理和 verdict 生命周期。
- `project-adapter.md` 新增 `verification.e2e` schema，并同步 Shell /
  PowerShell 首次生成器和保护性迁移规则。

### Changed

- `tic-workflow-orchestrator` 在 Verification phase 条件路由 E2E；
  consulting / micro 继续保持轻量。
- 项目原生可重复套件成为主要事实源；Playwright Test 是未指定 runner
  时的 Web 默认候选，MCP、Browser、Chrome 和 Computer Use 保持可替换。

### Fixed

- 修复重复 refresh `AGENTS.md` marker 时在文件末尾累积空白行的问题；
  Shell 与 PowerShell 写入逻辑同步，并新增字节级幂等回归。

[版本详情](docs/releases/0.3.0/README.md)

## 0.2.2 - 2026-07-27

### Fixed

- 修复 macOS Bash 3.2 在 `set -u` 下展开空 `CODEX_HOME_ARG` 数组，
  导致默认一键更新在刷新 Codex 全局 Loader 前退出的问题。
- 默认 Codex home 与显式 `--codex-home <path>` 现在使用同一刷新函数，
  不再依赖空数组参数拼接。

### Added

- 新增隔离的 Shell 更新回归，覆盖默认 preview、默认 apply 和显式
  Codex home 参数透传，不写入真实 Codex 目录。

[版本详情](docs/releases/0.2.2/README.md)

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
