# TIC 0.2.1：Project Adapter 保护性升级

## 问题

0.2.0 的一键更新会调用 `install --refresh`，再映射为 bootstrap `--force`。旧实现把 `--force` 同时用于刷新生成入口和覆盖 `ai-harness/project-adapter.md`，导致项目维护的工作区拓扑、模块边界、命令、风险和本地决策被浅层自动探测结果替换。

## 目标

- 普通安装、刷新和升级保留现有 adapter。
- adapter 的完整重生成必须使用独立、显式、可备份的参数。
- 提供证据驱动的 adapter 创建、补全、审计、迁移和修复 Skill。
- 首次生成时识别 `.gitmodules` 子项目，避免把多仓工作区误判为单项目。
- Shell、PowerShell、文档、manifest 和 Codex wrapper 保持一致。

## 非目标

- 不自动重写已有 adapter 的 schema。
- 不在本 hotfix 中替业务项目决定分支、tag、部署或产物归属。
- 不复制外部 agent 角色正文。
- 设计与实现阶段不静默执行 commit、push、merge、tag；发布动作只在用户明确确认后按 Git Flow 执行。

## 行为规格

### 普通刷新

当 `ai-harness/project-adapter.md` 已存在时：

1. `bootstrap --force` 只刷新生成的规则入口文档。
2. `install --refresh` 复用该行为。
3. `update` 继续调用 `install --refresh`，但 adapter 字节内容保持不变。
4. 输出计划应明确显示 adapter 被保留。

### 显式重生成

只有传入 `--regenerate-adapter` 或 `-RegenerateAdapter` 时：

1. 先把现有 adapter 写入 `.tic-backups/<timestamp>/`。
2. 再用当前探测结果生成新文件。
3. `.gitmodules` 中的 `path` 写入 `child_projects`。
4. 检测到 `.gitmodules`、`pnpm-workspace.yaml`、`apps/` 或 `packages/` 时，归属类型使用 `workspace`。

### 保护性维护

`project-adapter-maintainer` 提供：

- `create`：文件缺失时创建。
- `enrich`：只补空值、占位值和缺失章节。
- `audit`：只读核对。
- `migrate`：增加新 schema 字段，不覆盖已有值。
- `repair`：从 Git、备份和当前文件恢复最完整版本，再合并新 schema。

现有非占位内容、自定义章节和本地决策优先于自动探测结果。

## 验收标准

- `VERSION` 与 `manifest.json` 都是 `0.2.1`。
- `bash -n` 覆盖全部 Shell 工具。
- `bash tools/validate-pack.sh` 通过。
- 临时项目中，`--force` 前后 adapter 校验和一致。
- 显式重生成后，旧 sentinel 只存在于备份，新 adapter 识别 workspace 和子项目。
- PowerShell 参数与 Shell 参数结构对齐。
- README、USAGE、自动化文档和项目模板不再指导用户用 `--force` 刷新 adapter。

## 回滚

- 代码层：回退 hotfix 分支改动。
- 项目层：从 `.tic-backups/<timestamp>/ai-harness/project-adapter.md` 恢复。
- 已使用 `--regenerate-adapter` 且未确认新内容时，不应提交新 adapter。
