# TIC 0.2.1 本地验证证据

- 验证日期：2026-07-27
- 当前状态：adapter 保护逻辑和规则包校验通过；发布后 stable 冒烟发现
  Bash 3.2 一键更新缺陷
- 验证范围：Shell 语法、规则包一致性、adapter 保留、显式重生成、备份恢复、多仓工作区识别、PowerShell 结构对齐。

## 已通过的行为检查

- `bootstrap --force` 前后，现有 adapter 校验和一致。
- `bootstrap --force --regenerate-adapter` 会替换当前 adapter，并在 `.tic-backups/` 中保留旧 sentinel。
- `.gitmodules` 中的 `live-api` 和 `live-web` 被写入 `child_projects`。
- 检测到 `.gitmodules` 时，生成的 `artifact_ownership.owner_type` 和 `release_ownership.owner_type` 为 `workspace`。
- 用户实际更新链 `update --no-pull --no-global --project <fixture>` 保留 adapter 校验和，并把 `.tic-rules.lock` 更新为 `rules_version=0.2.1`。
- 受影响业务工作区的当前 adapter 已从 `.tic-backups/20260727161519/` 恢复，恢复后文件与备份 SHA-256 一致；未修改该工作区其他脏文件。
- 独立 code-reviewer 最终审查 24 个变更与新增文件，
  CRITICAL/HIGH/MEDIUM/LOW 均为 0，结论为 `APPROVE`。

## 发布后补充冒烟

- `bash tools/update.sh --preview --no-pull --no-project` 在 macOS Bash
  `3.2.57` 下失败。
- `bash tools/update.sh --no-pull --no-project` 在相同运行时下同样失败。
- 根因是 `set -u` 模式下展开空的 `CODEX_HOME_ARG` 数组。
- 显式传入 `--codex-home <path>` 的 preview 已验证通过。
- 原验证只覆盖了带 `--no-global` 的项目更新链，因此没有进入该分支。
- 该问题不否定 adapter 保留结论，但阻塞 0.2.1 默认一键更新入口；
  已发布 tag 不移动，应以新 hotfix 修复。

## 最终验证命令

```bash
bash -n tools/*.sh
jq empty manifest.json
git diff --check
bash tools/validate-pack.sh
```

上述命令均通过；`validate-pack.sh` 最终输出 `Validation passed.`。

## PowerShell

Shell 与 PowerShell 已做参数、保护条件、备份路径和 workspace 检测的结构对照。当前环境没有 `pwsh` 或 Windows PowerShell，因此运行时解析和行为测试记为未测，不伪报通过。

## Git 与发布边界

验证阶段没有创建 commit、推送分支、合并或打 tag。用户随后明确授权并已完成
`hotfix/0.2.1` 的 commit、合并、tag、push 和 develop 回灌。最终 tag 落点、
远端状态、真实工作区升级结果及发布后已知问题见
`docs/releases/0.2.1/evidence.md`。
